# Implementation - Agent fleet governance, multi-region design, and production rehearsal

## Session scope

### What we will do

Locate one governed agent and one MCP server in their native services, then rehearse routing to an
approved secondary deployment. The active-path check compares the immutable agent version, Entra
identity reference, API Management policy version, endpoint, and trace fields with the
source-controlled regional parameters.

### Why it matters

A secondary deployment needs an operator who can identify the service and move traffic through an
approved path. This rehearsal gives the service and delivery owners one visible regional result.

### Boundaries

Foundry Control Plane and Agent 365 store agent inventory. Microsoft Entra stores identity state,
Purview stores policy state, Defender stores security state, Azure Monitor stores telemetry, and
API Management reports the active gateway configuration. The customer repository keeps the files
that preflight and the rehearsal wrappers read: approved scope and script paths in
`control-definition.json`, regional deployment inputs in `region.parameters.json`, and restore
steps in `failover-runbook.md`. It does not keep portal exports, runtime output, approval records,
or one-time rehearsal results.

The regional path uses one Premium (classic) API Management service with an additional location, or
separate regional gateways. Session 14 promotes infrastructure and policy changes. This session
moves the approved traffic selector to an existing secondary path, checks it, and restores the
primary selector when required. It does not move identity or registry objects between regions.

## Architecture

### Architecture at a glance

This rehearsal switches traffic between existing regional deployments. Agent, MCP server, identity,
and inventory records stay in their native services. Azure Resource Manager checks regional
resources and API Management topology. The repository supplies regional parameters and the customer
health and routing interfaces. The customer change system approves the switch and records its
outcome.

First, check the primary and secondary deployments without moving traffic. Then preview the selector
change from the primary path to the secondary path. After the delivery owner approves the move,
change the selector and test the live path. The test must return the expected agent identity
reference, policy version, endpoint, and trace fields. If it does not, restore the primary selector
through the runbook.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations | Revisit when |
|---|---|---|---|---|
| Service state | Inspect live state in native services and Azure Resource Manager. | The operator sees current platform state. | Access is needed in each service. | A service adds or retires an inventory surface. |
| Gateway topology | Use one Premium (classic) multi-region instance or separate regional gateways. | The design can match the approved network boundary. | One instance keeps a primary-region management plane and regional counters. Separate gateways add release work. | Capacity, blast radius, tier support, or network design changes. |
| Restore scope | Move the approved selector and keep the secondary deployment. | The restore is narrow and the standby path stays available. | The secondary capacity remains in service. | The continuity plan changes. |

### Architecture guidance

