# Implement the agent fleet multi-region rehearsal

## Session scope

### What we will do

Locate one governed agent and one MCP server in their native services. Then move the approved
traffic selector to an existing secondary deployment and check the immutable agent version, Entra
identity reference, API Management policy version, endpoint, and trace fields.

### Why it matters

A secondary deployment is useful when an operator can identify the service, move traffic through
an approved path, recognize a bad result, and restore the primary path.

### Boundaries

Foundry Control Plane and Agent 365 hold agent inventory. Entra holds identity state, Purview holds
policy state, Defender holds security state, Azure Monitor holds telemetry, and API Management
reports gateway configuration. The customer change system records approval and the rehearsal
result.

The repository keeps the approved scope and script paths in `control-definition.json`, expected
regional values in `region.parameters.json`, and restore steps in `failover-runbook.md`. Session 13
promotes infrastructure and policy changes. This session moves one approved selector. It does not
move identity or registry objects, deploy a partial gateway definition, or prove fleet-wide
lifecycle enforcement.

## Architecture

### Architecture at a glance

The primary and secondary deployments already exist. Preflight checks their Azure resources, API
Management topology, customer script interfaces, and Bicep what-if without moving traffic. The
customer health script checks readiness. The routing script previews and then changes the selector
after delivery-owner approval. A second health check compares the active path with the regional
parameters.

![The team checks readiness, moves one named selector to the secondary region, verifies it, and restores the primary selector.](../assets/diagrams/regional-failover-sequence.svg)

### Design choices and tradeoffs

| Decision | Chosen approach | Tradeoff |
|---|---|---|
| Service state | Inspect live Azure and native service state | Operators need access to every source system |
| Gateway topology | One Premium (classic) multi-region service or separate regional gateways | One service keeps a primary-region management plane; separate gateways add release work |
| Restore | Move only the approved selector and keep the secondary deployment | Standby capacity remains in service |

### Architecture guidance

