# Foundry evaluations and release quality gates

## Session scope

### What we will do

Create and exercise a **callable release-eligibility gate for exact agent versions** using repeatable
customer-specific evaluation results. The team runs one versioned golden data set against the
currently approved [Session 06](../../06-governed-agent-baseline/implementation/README.md) version
and a separate candidate version. It activates the approved thresholds and release policy, then
confirms that the approved record returns `PASS` and the in-memory tool-process regression returns
`BLOCK`.

### Why it matters

Release owners need one stable answer to a narrow question: is this exact version eligible to move
forward? Keeping final-answer quality, tool process, and safety separate stops a good average from
hiding a failed tool path or safety check.

### Boundaries

Microsoft Foundry remains authoritative for detailed queries, responses, tool calls, evaluator
reasons, and row-level results. The approved release store holds payload-free aggregate records,
thresholds, and gate state. Preview task-adherence and prohibited-action evaluators stay advisory,
and the gate does not replace the [Session 09](../../09-mcp-tool-security/implementation/README.md)
authorization controls.

This session does not change the stable endpoint or promote a version. It creates and exercises the
callable eligibility contract. [Session 14](../../14-cicd-promotion-controls/implementation/README.md)
places that contract in the protected promotion path and makes promotion depend on it.

## Architecture

### Architecture at a glance

![One versioned golden data set fans into approved and candidate immutable agent versions; evaluator layers converge into aggregate records, then baseline thresholds and release policy return PASS or BLOCK](../assets/diagrams/evaluation-release-gate-flow.svg)

A versioned golden data set is the fixed set of approved test cases for this release decision. The
same set goes through the evaluation path twice: once against the approved Foundry agent version
and once against the candidate. Fixing both target versions and the data hash keeps the comparison
focused on the agent change rather than a moving input.

Foundry runs separate evaluators for the final answer, tool process, and safety. It keeps the
detailed rows and evaluator reasons. The runner sends payload-free aggregates to the approved
release store, where active thresholds and the release policy define the control boundary. The
callable gate reads that state and returns `PASS` or `BLOCK`.

Foundry keeps the evaluation runs and row-level detail. The approved release store keeps the data
hash, aggregates, thresholds, and active policy used for the release decision. The gate can return
a decision, but it cannot change the stable endpoint. Session 14 consumes that result inside its
protected promotion path.

### Design choices and tradeoffs

| Decision | Why this design | What it costs | Change it when |
|---|---|---|---|
| Run one versioned golden set against both exact agent versions | Both results use the same cases and data hash. | A data change requires a new version and approved baseline. | The approved use cases or risk set changes. |
| Keep final-answer, tool-process, and safety rules separate | A strong average cannot hide a failed tool path or safety row. | Owners maintain several thresholds and route failures to the right owner. | A supported evaluator changes status or meaning. |
| Derive active thresholds from the approved baseline, within owner-approved floors | The gate uses observed approved behavior without dropping below owner tolerances. | A weak baseline must be fixed; lowering the floor cannot make it acceptable. | The baseline, evaluator set, or owner tolerance changes. |
| Return `PASS` or `BLOCK` and leave version selection to Session 14 | Evaluation code has no authority to promote a version. | The control is incomplete until the delivery workflow calls the gate. | Session 14 changes its promotion contract. |

### Architecture guidance

