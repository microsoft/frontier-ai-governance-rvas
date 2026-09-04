# Evaluation, red-team, and threat release gates

## Session scope

### What we will do

**Create one release decision from quality and security checks.** We will evaluate fixed agent versions, run a bounded adversarial plan, confirm the Defender-to-SOC route, and prove that the release gate passes the approved version and blocks a regression.

### Why it matters

An average quality score can hide a broken tool path or safety regression. The combined gate keeps quality, tool process, prohibited actions, and threat routing separate so one good score cannot cover a failed control.

### Boundaries

The work stays in the approved nonproduction Foundry project and Citadel access path. Foundry keeps detailed evaluation results. The approved release and security stores keep payload-free aggregates. Session 07 consumes the pass or block decision.

## Architecture

### Architecture at a glance

Evaluation attaches to the versioned agent or application target. It does not run inside an APIM
policy. APIM supplies the governed endpoint and runtime controls; Foundry runs the evaluation and
red-team jobs; the customer-owned gate turns their results into a release decision.

```text
Governed Citadel endpoint
APIM runtime controls -> fixed agent + fixed tools
                              |
                 +------------+------------+
                 |                         |
          Foundry evaluation       authorized red-team run
                 |                         |
        metric-group results       risk-by-risk comparison
                 +------------+------------+
                              |
                 customer release gate -> PASS or BLOCK

Defender posture and incidents -----------------> SOC process
```

The same synthetic cases run against the approved and candidate versions. Quality, tool-process,
safety, and adversarial results remain separate blocking layers. The gate consumes aggregate
records and fixed configuration hashes; detailed prompts and responses stay in Foundry or the
approved security system.

APIM Content Safety, Prompt Shields, authorization, and rate limits remain runtime controls.
Preproduction evaluation and red teaming test the release. Defender inventory, posture findings,
and incidents follow a separate SOC path. None of those signals should be described as the same
control.

Citadel does not provide the `PASS` or `BLOCK` workflow in this session. The thresholds, policy, and
release integration are customer-owned artifacts built on Foundry results.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
| --- | --- | --- | --- |
| Test data | Versioned synthetic cases | Repeatable and safe to retain | New behavior needs a new baseline |
| Test endpoint | Use the same governed APIM path intended for release | Includes gateway, identity, and tool boundaries in the test | Requires stable nonproduction routing |
| Gate | Separate quality, tool, safety, and adversarial layers | Averages cannot hide a failed layer | Several owners maintain explicit floors |
| Red team | Compare fixed versions with the same authorized plan | Shows whether remediation helped | Human review remains required; this is not an inline filter |
| Defender | Keep posture and incidents in the SOC path | Uses existing security ownership and retention | Does not replace release evaluation |
| Records | Payload-free aggregates outside this repository | Supports promotion without retaining content | Detailed investigation stays in Foundry and security systems |

### Architecture guidance

