# Rehearse regional failover for a governed AI service

## Session scope

### What we will do

Rehearse **one approved traffic-selector move** for a governed AI service. Check the primary path
and secondary readiness. Preview the move, get delivery-owner approval, move the named selector,
and check the secondary path. Then restore and check the primary path.

### Why it matters

Operators must be able to move traffic to a regional path and return it safely. This rehearsal
checks that ability for one service.

### Boundaries

The selected service already has both regional paths. Session 12 promotes infrastructure and API
Management policy. This session moves one approved selector through the customer routing control.
It does not deploy infrastructure, change policy, update identity, or review the fleet inventory.

The repository holds the rehearsal contract and runbook. The customer change system holds approval
and the runtime outcome. Foundry, API Management, and Azure Monitor remain authoritative for their
live service state.

## Architecture

### Architecture at a glance

The customer health control checks the active path against the regional contract. It reports agent
version, Entra identity, API Management policy version, endpoint, required trace fields, and
whether sensitive input appeared.

The routing control previews the move to the secondary selector. The delivery owner approves the
move. The wrapper checks the active secondary path, previews the return, restores the primary
selector, and checks the primary path again.

![The team checks the primary path, moves one selector to the secondary path, checks it, then restores and checks the primary path.](../assets/diagrams/regional-failover-sequence.svg)

### Design choices and tradeoffs

| Decision | Chosen approach | Benefit | Cost and limitation |
|---|---|---|---|
| Change boundary | Move one named traffic selector | The rehearsal avoids infrastructure and policy changes | The customer routing control must expose that selector |
| Path check | Compare health output with the regional contract | Operators check all required path values together | The health control must return the documented fields |
| Restore | Preview and approve the return move | The team checks the primary path before closing the rehearsal | The delivery owner approves a second traffic move |

### Architecture guidance

- [Deploy an Azure API Management instance to multiple Azure regions](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-deploy-multi-region)
- [Reliability in Azure API Management](https://learn.microsoft.com/en-us/azure/reliability/reliability-api-management)

## Before you start

Confirm:

| Check | Confirm |
|---|---|
| Regional paths | The governed service has deployed primary and secondary paths. |
| Agent | The platform owner confirms the immutable agent version and Entra identity. |
| Gateway | The gateway owner confirms the API Management policy version and both endpoints. |
| Trace | The primary path reports the expected trace fields. (Sessions 04, 06, 08, 11, and 12.) |
| Change | The approved change record names the exact resource-group scope, both selectors, maintenance window, delivery owner, and restore owner. |
| Controls | The approved PowerShell and Bash health and routing controls accept the documented parameters. The routing owner confirms that `Preview`, `Failover`, and `Restore` change only the named selector. |
| Access | The rehearsal operator has time-bound access for the approved scope. A customer-managed runtime directory exists outside the repository. |

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Runtime | [`artifacts/control-definition.json`](artifacts/control-definition.json) | The Session 13 preflight scripts and regional rehearsal operators |
| Runtime | [`artifacts/regional/region.parameters.json`](artifacts/regional/region.parameters.json) | The Session 13 preflight scripts and rehearsal wrappers |
| Record | [`artifacts/regional/failover-runbook.md`](artifacts/regional/failover-runbook.md) | The service continuity and routing operators |

`control-definition.json` binds the approved scope to the customer controls. The health control
writes temporary JSON outside the repository. The wrappers remove it after each check.
A read-only deployment preview is unsupported because this session does not deploy infrastructure.
The routing control provides the read-only selector preview.

## Decisions and stop conditions

Resolve every `__REQUIRED_*__` value before the rehearsal. The regional contract names each region,
selector, endpoint, and expected path value.

| Gate | Continue when | Stop when |
|---|---|---|
| Scope | The command scope matches the change record and control definition | The scope differs or reaches an unapproved resource group |
| Paths | Primary and secondary selectors differ, and the primary path reports the expected values | A selector is blank or equal, or the primary path fails its check |
| Customer controls | Health and routing controls parse and accept their documented parameters | A control is missing, leaves the repository, or fails its preview |
| Approval | The delivery owner approves the previewed move and the return move | Approval, maintenance window, or restore owner is unavailable |
| Secondary check | The active secondary path matches the regional contract | A required path value or sensitive-input check differs |

**Keep the current selector when any gate is open.** If the secondary check fails after traffic
moves, stop the rehearsal and use the approved restore path.

## Implement

### 1. Complete the rehearsal contract

Set the approved scope, customer-control paths, selectors, expected values, and runbook owners.
Then check the local contract.

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

### 2. Check the active primary path

Use the external runtime directory for temporary health output. Ready preflight checks the
approved primary path before the team previews a move.

```powershell
.\scripts\preflight.ps1 `
  -Phase Ready `
  -ApprovedScope "/subscriptions/<id>/resourceGroups/<name>" `
  -RuntimeDirectory "C:\customer-runtime"
```

```bash
./scripts/preflight.sh \
  --phase ready \
  --approved-scope "/subscriptions/<id>/resourceGroups/<name>" \
  --runtime-directory "/customer/runtime"
```

### 3. Rehearse failover and restore

Freeze infrastructure and API Management policy changes. Review the move preview. Get
delivery-owner approval before starting. The wrapper checks secondary readiness, moves the
selector, checks the secondary path, previews the return, restores the primary selector, and checks
the primary path.

```powershell
.\scripts\rehearse-failover.ps1 `
  -ApprovedScope "/subscriptions/<id>/resourceGroups/<name>" `
  -ChangeRecordId "<customer-change-record>" `
  -RuntimeDirectory "C:\customer-runtime" `
  -Confirm
```

```bash
./scripts/rehearse-failover.sh \
  --approved-scope "/subscriptions/<id>/resourceGroups/<name>" \
  --change-record-id "<customer-change-record>" \
  --runtime-directory "/customer/runtime" \
  --confirm
```

## Confirm the result

Inspect the wrapper output once. It must report matching secondary and restored-primary paths. Each
result must match the regional contract and report `sensitiveInputPresent: false`.

## After implementation

The service continuity owner keeps the runbook current. The platform owner maintains the scope and
regional contract. The routing owner maintains the customer controls.

Keep the secondary path deployed. End temporary access through the customer process. Record the
rehearsal outcome in the approved change record. Session 12 remains the path for infrastructure or
policy promotion.
