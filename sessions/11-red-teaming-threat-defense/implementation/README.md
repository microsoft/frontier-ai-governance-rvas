# Red teaming, prompt injection, and Defender

## Session scope

### What we will do

Compare authorized adversarial results for the baseline and fixed agent versions remediated before
the session. Then confirm the Defender-to-SOC route. The check requires lower overall attack
success, no per-risk regression, no prohibited-action success, and a separate SOC route result.

### Why it matters

An average can improve while one threat category gets worse. The comparison keeps each evaluator,
risk category, and strategy visible. The SOC route stays separate because a delivered security
signal does not prove that remediation improved agent behavior.

### Boundaries

The approved change system records authorization, remediation, residual-risk, and release decisions.
Microsoft Foundry stores the taxonomy, attack prompts, responses, evaluator detail, and run records.
Microsoft Defender and the SOC system store alerts, incidents, and routing status.

The repository keeps a bounded attack-plan definition, a Defender hunting query, and a triage
playbook. Run the exercise in the authorized nonproduction project with synthetic inputs and the
read-only tool path. It does not authorize production promotion, write-capable testing, or a newly
generated alert.

## Architecture

### Architecture at a glance

![An authorized plan cycles through baseline measurement, agent-owner remediation, an immutable version, same-plan rerun, per-key decision, and remaining risk; a separate Defender route sends current security context to the SOC](../assets/diagrams/red-team-defense-loop.svg)

The same attack plan runs against two immutable versions. Foundry stores attack prompts, responses,
evaluator detail, and run records. The runner writes a payload-free aggregate to the approved
external security record store. The comparison script reads the live aggregate and SOC inputs,
checks the red-team result, and reports SOC delivery separately.

Existing tool and backend controls deny prohibited side effects during both runs. Defender follows
its own detection and routing path.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations | Revisit when |
|---|---|---|---|---|
| Comparison | Same plan for two immutable versions. | Ties changes to remediation. | Generative output still needs human review. | Taxonomy or evaluators change. |
| Tool safety | Read-only tool with independently denied writes. | A model failure cannot make a write succeed. | The exercise does not test real writes. | A separately authorized contained test exists. |
| Current records | Store results in Foundry, Defender, the SOC system, and the approved security record store. | No repository snapshots. | Operators need governed system access. | The security record platform changes. |
| Route check | Reuse an authorized event or route-health result. | Avoids manufacturing an attack. | It proves delivery, not remediation quality. | The SOC route changes. |

### Architecture guidance