- [Manage agents at scale in Microsoft Foundry Control Plane](https://learn.microsoft.com/en-us/azure/foundry/control-plane/how-to-manage-agents)
- [Deploy an Azure API Management instance to multiple Azure regions](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-deploy-multi-region)
- [Reliability in Azure API Management](https://learn.microsoft.com/en-us/azure/reliability/reliability-api-management)

## Before you start

Complete Sessions 04 and 06-13. If your team built those controls elsewhere, confirm these states
before the rehearsal:

| Control | Required state | Owner check |
|---|---|---|
| 04 Agent baseline | Foundry project, immutable agent version, model alias, and Entra identity | Platform owner invokes the approved version |
| 07 Gateway | Versioned API Management policy and regional selectors | Gateway owner previews the selectors |
| 08 Inventory | Exact API, agent, and MCP identifiers with owners | Inventory owner locates every native identifier |
| 09 Tool security | Workload identity, allowed operations, and egress | Tool owner checks the allowed path and blocked unauthorized action |
| 05 Agent 365 data controls | Classification, residency, Purview policy ID, and covered agent | Data owner finds the agent in the policy |
| 10 Evaluation | Threshold policy, approved baseline, and passing candidate | Quality owner sees the release gate pass |
| 11 Threat defense | Payload-free comparison and Defender route | Security owner checks the prohibited action and Defender signal |
| 12 Observability | Telemetry definition, workbook, alerts, and smoke interface | Observability owner traces a safe request with separate failures |
| 13 Promotion | Protected environments, deployment metadata, and previous-release restore | Release owner sees approval after what-if |

Also confirm:

- Both regions meet the model, quota, residency, data, network, capacity, and tool-path requirements.
- The customer Bicep entrypoint deploys the complete regional stack. The secondary deployment is ready.
- The customer-approved temporary-access process gives the inventory operator Azure Reader at
  subscription scope and the privileged Entra AI Reader role at tenant scope for the rehearsal.
- The security owner has recorded the Defender Unified RBAC activation state. The security operator
  has Purview Data Security AI Viewer and, when Unified RBAC does not cover the workload, a
  time-bound Entra Security Reader activation at tenant scope.
- The preview operator has built-in Contributor at the exact regional resource group.
- The maintenance window, change record, delivery authority, and restore authority are ready.

The customer-approved access process ends temporary access after the rehearsal. Agent Registry
Administrator may add a missing registry record. Agent ID Administrator is required only for an
identity change. Return either task to pre-work.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Runtime | [`artifacts/control-definition.json`](artifacts/control-definition.json) | The Session 14 preflight scripts and regional rehearsal operators |
| Deployment | [`artifacts/regional/region.parameters.json`](artifacts/regional/region.parameters.json) | The customer Bicep deployment, Session 14 preflight scripts, and routing wrappers |
| Record | [`artifacts/regional/failover-runbook.md`](artifacts/regional/failover-runbook.md) | The service continuity and routing operators |

The wrappers call customer-owned paired PowerShell and Bash scripts. The health script accepts
`Readiness` or `Active`, the Azure region, and a temporary result path outside the repository. Its
JSON result reports the session marker, status, region, agent version, identity, policy version,
endpoint checks, trace checks, and `sensitiveInputPresent`.

```powershell
.\customer-regional-health.ps1 `
  -Mode Readiness|Active `
  -Region <azure-region> `
  -ResultPath <customer-managed-runtime-path>
```
```bash
./customer-regional-health.sh \
  --mode readiness|active \
  --region <azure-region> \
  --result-path <customer-managed-runtime-path>
```

The routing script accepts `Preview`, `Failover`, or `Restore`. It changes only the named selector
pair in the approved scope and accepts no secret or free-form command.

```powershell
.\customer-routing-control.ps1 `
  -Mode Preview|Failover|Restore `
  -FromSelector <selector-from-regional-parameters> `
  -ToSelector <selector-from-regional-parameters> `
  -ApprovedScope "/subscriptions/<id>/resourceGroups/<name>" `
  -ChangeRecordId <customer-change-record>
```
```bash
./customer-routing-control.sh \
  --mode preview|failover|restore \
  --from-selector <selector-from-regional-parameters> \
  --to-selector <selector-from-regional-parameters> \
  --approved-scope "/subscriptions/<id>/resourceGroups/<name>" \
  --change-record-id <customer-change-record>
```

## Decisions and stop conditions

Resolve every `__REQUIRED_*__` value. Name the exact Azure scope and the platform, service,
security, and delivery owners. Record both regions, the gateway pattern, routing mode, distinct
selectors, Foundry project, immutable agent version, Entra identity, policy version, Application
Insights resource, gateway and backend URLs, customer Bicep entrypoint, paired customer scripts,
and change process.

For one multi-region service, use the same API Management resource ID for both paths and Premium
(classic). Put the secondary region in `additionalLocations`. Separate gateways use different
resource IDs and receive the same policy revision through Session 13. Internal mode needs
customer-owned cross-region routing and DNS.

Stop before routing when:

- a required value remains, the Azure scope differs, or a script path leaves the repository;
- Azure Resource Manager cannot query the Foundry project, Application Insights, or API Management;
- the agent or MCP server is missing, duplicated, ownerless, or version-ambiguous;
- selectors are missing or equal, or the regions do not meet the approved requirements;
- the API Management tier or topology is unsupported;
- Bicep what-if shows an unrelated deletion, replacement, tier change, or network change; or
- a customer script breaks its documented interface.

**Keep the current selector while any stop condition remains.**

## Implement

### 1. Reconcile the governed service

Locate the agent in Foundry Control Plane and Agent 365, its MCP server in the API inventory, and
the applicable Purview and Defender state. Do not copy portal exports, prompts, traces,
screenshots, or runtime output into the repository.

### 2. Complete the inputs and check decisions

Complete `artifacts/control-definition.json`, `artifacts/regional/region.parameters.json`, and the
restore runbook.

```powershell
.\scripts\preflight.ps1 `
  -Phase Decisions `
  -ApprovedScope "/subscriptions/<id>/resourceGroups/<name>"
```
```bash
./scripts/preflight.sh \
  --phase decisions \
  --approved-scope "/subscriptions/<id>/resourceGroups/<name>"
```

### 3. Check live readiness and preview deployment changes

```powershell
.\scripts\preflight.ps1 `
  -Phase Ready `
  -ApprovedScope "/subscriptions/<id>/resourceGroups/<name>"
```
```bash
./scripts/preflight.sh \
  --phase ready \
  --approved-scope "/subscriptions/<id>/resourceGroups/<name>"
```

Ready preflight checks the live resources and gateway topology, then runs Bicep what-if.

### 4. Run the rehearsal

Freeze infrastructure and gateway policy changes. The wrapper reruns ready preflight, checks
secondary readiness, previews the selector move, pauses for delivery-owner approval, moves traffic,
and checks the active path.

```powershell
.\scripts\rehearse-failover.ps1 `
  -ApprovedScope "/subscriptions/<id>/resourceGroups/<name>" `
  -ChangeRecordId "<customer-change-record>" `
  -RuntimeDirectory "C:\customer-runtime"
```
```bash
./scripts/rehearse-failover.sh \
  --approved-scope "/subscriptions/<id>/resourceGroups/<name>" \
  --change-record-id "<customer-change-record>" \
  --runtime-directory "/customer/runtime"
```

The temporary health result stays outside the repository and is removed by the wrapper. The
customer change system records the outcome.

## Confirm the result

Inspect the wrapper output and active telemetry once. The secondary path must report the expected
immutable agent version, Entra identity reference, API Management policy version, endpoint, and
trace fields from `region.parameters.json`. `sensitiveInputPresent` must be false.

If any field differs, stop other changes and restore the primary selector.

## After implementation

The platform owner maintains the control definition and regional parameters. The service continuity
owner maintains the runbook and paired rehearsal wrappers. Native Microsoft services remain
authoritative for live inventory, identity, policy, security, telemetry, and gateway state. The
customer change system keeps approval and runtime results.

To restore, check primary readiness, preview the secondary-to-primary selector move, get
delivery-owner confirmation, and call the routing control in `Restore` mode. Restore only the
documented selector pair. Then check the active primary path. Keep the secondary deployment.

End temporary human access through the customer-approved access process after the rehearsal.