- [Manage agents at scale in Microsoft Foundry Control Plane](https://learn.microsoft.com/en-us/azure/foundry/control-plane/how-to-manage-agents)
  describes subscription-scoped inventory, access, traces, and fleet metrics.
- [Deploy an Azure API Management instance to multiple Azure regions](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-deploy-multi-region)
  describes regional gateways, routing, and regional counter behavior.
- [Reliability in Azure API Management](https://learn.microsoft.com/en-us/azure/reliability/reliability-api-management)
  identifies the API Management tiers that support multi-region deployment.

## Before you start

1. Complete Sessions 05, 07-14. If your team built the controls outside this series, confirm the
   required state in the table below before starting the rehearsal.
2. Approve the primary and secondary regions for model availability, quota, residency, network
   dependencies, API Management capacity, and the agent's tool path.
3. Confirm that the customer Bicep entrypoint reads
   `artifacts/regional/region.parameters.json` and deploys the complete regional stack.
4. Give the inventory operator Azure Reader at the selected subscription. Make Microsoft Entra
   AI Reader PIM-eligible at tenant scope and activate it only for the reconciliation window.
5. Confirm the Defender Unified RBAC activation state and the permission model that gives the
   security operator read access to the in-scope workload.
6. Give the security operator Purview Data Security AI Viewer and a time-bound Microsoft Entra
   Security Reader activation when Defender Unified RBAC does not cover the workload.
7. Give the preview operator built-in Contributor at the exact regional resource group.
8. Complete the secondary-region deployment through the Session 14 promotion path.
9. Prepare a maintenance window, delivery authority, restore authority, and customer change record.

### If you are starting with Session 15

This table is for teams that built earlier controls outside this series. It lists the state required
before the rehearsal. Complete every row before moving traffic.

| Existing control | What must already work | How the owner confirms it |
|---|---|---|
| 05 Agent baseline | Foundry project, immutable agent version, model alias, and Entra identity | Platform owner invokes the approved version. |
| 07 Gateway | Versioned APIM policy and regional selectors | Gateway owner previews the approved selectors. |
| 08 Inventory | Exact API, agent, and MCP identifiers with owners | Inventory owner locates each native identifier. |
| 09 Tool security | Workload identity, allowed operations, and egress | Tool owner checks the allowed path and blocked unauthorized action. |
| 10 Data governance | Classification, residency, Purview policy ID, and covered agent | Data owner finds the agent in the applicable policy. |
| 11 Evaluation | Threshold policy, approved baseline, and passing candidate | Quality owner sees the release gate pass. |
| 12 Threat defense | Payload-free comparison and Defender route | Security owner checks the prohibited action and Defender signal. |
| 13 Observability | Telemetry definition, workbook, alerts, and smoke interface | Observability owner traces a safe request with separate failures. |
| 14 Promotion | Protected environments, deployment metadata, and previous-release restore | Release owner sees the approval after what-if. |

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Runtime | [`artifacts/control-definition.json`](artifacts/control-definition.json) | The Session 15 preflight scripts and regional rehearsal operators |
| Deployment | [`artifacts/regional/region.parameters.json`](artifacts/regional/region.parameters.json) | The customer Bicep deployment, Session 15 preflight scripts, and routing wrappers |
| Record | [`artifacts/regional/failover-runbook.md`](artifacts/regional/failover-runbook.md) | The service continuity and routing operators |

### Rehearsal scripts

The implementation repository supplies two small adapters for the team's health and routing
systems. The Session 15 wrappers call them in a fixed order: confirm secondary readiness, preview
the selector move, switch traffic after approval, then check the active path. The health-check
script never changes traffic. The routing-control script is the only script that can do so.

### Health-check script interface

The wrapper calls this script twice for the secondary region.

| Mode | When it runs | What it does | Result |
|---|---|---|---|
| `Readiness` | Before routing preview | Checks that the existing secondary deployment can serve the approved synthetic request. | Writes a temporary JSON result with `status: ready`. |
| `Active` | After failover | Sends the same safe check through the active secondary selector. | Writes a temporary JSON result with `status: active`. |

Both modes receive the secondary Azure region and a temporary result path outside the repository.
They return exit code zero only when the check completes. The wrapper then compares the returned
agent version, identity, gateway policy, endpoint, and trace status with `region.parameters.json`.
A failed check stops the rehearsal.

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

The JSON result contains `implementationSession`, `status`, `region`, `agentVersion`,
`agentIdentityId`, `gatewayPolicyVersion`, endpoint, identity, policy, trace statuses, and
`sensitiveInputPresent`. The synthetic request contains no customer data.

### Routing-control script interface

The routing-control script works with the team's existing traffic layer. It receives the approved
selectors, Azure scope, and change-record ID. It accepts no secret or free-form command.

| Mode | When it runs | What it may do | Result |
|---|---|---|---|
| `Preview` | Before delivery-owner approval | Shows the proposed primary-to-secondary selector move. | Makes no traffic change. |
| `Failover` | After the preview and delivery-owner approval | Moves traffic from the named primary selector to the named secondary selector. | Changes only those approved selectors. |
| `Restore` | When an active-path check fails or the delivery owner stops the rehearsal | Returns traffic to the named primary selector. | Changes only the approved selector pair. |

Each mode returns exit code zero only when the preview or routing action completes. Any nonzero exit
stops the wrapper. The wrapper does not call `Restore` automatically. Use the approved restore
procedure when traffic has moved.

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

Use `Preview` before approval. Use `Failover` only after approval. Use `Restore` through the
approved change process when the active-path check does not match the expected values in
`region.parameters.json`.

## Decisions and stop conditions

Resolve every `__REQUIRED_*__` value. Decide the following:

- the exact resource-group scope and the service, platform, security, and delivery owners;
- the primary and secondary regions, gateway topology, routing mode, and distinct selectors;
- the Foundry project, immutable agent version, Entra agent identity, gateway policy version, and
  Application Insights resource used by the active-path check;
- API Management resource IDs, tiers, gateway URLs, backend URLs, and customer-owned routing;
- the Bicep entrypoint plus paired PowerShell and Bash health and routing script paths; and
- the customer change process that records the production decision and result.

Inspect the governed agent in Foundry Control Plane and Agent 365, and inspect its MCP server in the
applicable API inventory. Check Purview and Defender in their native portals. Those services retain
their live state. The repository does not mirror it.

Stop before routing when:

- a sentinel remains, the approved scope differs, or a source path leaves the repository;
- Azure Resource Manager cannot query the Foundry project, Application Insights resource, or API
  Management resource;
- the native services cannot locate the governed agent or MCP server, or either record lacks an
  owner;
- the primary and secondary selectors are missing or equal;
- the secondary region lacks the required model, quota, data, network, or tool path;
- the selected multi-region API Management instance is not Premium (classic);
- separate regional gateways use the same resource ID;
- internal routing lacks customer-owned cross-region routing and DNS;
- the Bicep what-if has an unrelated deletion, replacement, tier change, or network change; or
- either customer script breaks its fixed interface.

**Keep the current selector if any stop condition remains.**

## Implement

### 1. Locate the governed service in native systems

Use Foundry Control Plane and Agent 365 to locate the governed agent. Use the API inventory to
locate its MCP server. Check the relevant Purview and Defender views before the maintenance window.
Do not export portal data, traces, prompts, screenshots, or runtime output to this repository.

### 2. Complete the regional parameters

Complete `regional/region.parameters.json`. The customer Bicep entrypoint reads this file for the
regional deployment inputs used during the rehearsal.

For one multi-region instance, use the same API Management resource ID for both paths and include
the secondary region under `additionalLocations`. Separate gateways use different resource IDs and
receive the same policy revision through Session 14.

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

### 3. Run live checks and deployment preview

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

Ready preflight checks live Azure resources and API Management topology, then runs Bicep what-if.
It does not deploy resources or move traffic.

### 4. Run the regional rehearsal

Freeze infrastructure and gateway policy changes. The service owner checks secondary readiness. The
routing script previews the approved selectors.

![Regional failover sequence from primary health through readiness, preview, selector change, secondary checks, and exact restore](../assets/diagrams/regional-failover-sequence.svg)

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

The wrappers rerun ready preflight before the health check. They reject empty or equal selectors.
The delivery owner confirms the production traffic move after preview. Each wrapper removes its
temporary health result outside the repository. The customer change system records the outcome.

## Confirm the result

Inspect wrapper output and active service telemetry.

**Expected result:** the immutable agent version is active through the secondary selector and
regional backend. The Entra agent identity, API Management policy version, endpoint, and trace
checks match `region.parameters.json`.

Restore the primary selector before another change if a field differs.

## After implementation

Keep `control-definition.json`, `regional/region.parameters.json`, the paired wrappers, and the
Markdown restore runbook. The platform owner updates the control definition and regional parameters
when deployment or script paths change. The service continuity owner updates the runbook before each
scheduled rehearsal and after routing, topology, or restore-process changes.

Azure, Foundry, Agent 365, Entra, Purview, Defender, Azure Monitor, API Management, and the
customer change system remain the systems of record. GitHub protected environments, deployment
metadata, and release metadata continue to record promotion status under Session 14.

Restore the primary selector through the approved routing control in the runbook. Check primary
readiness, preview the selector update, get delivery-owner confirmation, then restore only the
documented selector. The secondary region remains deployed.
