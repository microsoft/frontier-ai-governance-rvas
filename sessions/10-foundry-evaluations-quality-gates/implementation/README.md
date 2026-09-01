# Foundry evaluations and release quality gates

## Session scope

### What we will do

Create and run `release-gate.py` for two fixed versions of the Session 05 agent. Both versions use
the same versioned synthetic data and Foundry evaluation definition. The approved aggregate must
return `PASS`. The in-memory tool-process regression must return `BLOCK`.

### Why it matters

The gate gives the release owner one usable decision without averaging away a failed tool path or
safety metric. Session 14 can run the same command before promotion.

### Boundaries

Use the approved nonproduction Foundry project. The stable endpoint stays pinned to the approved
version, and the runner targets named versions directly.

Foundry stores queries, responses, tool calls, evaluator reasons, and row-level results. The
approved release platform stores payload-free aggregates, gate state, and promotion decisions. The
repository stores the evaluation definition, synthetic data, thresholds, release policy, scripts,
and restore runbook.

The gate decides eligibility. It does not promote an agent or change the stable selector. Preview
task-adherence, prohibited-action, and sensitive-data-leakage evaluators stay advisory. Session 10
remains the authorization boundary for prohibited writes.

## Architecture

### Architecture at a glance

![Approved and candidate versions use the same data and evaluators before release thresholds return PASS or BLOCK.](../assets/diagrams/evaluation-release-gate-flow.svg)

The runner sends the same synthetic cases to two immutable agent versions. Foundry keeps detailed
results. The release gate reads payload-free aggregates, applies the repository policy, and returns
`PASS` or `BLOCK` to the approved release platform.

### Design choices and tradeoffs

| Decision | Chosen approach | Tradeoff |
|---|---|---|
| Test data | Versioned synthetic golden set | A changed use case or risk needs a new baseline |
| Gate structure | Separate final-answer, tool-process, and safety layers | Several owners must maintain explicit floors |
| Protected material | Blocking in East US 2 | The run stops if that supported path is unavailable |
| Authoritative state | Foundry keeps detail; the release platform keeps gate and promotion state | The gate reads external result records |

### Architecture guidance