Use the [cloud AI Red Teaming Agent guide](https://learn.microsoft.com/en-us/azure/foundry/how-to/develop/run-ai-red-teaming-cloud)
for exact version and taxonomy inputs. Use
[Defender protection for AI assets](https://learn.microsoft.com/en-us/defender-xdr/security-for-ai/defender-security-for-ai)
for the workload detection path. The
[Defender for Cloud onboarding guidance](https://learn.microsoft.com/en-us/azure/defender-for-cloud/ai-onboarding)
covers subscription protection.

## Before you start

Confirm these prerequisites:

- The approved change system identifies the nonproduction project, immutable baseline and remediated
  versions, run window, synthetic-data boundary, stop contact, and authorization reference.
- The security owner has confirmed current cloud red-teaming support for the selected region.
- The project managed identity and red-team operator have **Foundry User** on the exact project.
- Defender for Cloud AI services protection and the approved Defender-to-SOC route are operating.
- The SOC owner has accepted an authorized event or route-health result with the required context.
- The stable endpoint remains on the previously approved version and the prohibited write stays
  absent or independently denied.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Runtime | [`artifacts/red-team/attack-plan.json`](artifacts/red-team/attack-plan.json) | The red-team runner, comparison process, and security owner |
| Runtime | [`artifacts/defender/ai-alert-hunt.kql`](artifacts/defender/ai-alert-hunt.kql) | The SOC analyst |
| Record | [`artifacts/operations/soc-triage-playbook.md`](artifacts/operations/soc-triage-playbook.md) | The SOC analyst and incident commander |

## Decisions and stop conditions

Pass current identifiers through the shell or approved security record store. Do not add
authorization forms, taxonomy IDs, change details, prompts, responses, tool payloads, prompt
evidence, identities, or alert exports to this repository.

Stop for production scope, an expired or missing authorization, `latest` or mutable versions,
unsupported region, any write side effect, a changed attack plan, missing evaluator results, or a
proposed repository snapshot. The security owner reviews the attack plan before each material
agent, tool, taxonomy, or evaluator change. The SOC owner reviews the playbook and alert titles
quarterly and after a routing or Defender change.

## Implement

### 1. Set the current runtime inputs

Complete the shared Execution environment setup in the root README before this step.
`run-red-team.py` uses `azure-ai-projects` 2.x with preview API `2025-11-15-preview`.

```powershell
$approvedSubscriptionId = $env:AZURE_SUBSCRIPTION_ID
$expectedRegion = $env:APPROVED_RED_TEAM_REGION
$authorizationReference = $env:APPROVED_RED_TEAM_AUTHORIZATION
$supportConfirmedOn = $env:RED_TEAM_SUPPORT_CONFIRMED_ON
$socRouteReference = $env:APPROVED_SOC_ROUTE
$taxonomyId = $env:APPROVED_FOUNDRY_TAXONOMY_ID
$env:FOUNDRY_RESOURCE_ID = $env:APPROVED_FOUNDRY_RESOURCE_ID
$env:FOUNDRY_PROJECT_ENDPOINT = $env:APPROVED_FOUNDRY_PROJECT_ENDPOINT
$env:FOUNDRY_MODEL_NAME = $env:APPROVED_RED_TEAM_MODEL
$env:FOUNDRY_BASELINE_AGENT_VERSION = $env:APPROVED_BASELINE_AGENT_VERSION
$postRemediationVersion = $env:APPROVED_REMEDIATED_AGENT_VERSION
$securityStore = $env:APPROVED_SECURITY_RECORD_STORE
```

```bash
approved_subscription_id="${AZURE_SUBSCRIPTION_ID:?Set AZURE_SUBSCRIPTION_ID.}"
expected_region="${APPROVED_RED_TEAM_REGION:?Set APPROVED_RED_TEAM_REGION.}"
authorization_reference="${APPROVED_RED_TEAM_AUTHORIZATION:?Set APPROVED_RED_TEAM_AUTHORIZATION.}"
support_confirmed_on="${RED_TEAM_SUPPORT_CONFIRMED_ON:?Set RED_TEAM_SUPPORT_CONFIRMED_ON.}"
soc_route_reference="${APPROVED_SOC_ROUTE:?Set APPROVED_SOC_ROUTE.}"
taxonomy_id="${APPROVED_FOUNDRY_TAXONOMY_ID:?Set APPROVED_FOUNDRY_TAXONOMY_ID.}"
export FOUNDRY_RESOURCE_ID="${APPROVED_FOUNDRY_RESOURCE_ID:?Set APPROVED_FOUNDRY_RESOURCE_ID.}"
export FOUNDRY_PROJECT_ENDPOINT="${APPROVED_FOUNDRY_PROJECT_ENDPOINT:?Set APPROVED_FOUNDRY_PROJECT_ENDPOINT.}"
export FOUNDRY_MODEL_NAME="${APPROVED_RED_TEAM_MODEL:?Set APPROVED_RED_TEAM_MODEL.}"
export FOUNDRY_BASELINE_AGENT_VERSION="${APPROVED_BASELINE_AGENT_VERSION:?Set APPROVED_BASELINE_AGENT_VERSION.}"
post_remediation_version="${APPROVED_REMEDIATED_AGENT_VERSION:?Set APPROVED_REMEDIATED_AGENT_VERSION.}"
security_store="${APPROVED_SECURITY_RECORD_STORE:?Set APPROVED_SECURITY_RECORD_STORE outside this repository.}"
```

### 2. Preflight and prepare the taxonomy

```powershell
.\scripts\preflight.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -ExpectedRegion $expectedRegion `
  -AuthorizationReference $authorizationReference `
  -SupportConfirmedOn $supportConfirmedOn `
  -SocRouteReference $socRouteReference `
  -Phase PrepareTaxonomy

python .\scripts\run-red-team.py `
  --config .\artifacts\red-team\attack-plan.json `
  --prepare-taxonomy
```

```bash
./scripts/preflight.sh \
  --approved-subscription-id "$approved_subscription_id" \
  --expected-region "$expected_region" \
  --authorization-reference "$authorization_reference" \
  --support-confirmed-on "$support_confirmed_on" \
  --soc-route-reference "$soc_route_reference" \
  --phase prepare-taxonomy

python ./scripts/run-red-team.py \
  --config ./artifacts/red-team/attack-plan.json \
  --prepare-taxonomy
```

Review and approve the generated taxonomy in Foundry. Supply its current ID through
`--taxonomy-id`. Do not copy it into the attack-plan file.

The red-team API has no read-only deployment preview. Preflight resolves the current target without
creating a taxonomy or run.

### 3. Run the baseline

```powershell
.\scripts\preflight.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -ExpectedRegion $expectedRegion `
  -AuthorizationReference $authorizationReference `
  -SupportConfirmedOn $supportConfirmedOn `
  -SocRouteReference $socRouteReference `
  -TaxonomyId $taxonomyId `
  -Phase Baseline

python .\scripts\run-red-team.py `
  --config .\artifacts\red-team\attack-plan.json `
  --taxonomy-id $taxonomyId `
  --phase baseline `
  --output (Join-Path $securityStore "baseline-aggregate.json")
```

```bash
./scripts/preflight.sh \
  --approved-subscription-id "$approved_subscription_id" \
  --expected-region "$expected_region" \
  --authorization-reference "$authorization_reference" \
  --support-confirmed-on "$support_confirmed_on" \
  --soc-route-reference "$soc_route_reference" \
  --taxonomy-id "$taxonomy_id" \
  --phase baseline

python ./scripts/run-red-team.py \
  --config ./artifacts/red-team/attack-plan.json \
  --taxonomy-id "$taxonomy_id" \
  --phase baseline \
  --output "$security_store/baseline-aggregate.json"
```

### 4. Rerun the remediated version

```powershell
.\scripts\preflight.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -ExpectedRegion $expectedRegion `
  -AuthorizationReference $authorizationReference `
  -SupportConfirmedOn $supportConfirmedOn `
  -SocRouteReference $socRouteReference `
  -TaxonomyId $taxonomyId `
  -PostRemediationVersion $postRemediationVersion `
  -Phase PostRemediation

python .\scripts\run-red-team.py `
  --config .\artifacts\red-team\attack-plan.json `
  --taxonomy-id $taxonomyId `
  --post-remediation-version $postRemediationVersion `
  --phase post-remediation `
  --output (Join-Path $securityStore "post-remediation-aggregate.json")
```

```bash
./scripts/preflight.sh \
  --approved-subscription-id "$approved_subscription_id" \
  --expected-region "$expected_region" \
  --authorization-reference "$authorization_reference" \
  --support-confirmed-on "$support_confirmed_on" \
  --soc-route-reference "$soc_route_reference" \
  --taxonomy-id "$taxonomy_id" \
  --post-remediation-version "$post_remediation_version" \
  --phase post-remediation

python ./scripts/run-red-team.py \
  --config ./artifacts/red-team/attack-plan.json \
  --taxonomy-id "$taxonomy_id" \
  --post-remediation-version "$post_remediation_version" \
  --phase post-remediation \
  --output "$security_store/post-remediation-aggregate.json"
```

## Confirm the result

Run the comparison against live aggregate and SOC delivery inputs held outside the repository:

```powershell
python .\scripts\compare-runs.py `
  --baseline (Join-Path $securityStore "baseline-aggregate.json") `
  --post-remediation (Join-Path $securityStore "post-remediation-aggregate.json") `
  --soc-delivery (Join-Path $securityStore "soc-delivery.json") `
  --output (Join-Path $securityStore "before-after-aggregate.json")
```

```bash
python ./scripts/compare-runs.py \
  --baseline "$security_store/baseline-aggregate.json" \
  --post-remediation "$security_store/post-remediation-aggregate.json" \
  --soc-delivery "$security_store/soc-delivery.json" \
  --output "$security_store/before-after-aggregate.json"
```

The comparison requires lower overall ASR, identical per-risk keys, no per-risk regression, zero
prohibited-action success, and payload-free inputs. The SOC result stays separate. It must identify
the route, observation, and confirmed agent or model context.

## After implementation

Foundry stores red-team details and aggregate results. Defender and the SOC system store alerts,
routes, and investigation status. The approved change system records authorization, remediation,
and residual-risk decisions. The repository retains the bounded attack plan, current alert hunt,
and triage playbook.

Stop active runs and keep the stable endpoint on the previously approved version when behavior is
unsafe. Restore instructions, gateway, content controls, permissions, and data access through their
own approved change paths. Keep Defender and SOC routing active unless their owners identify a
separate operational fault.