The [cloud evaluation SDK guide](https://learn.microsoft.com/en-us/azure/foundry/how-to/develop/cloud-evaluation)
defines the dataset, target, run, and stored-result interfaces. Use the
[agent evaluation guidance](https://learn.microsoft.com/en-us/azure/foundry/observability/how-to/evaluate-agent)
when mapping exact agent versions and aggregate results. Before each run, check the region, network,
and project-identity requirements in the
[evaluation support guidance](https://learn.microsoft.com/en-us/azure/foundry/concepts/evaluation-regions-limits-virtual-network).

## Before you start

Confirm these prerequisites:

- Sessions 01-10 are complete in the full path. For a focused route, confirm the platform inventory
  lists the exact nonproduction Foundry resource, project, policy-assistant agent, approved version,
  candidate version, and stable-endpoint selector.
- For a focused route, confirm the access, gateway, tool, and data records list the operator
  assignment, project-managed-identity assignment, APIM policy reference, `get_policy` allowlist,
  backend role definition ID and assignment scope, prohibited-write decision, and synthetic-data
  classification. The stable endpoint must select the approved version, `get_policy` must read
  successfully, and the prohibited write must be absent or denied.
- The [Session 06](../../06-governed-agent-baseline/implementation/README.md) policy assistant has one currently approved immutable version and a different
  candidate version. The stable endpoint remains pinned to the approved version.
- The [Session 09](../../09-mcp-tool-security/implementation/README.md) `get_policy` path, synthetic records, prohibited write, and human change route remain
  available to the candidate.
- On the day of each run, the quality owner checks the selected project region and evaluator set
  against the current Microsoft evaluation support documentation. Record `supported` and the check
  date in `release-policy.json`. Use that live documentation check as the support authority.
- A network-isolated project has evaluation subnet delegation.
- The project managed identity has **Foundry User** on the exact Foundry project. This role was
  previously named Azure AI User; the role ID and core permissions did not change with the rename.
- The evaluation operator has **Foundry User** on the exact Foundry project. Azure CLI is
  authenticated to the approved subscription, and Python 3 is installed.
- An approved judge-model deployment and an evaluation budget are available. Foundry evaluations and
  agent playground evaluations use consumption-based billing.
- The release owner, quality owner, tool owner, safety owner, cost owner, and exception authority are
  recorded as roles or groups rather than personal data.
- The team has approved the golden data categories and confirmed that all examples are synthetic.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Runtime | [`artifacts/eval/evaluation-spec.json`](artifacts/eval/evaluation-spec.json) | The evaluation runner, release gate, preflight scripts, and Session 14 validators |
| Runtime | [`artifacts/eval/data/golden-v1.jsonl`](artifacts/eval/data/golden-v1.jsonl) | The evaluation runner and release gate |
| Runtime | [`artifacts/eval/thresholds.yaml`](artifacts/eval/thresholds.yaml) | The release gate, preflight scripts, and Session 14 validators |
| Runtime | [`artifacts/gate-tests/cases/tool-process-regression.json`](artifacts/gate-tests/cases/tool-process-regression.json) | The release owner and Session 14 validators |
| Record | [`artifacts/governance/evaluation-governance-decision.md`](artifacts/governance/evaluation-governance-decision.md) | The release, quality, tool, safety, and exception owners |
| Record | [`artifacts/release/release-policy.json`](artifacts/release/release-policy.json) | The release owner, release gate, preflight scripts, and Session 14 promotion workflow |
| Record | [`artifacts/release-records/release-record-template.json`](artifacts/release-records/release-record-template.json) | The release owner and audit reviewers |
| Record | [`artifacts/operations/disable-and-restore.md`](artifacts/operations/disable-and-restore.md) | The release owner and incident operator |

### Official documentation

Use Microsoft’s [cloud evaluation SDK guide](https://learn.microsoft.com/en-us/azure/foundry/how-to/develop/cloud-evaluation)
when checking the current evaluation target, dataset, run, and stored-result interfaces.

## Decisions and stop conditions

Resolve every `__REQUIRED_*__` value before running an evaluation. Keep the Foundry project endpoint,
Azure resource ID, subscription ID, tokens, prompts, responses, tool arguments, tool results, and
personal data out of the repository. Supply the project endpoint and resource ID through environment
variables only.

### Target and version boundary

The approved and candidate agent versions must be different immutable versions of the same
agent. Keep the stable endpoint at 100% of the approved version while both evaluation runs and the
gate checks occur.

**Stop before evaluation** if either version cannot be resolved, the candidate was edited in place, the evaluation points
at the latest version implicitly, or any step changes the stable endpoint. A release record without
an exact agent version is not eligible for this gate.

### Golden data boundary

The supplied JSONL includes normal, edge, refusal, multilingual, sensitive-data, tool-use,
indirect-attack, and failure cases. Every case has a stable `case_id`, one category, a synthetic query,
an expected behavior, and the Session 09 read-only tool definition.

The quality and safety owners must review additions or edits. Change the data set version when content
changes. The runner derives the Foundry dataset version from the local SHA-256 hash, so identical
content is reused and changed content creates a new immutable version.

Stop if a row contains production data, credentials, personal data, real identifiers, unapproved
adversarial content, or more than 2 MB. Stop if the set exceeds 100,000 rows or loses one of the eight
required categories.

### Evaluator boundary

The blocking-eligible set is:

| Layer | Evaluators | Release meaning |
|---|---|---|
| Final-answer quality | `relevance` | The response addresses the request |
| Tool process | `tool_call_accuracy`, `tool_call_success` | The tool choice, input, and execution path are acceptable |
| Safety | `violence`, `hate_unfairness`, `protected_material` | Every evaluated row passes the selected safety checks |

`task_adherence` and `prohibited_actions` are currently preview and advisory only. Stop if either is
made blocking, if a preview signal is presented as production-ready, or if final-answer quality is
used to hide a failed tool-process metric.

The policy starts in `establish_from_approved_baseline` state. Thresholds include draft starter
values: `0.80` for relevance, `0.95` for tool-call accuracy, `0.95` for tool-call success, and
`1.00` for each safety metric. Treat them as examples until the owners listed in the governance decision approve them. Set the
final numbers from the observed approved baseline and the owners' stated tolerance; do not keep a
sample value just because it is already in the file. Safety pass rates remain `1.00`.

Before calculating a threshold, save its metric-specific regression floor in `eval/thresholds.yaml`
and record the decision in
[`artifacts/governance/evaluation-governance-decision.md`](artifacts/governance/evaluation-governance-decision.md).
The quality owner approves the `relevance` floor. The tool owner approves the
`tool_call_accuracy` and `tool_call_success` floors. The safety owner approves the `violence`,
`hate_unfairness`, and `protected_material` floors at `1.00`. Each record includes the floor,
approver, and approval date. Set the threshold no higher than the approved baseline and no lower
than that approved floor. If those bounds conflict, stop and improve the baseline instead of
weakening the gate.

### Region, network, identity, and cost boundary

Complete `release-policy.json` against the current Microsoft region matrix on the day of the run.
Set the support status to `supported` only when the selected region currently supports batch
evaluation, the selected risk and safety evaluators, and protected-material evaluation. This is an
explicit manual gate because the kit does not depend on a stable support-discovery API.

For isolated evaluation, the network owner confirms network injection through the exact delegated
evaluation subnet. The identity owner confirms **Foundry User** for the project managed identity on
the exact Foundry project. Stop if current documentation does not support the selected set, the
subnet is not delegated,
the judge deployment cannot be used from the project, either identity lacks its project-scope
role, or the cost owner has not approved evaluation consumption.

### Release and exception boundary

The gate never promotes an agent. It returns `PASS` or `BLOCK`; the release owner controls the
version selector and later delivery integration.

No exception can override a safety or tool-process failure. A non-safety exception must name a
business reason, compensating control, owner, authority, and expiry. It never enables automatic
promotion. Stop if an exception has no expiry, attempts to override a prohibited action or failed
tool path, or is used to alter an evaluation result.

## Implement

### 1. Complete the required decisions

Populate the release policy, evaluation specification, and threshold baseline version with the
**same agent name and exact versions**.

Set these booleans to `true` only after the corresponding owner confirms them:

- region availability;
- project managed-identity Foundry User role;
- evaluation budget;
- batch, risk-and-safety, and protected-material support; and
- subnet delegation when `networkMode` is `isolated`.

Keep `release-policy.json` gate state at `disabled-pending-session-checkpoint`.

### 2. Install the required SDK dependencies

Use the customer's approved Python environment:

```powershell
python -m pip install -r .\scripts\requirements.txt
```
```bash
python -m pip install -r ./scripts/requirements.txt
```

The implementation runner uses the current `azure-ai-projects` 2.x cloud Evals path. Recheck the SDK and
Microsoft Learn sources before delivery if a later major version is installed. The
[Azure AI Projects evaluation
samples](https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/ai/azure-ai-projects/samples/evaluations)
show the current SDK request patterns; keep this session’s exact dataset and release policy.

### 3. Set the approved runtime context

Keep these values in the shell only:

```powershell
$approvedSubscriptionId = $env:AZURE_SUBSCRIPTION_ID
$env:FOUNDRY_RESOURCE_ID = $env:APPROVED_FOUNDRY_RESOURCE_ID
$env:FOUNDRY_PROJECT_ENDPOINT = $env:APPROVED_FOUNDRY_PROJECT_ENDPOINT
$env:FOUNDRY_MODEL_NAME = $env:APPROVED_EVALUATION_MODEL
```
```bash
approved_subscription_id="${AZURE_SUBSCRIPTION_ID}"
export FOUNDRY_RESOURCE_ID="${APPROVED_FOUNDRY_RESOURCE_ID}"
export FOUNDRY_PROJECT_ENDPOINT="${APPROVED_FOUNDRY_PROJECT_ENDPOINT}"
export FOUNDRY_MODEL_NAME="${APPROVED_EVALUATION_MODEL}"
```

`FOUNDRY_PROJECT_ENDPOINT` has this shape:

```text
https://<account>.services.ai.azure.com/api/projects/<project>
```

Do not pass a token, key, endpoint, subscription ID, or resource ID as a script argument.
`DefaultAzureCredential` uses the customer's approved secretless identity path.

### 4. Run baseline preflight

```powershell
.\scripts\preflight.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -Phase Baseline
```
```bash
./scripts/preflight.sh \
  --approved-subscription-id "$approved_subscription_id" \
  --phase baseline
```

Preflight parses the implementation JSON and JSONL files, rejects every decision sentinel, checks
cross-file agent versions and owners, validates all eight data categories and current row limits,
checks the evaluator layers and preview status, and checks the region against each of the three
required region lists. It also confirms the Azure subscription and Foundry resource scope, imports
the SDK dependencies, and resolves both exact agent versions through the Foundry SDK.

The Evals API has no read-only deployment preview. Before a billable run, preflight prints the
project alias, region, exact approved or candidate agent version, dataset SHA-256, case count,
evaluator names, and the rule that output records contain aggregates only. The release owner
compares those values with the approved run. Preflight and the evaluation runner target an exact
version directly and never call the stable-version selector, so the endpoint remains pinned to the
approved version.

### 5. Run the approved version

```powershell
$spec = ".\artifacts\eval\evaluation-spec.json"
$baselineRecord = ".\artifacts\release-records\approved-baseline.json"

python .\scripts\run-evaluation.py `
  --spec $spec `
  --target approved `
  --output $baselineRecord
```
```bash
spec="./artifacts/eval/evaluation-spec.json"
baseline_record="./artifacts/release-records/approved-baseline.json"

python ./scripts/run-evaluation.py \
  --spec "$spec" \
  --target approved \
  --output "$baseline_record"
```

The runner:

1. resolves both exact agent versions;
2. hashes and reuses or uploads the versioned golden dataset;
3. creates one cloud evaluation definition with the approved evaluators;
4. runs it against the exact approved agent version;
5. polls to a terminal state; and
6. writes only aggregate counts, pass rates, target identifiers, dataset hash, run IDs, and the
   Foundry report URL.

Open the Foundry report to inspect row-level failures and evaluator reasoning. Do not copy those
details into this repository. Stop on an errored evaluator, missing metric, unexpected tool, unsafe
response, unsupported preview behavior, or a run that targets the wrong version.

### 6. Establish thresholds from the approved baseline

Use `approved-baseline.json` and the Foundry report to update `thresholds.yaml`:

1. Before calculating thresholds, enter each metric-specific regression floor, its approver,
   and approval date.
2. Set `baseline.source_run_id` to the approved run ID.
3. Set `baseline.established_on` to the decision date.
4. Set each blocking final-answer and tool-process `minimum_pass_rate` at or below the approved
   baseline and at or above its approved regression floor.
5. Keep safety `minimum_pass_rate` at `1.00`.
6. Keep every `maximum_errored` at `0`.
7. Keep preview rules nonblocking.
8. Change `policy_state` to `active`.
9. Copy the baseline run ID into `release-policy.json`.

A threshold must be explainable from the approved baseline and use-case risk. If the approved version
itself is unacceptable, remediate and create a new approved version; do not lower the policy to make a
bad baseline pass.

Run candidate preflight:

```powershell
.\scripts\preflight.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -Phase Candidate
```
```bash
./scripts/preflight.sh \
  --approved-subscription-id "$approved_subscription_id" \
  --phase candidate
```

Candidate preflight also rejects missing baseline metadata, `null` blocking thresholds, an
inactive policy, or a policy without independent blocking coverage for all three layers.

### 7. Run and gate the candidate version

```powershell
$candidateRecord = ".\artifacts\release-records\candidate.json"
$policy = ".\artifacts\eval\thresholds.yaml"
$dataset = ".\artifacts\eval\data\golden-v1.jsonl"

python .\scripts\run-evaluation.py `
  --spec $spec `
  --target candidate `
  --output $candidateRecord

python .\scripts\release-gate.py `
  --policy $policy `
  --spec $spec `
  --dataset $dataset `
  --baseline-result $baselineRecord `
  --candidate-result $candidateRecord `
  --evaluated-target candidate `
  --expect pass
```
```bash
candidate_record="./artifacts/release-records/candidate.json"
policy="./artifacts/eval/thresholds.yaml"
dataset="./artifacts/eval/data/golden-v1.jsonl"

python ./scripts/run-evaluation.py \
  --spec "$spec" \
  --target candidate \
  --output "$candidate_record"

python ./scripts/release-gate.py \
  --policy "$policy" \
  --spec "$spec" \
  --dataset "$dataset" \
  --baseline-result "$baseline_record" \
  --candidate-result "$candidate_record" \
  --evaluated-target candidate \
  --expect pass
```

If the candidate blocks, leave it unpinned. Send a final-answer quality failure to the quality
owner, a tool selection or execution failure to the tool owner, and a safety failure to the safety
owner. The release owner keeps the stable selector on the approved version. After the responsible
owner completes remediation, create a new candidate version instead of changing the evaluated
version.

Update the candidate run ID in `release-policy.json`. Do not set the decision to enable yet.

## Confirm the result

**Keep the release owner present.** The owner confirms the gate behavior here; production approval
remains in Session 14.

### Intended path: approved version passes

Apply the active baseline-derived policy to the approved baseline record:

```powershell
python .\scripts\release-gate.py `
  --policy $policy `
  --spec $spec `
  --dataset $dataset `
  --baseline-result $baselineRecord `
  --candidate-result $baselineRecord `
  --evaluated-target approved `
  --expect pass
```
```bash
python ./scripts/release-gate.py \
  --policy "$policy" \
  --spec "$spec" \
  --dataset "$dataset" \
  --baseline-result "$baseline_record" \
  --candidate-result "$baseline_record" \
  --evaluated-target approved \
  --expect pass
```

Expected result:

- the gate returns `PASS`;
- final-answer, tool-process, and safety lines are printed separately;
- every blocking evaluator is present and has zero errors;
- the approved run ID matches the threshold source; and
- no prompt, response, tool payload, or evaluator reason appears in the aggregate record.

Stop if the approved baseline does not pass its active thresholds or if the gate combines the three
layers into one average.

### Blocked path: below-threshold tool process

Run the stable blocked-path command. It creates payload-free aggregate records in memory and calls
the same metric decision function used by `release-gate.py`:

```powershell
python .\scripts\test_release_gate.py --mode blocked-tool-process
```
```bash
python ./scripts/test_release_gate.py --mode blocked-tool-process
```

Expected result:

- the gate returns `BLOCK`;
- final-answer quality remains passing;
- `tool_call_accuracy` and `tool_call_success` are identified as separate tool-process failures;
- safety remains passing; and
- the candidate remains unpinned.

Stop if a strong final answer masks the tool failure or the test requires a saved case file,
disposable agent, dataset, or cloud resource.

### Delivery-owner checkpoint

The release owner observes both gate behaviors and the actual candidate outcome:

- **Enable the gate:** set `gate.state` to `enabled`, `gate.decision` to `approved`, and
  `gate.decisionDate` to the approval date only when the approved path passes, the blocked self-test
  returns `BLOCK`, every blocking candidate metric is complete, and the planned
  [Session 14](../../14-cicd-promotion-controls/implementation/README.md) delivery path names this
  gate. `gate.baselineRunId` must equal both the supplied baseline run ID and
  `thresholds.yaml` `baseline.source_run_id`. `gate.candidateRunId` must equal the supplied
  candidate run ID.
- **Disable the gate:** keep the decision `disabled`, leave the stable endpoint on the approved
  version, and route gate defects to the quality owner.

An enabled gate makes a passing candidate eligible for the later delivery path. It does not itself
promote the candidate or approve production.

## After implementation

Keep the **golden data set and active release policy**, along with the immutable Foundry dataset
versions, evaluation definitions and runs, aggregate release records, active threshold policy,
consolidated release policy, and scripts.

The quality owner owns the data set, evaluator selection, and threshold history. The safety owner owns
the safety set and preview-evaluator boundary. The tool owner owns tool-process failures. The cost
owner monitors evaluation consumption. The release owner owns the stable version selector and gate
state. In [Session 14](../../14-cicd-promotion-controls/implementation/README.md), the controlled
promotion workflow invokes `release-gate.py` with the approved evaluation specification, threshold
policy, approved baseline record, candidate record, and release policy. It must pass both
`--release-policy implementation/artifacts/release/release-policy.json` and `--require-enabled`.
That mode rejects a pending or disabled gate, an unapproved or undated decision, an inactive
threshold policy, or mismatched run IDs before it evaluates metrics. Session 14 may call
`test_release_gate.py --mode blocked-tool-process` for the same in-memory blocked-path test.

Run this implementation only against the nonproduction Foundry project, policy-assistant agent, two
agent versions, synthetic data set, and evaluator set listed in the evaluation spec. It does not approve a model
catalog change, production traffic, continuous production evaluation, red teaming, broad trace
collection, or automatic promotion.

The immediate disable switch is the stable endpoint selector. Keep or restore the approved [Session 06](../../06-governed-agent-baseline/implementation/README.md)
version at 100%. Follow
[`artifacts/operations/disable-and-restore.md`](artifacts/operations/disable-and-restore.md) before
removing a gate, evaluation definition, or dataset version. The scripts do not change the endpoint or
delete cloud state.