- [Cloud Evaluation with the Microsoft Foundry SDK](https://learn.microsoft.com/en-us/azure/foundry/how-to/develop/cloud-evaluation)
- [Evaluate your AI agents](https://learn.microsoft.com/en-us/azure/foundry/observability/how-to/evaluate-agent)
- [Evaluation regions, limits, and virtual networks](https://learn.microsoft.com/en-us/azure/foundry/concepts/evaluation-regions-limits-virtual-network)

## Before you start

Confirm the following:

- The approved and candidate versions are different immutable versions of the Session 05 agent.
- The stable endpoint is pinned to the approved version.
- The operator and project managed identity have **Foundry User** on the exact project.
- A network-isolated project has the approved delegated evaluation subnet.
- The quality owner has confirmed same-day regional and evaluator support.
- The tool owner has approved tool-call evaluators for the Function Tool path.
- The cost owner has approved judge-model and evaluation consumption.
- The golden set contains synthetic content only. Each JSONL row stays below 2 MB, and the batch
  stays within 100,000 rows.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Runtime | [`artifacts/eval/evaluation-spec.json`](artifacts/eval/evaluation-spec.json) | The evaluation runner, release gate, preflight scripts, and Session 14 validators |
| Runtime | [`artifacts/eval/data/golden-v1.jsonl`](artifacts/eval/data/golden-v1.jsonl) | The evaluation runner and release gate |
| Deployment | [`artifacts/eval/thresholds.yaml`](artifacts/eval/thresholds.yaml) | The release gate, preflight scripts, and Session 14 validators |
| Deployment | [`artifacts/release/release-policy.json`](artifacts/release/release-policy.json) | The release owner, release gate, preflight scripts, and Session 14 promotion workflow |
| Record | [`artifacts/operations/disable-and-restore.md`](artifacts/operations/disable-and-restore.md) | The release owner and incident operator |

## Decisions and stop conditions

Set required values through the approved delivery change path. Keep project endpoints, resource
IDs, subscriptions, tokens, prompts, responses, tool payloads, and personal data out of the
repository.

### Set the gate policy

Before the baseline run:

- The quality owner approves the relevance floor.
- The tool owner approves the tool-call accuracy and success floors.
- The safety owner approves safety floors of `1.00`.
- Every blocking metric has a maximum error count of `0`.

After the run, set each active quality or tool threshold no lower than its owner-approved floor and
no higher than the approved baseline result. Conflicting bounds stop the gate. Fix the approved
version or change the owner floor through the delivery path. Do not weaken a floor to fit the
baseline.

The threshold policy, release policy, and approved aggregate must name the same baseline run ID.

### Keep the target and evaluator boundary fixed

Run the complete gate in **East US 2** while protected material remains blocking there. If that path
is unavailable, stop. Move the gate or have the safety and release owners revise the policy before
another run.

Keep the gate disabled if the evaluated path adds Azure AI Search, Bing Grounding, Bing Custom
Search, SharePoint Grounding, Code Interpreter, Fabric Data Agent, or Web Search. The tool owner
must approve compatibility again.

The gate returns `PASS` only when every blocking metric is present, meets its threshold, and has
zero evaluator errors. Preview evaluators cannot become the sole blocking control.

An exception may cover an eligible final-answer quality failure. It must name the metric and
business reason, compensating control, owner, exception authority, and expiry. It cannot override a
safety or tool-process failure or enable automatic promotion.

Stop when a version is mutable or implicit, the project or region is wrong, a limited-support tool
enters the path, a preview evaluator becomes blocking, or a safety or tool-process failure is
treated as overridable.

## Implement

### 1. Set the runtime context

Complete the shared execution-environment setup in the root README. Sign in to the approved Azure
subscription, install the Python dependencies, and set the external release-store path.

```powershell
python -m pip install -r .\scripts\requirements.txt
$approvedSubscriptionId = $env:AZURE_SUBSCRIPTION_ID
$env:FOUNDRY_RESOURCE_ID = $env:APPROVED_FOUNDRY_RESOURCE_ID
$env:FOUNDRY_PROJECT_ENDPOINT = $env:APPROVED_FOUNDRY_PROJECT_ENDPOINT
$env:FOUNDRY_MODEL_NAME = $env:APPROVED_EVALUATION_MODEL
$releaseStore = $env:APPROVED_RELEASE_STORE
```

```bash
python -m pip install -r ./scripts/requirements.txt
approved_subscription_id="${AZURE_SUBSCRIPTION_ID:?Set AZURE_SUBSCRIPTION_ID.}"
export FOUNDRY_RESOURCE_ID="${APPROVED_FOUNDRY_RESOURCE_ID:?Set APPROVED_FOUNDRY_RESOURCE_ID.}"
export FOUNDRY_PROJECT_ENDPOINT="${APPROVED_FOUNDRY_PROJECT_ENDPOINT:?Set APPROVED_FOUNDRY_PROJECT_ENDPOINT.}"
export FOUNDRY_MODEL_NAME="${APPROVED_EVALUATION_MODEL:?Set APPROVED_EVALUATION_MODEL.}"
release_store="${APPROVED_RELEASE_STORE:?Set APPROVED_RELEASE_STORE outside this repository.}"
```

### 2. Run the approved baseline

```powershell
.\scripts\preflight.ps1 -ApprovedSubscriptionId $approvedSubscriptionId -Phase Baseline
python .\scripts\run-evaluation.py `
  --spec .\artifacts\eval\evaluation-spec.json `
  --target approved `
  --output (Join-Path $releaseStore "approved-baseline.json")
```

```bash
./scripts/preflight.sh --approved-subscription-id "$approved_subscription_id" --phase baseline
python ./scripts/run-evaluation.py \
  --spec ./artifacts/eval/evaluation-spec.json \
  --target approved \
  --output "$release_store/approved-baseline.json"
```

Preflight resolves the exact target and rejects invalid scope, support, identity, dataset, policy,
dependency, and budget inputs. The Evals API has no dry run. Inspect row-level detail in Foundry,
then let the control owners activate thresholds within the approved floor and baseline bounds.

### 3. Run and gate the candidate

```powershell
.\scripts\preflight.ps1 -ApprovedSubscriptionId $approvedSubscriptionId -Phase Candidate
python .\scripts\run-evaluation.py `
  --spec .\artifacts\eval\evaluation-spec.json `
  --target candidate `
  --output (Join-Path $releaseStore "candidate.json")
python .\scripts\release-gate.py `
  --policy .\artifacts\eval\thresholds.yaml `
  --spec .\artifacts\eval\evaluation-spec.json `
  --dataset .\artifacts\eval\data\golden-v1.jsonl `
  --baseline-result (Join-Path $releaseStore "approved-baseline.json") `
  --candidate-result (Join-Path $releaseStore "candidate.json") `
  --evaluated-target candidate `
  --expect pass
```

```bash
./scripts/preflight.sh --approved-subscription-id "$approved_subscription_id" --phase candidate
python ./scripts/run-evaluation.py \
  --spec ./artifacts/eval/evaluation-spec.json \
  --target candidate \
  --output "$release_store/candidate.json"
python ./scripts/release-gate.py \
  --policy ./artifacts/eval/thresholds.yaml \
  --spec ./artifacts/eval/evaluation-spec.json \
  --dataset ./artifacts/eval/data/golden-v1.jsonl \
  --baseline-result "$release_store/approved-baseline.json" \
  --candidate-result "$release_store/candidate.json" \
  --evaluated-target candidate \
  --expect pass
```

`PASS` makes the fixed candidate eligible for the approved Session 14 delivery path. `BLOCK` leaves
the approved version pinned. Remediate the failed layer and evaluate a new fixed candidate.

## Confirm the result

### Intended path

Run the gate with the approved aggregate as both inputs. It must return `PASS` with separate
final-answer, tool-process, and safety summaries.

```powershell
python .\scripts\release-gate.py `
  --policy .\artifacts\eval\thresholds.yaml `
  --spec .\artifacts\eval\evaluation-spec.json `
  --dataset .\artifacts\eval\data\golden-v1.jsonl `
  --baseline-result (Join-Path $releaseStore "approved-baseline.json") `
  --candidate-result (Join-Path $releaseStore "approved-baseline.json") `
  --evaluated-target approved `
  --expect pass
```

```bash
python ./scripts/release-gate.py \
  --policy ./artifacts/eval/thresholds.yaml \
  --spec ./artifacts/eval/evaluation-spec.json \
  --dataset ./artifacts/eval/data/golden-v1.jsonl \
  --baseline-result "$release_store/approved-baseline.json" \
  --candidate-result "$release_store/approved-baseline.json" \
  --evaluated-target approved \
  --expect pass
```

### Blocked or failure path

```powershell
python .\scripts\test_release_gate.py --mode blocked-tool-process
```

```bash
python ./scripts/test_release_gate.py --mode blocked-tool-process
```

The test must return `BLOCK` for tool-call accuracy and success while final-answer quality and
safety remain passing.

### Delivery-owner checkpoint

The release owner reviews both outcomes in the approved release platform. A blocked candidate
stays unpinned. After a successful checkpoint, the owner may enable the gate for Session 14. The
gate still cannot promote a version.

## After implementation

Keep the golden data, evaluation specification, thresholds, release policy, scripts, and
disable-and-restore runbook in operation. The quality owner maintains data and thresholds. The
safety owner maintains safety coverage and the protected-material boundary. The tool owner owns
Function Tool compatibility. The cost owner approves consumption. The release owner controls gate
state and the stable selector.

Use [`artifacts/operations/disable-and-restore.md`](artifacts/operations/disable-and-restore.md) to
disable the gate, keep or restore the approved version at 100%, remove delivery integration after
dependency review, and cancel unnecessary evaluations. Do not delete the Foundry project, agent,
model, tool path, logs, or customer data as a shortcut. The scripts never change the stable
endpoint or delete cloud state.