- [Evaluate your AI agents](https://learn.microsoft.com/azure/foundry/observability/how-to/evaluate-agent)
- [AI Red Teaming Agent](https://learn.microsoft.com/azure/foundry/concepts/ai-red-teaming-agent)
- [Protect AI assets using Microsoft Defender](https://learn.microsoft.com/defender-xdr/security-for-ai/defender-security-for-ai)

## Before you start

Name the approved and candidate agent versions, Foundry project, Citadel endpoint, dataset, evaluators, thresholds, attack taxonomy, prohibited actions, judge model, budget, run window, quality owner, security owner, SOC owner, and release store.

### Implementation files

| Type | File | Consumer |
| --- | --- | --- |
| Runtime | `artifacts/eval/evaluation-spec.json` | Foundry evaluation runner |
| Runtime | `artifacts/eval/data/golden-v1.jsonl` | Foundry evaluation runner |
| Deployment | `artifacts/eval/thresholds.yaml` | release gate |
| Deployment | `artifacts/release/release-policy.json` | release gate and Session 07 promotion workflow |
| Runtime | `artifacts/red-team/attack-plan.json` | red-team runner and security owner |
| Runtime | `artifacts/defender/ai-alert-hunt.kql` | SOC analyst |
| Record | `artifacts/operations/disable-and-restore.md` | release and incident owners |
| Record | `artifacts/operations/soc-triage-playbook.md` | SOC analyst and incident commander |

Install the Python packages in `scripts/requirements.txt`. The operator and project identity need the current Foundry role required for evaluation and red teaming at the exact project scope.

## Decisions and stop conditions

Stop when a version is mutable, the dataset contains customer data, evaluator or regional support is unconfirmed, a limited-support tool enters the path, a preview evaluator becomes the only blocking control, the red-team scope is unauthorized, prompts or responses would be retained in the repository, or the Defender route has no owner.

Safety and tool-process failures cannot be overridden. A quality exception needs an owner, reason, compensating control, and expiry, and it cannot trigger automatic promotion.

## Implement

### 1. Prepare the environment

```powershell
python -m pip install -r .\scripts\requirements.txt
$releaseStore = $env:APPROVED_RELEASE_STORE
```

```bash
python -m pip install -r ./scripts/requirements.txt
release_store="${APPROVED_RELEASE_STORE:?Set APPROVED_RELEASE_STORE outside this repository.}"
```

### 2. Evaluate the approved and candidate versions

```powershell
.\scripts\preflight.ps1 -ApprovedSubscriptionId $env:AZURE_SUBSCRIPTION_ID -Phase Baseline
python .\scripts\run-evaluation.py --spec .\artifacts\eval\evaluation-spec.json --target approved --output (Join-Path $releaseStore "approved.json")
python .\scripts\run-evaluation.py --spec .\artifacts\eval\evaluation-spec.json --target candidate --output (Join-Path $releaseStore "candidate.json")
```

```bash
./scripts/preflight.sh --approved-subscription-id "$AZURE_SUBSCRIPTION_ID" --phase baseline
python ./scripts/run-evaluation.py --spec ./artifacts/eval/evaluation-spec.json --target approved --output "$release_store/approved.json"
python ./scripts/run-evaluation.py --spec ./artifacts/eval/evaluation-spec.json --target candidate --output "$release_store/candidate.json"
```

### 3. Run the gate and adversarial comparison

```powershell
python .\scripts\release-gate.py --policy .\artifacts\eval\thresholds.yaml --spec .\artifacts\eval\evaluation-spec.json --dataset .\artifacts\eval\data\golden-v1.jsonl --baseline-result (Join-Path $releaseStore "approved.json") --candidate-result (Join-Path $releaseStore "candidate.json") --evaluated-target candidate --expect pass
python .\scripts\run-red-team.py --plan .\artifacts\red-team\attack-plan.json --output (Join-Path $releaseStore "red-team-candidate.json")
```

```bash
python ./scripts/release-gate.py --policy ./artifacts/eval/thresholds.yaml --spec ./artifacts/eval/evaluation-spec.json --dataset ./artifacts/eval/data/golden-v1.jsonl --baseline-result "$release_store/approved.json" --candidate-result "$release_store/candidate.json" --evaluated-target candidate --expect pass
python ./scripts/run-red-team.py --plan ./artifacts/red-team/attack-plan.json --output "$release_store/red-team-candidate.json"
```

Review the detailed runs in Foundry and the current Defender or SOC record. Keep payloads out of the release store.

## Confirm the result

### Intended path

Run `release-gate.py` with the approved aggregate as both baseline and candidate. It returns `PASS`.

### Blocked or failure path

```powershell
python .\scripts\test_release_gate.py --mode blocked-tool-process
```

```bash
python ./scripts/test_release_gate.py --mode blocked-tool-process
```

The generated tool regression returns `BLOCK`. The red-team comparison also blocks any prohibited-action success or per-risk regression.

### Delivery-owner checkpoint

The quality, security, SOC, and release owners confirm the two outcomes and the payload-free record locations. The candidate stays unpromoted until all blocking layers pass.

## After implementation

The quality owner maintains the dataset and thresholds. The security owner maintains the attack plan. The SOC owner maintains Defender routing and the triage playbook. The release owner controls gate activation. Restore the fixed approved agent version and disable promotion through `disable-and-restore.md`; do not delete Foundry or security records needed by an incident or retention rule.
