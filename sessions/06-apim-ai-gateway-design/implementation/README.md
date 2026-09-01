# Azure API Management AI gateway design

## Session scope

### What we will do

Create a **source-controlled APIM gateway design record** for one target AI workload. Record the
approved scope, backend type, ingress pattern, identities, network path, APIM tier and instance,
Content Safety decision, telemetry boundary, runtime controls, restore approach, owners, and
readiness gaps.

The session produces `gateway-design-record.json`. Run preflight to check that the record is
complete and that its readiness state is inspectable. This session does not create or change Azure
resources.

### Why it matters

The implementation team needs a decision record before it configures an AI gateway. Capturing
owners and gaps early avoids discovering an unready backend, identity path, or network path during
deployment.

### Boundaries

This design applies to the approved nonproduction workload named in the record. The repository is
authoritative for the design record. Azure API Management and connected Azure services are
authoritative for live service state.

The session can plan any approved AI backend. Session 07 implements the Foundry Agent Service
policy-assistant variant and requires a target agent endpoint. Another backend needs an approved
implementation variant. Do not record live endpoint URLs, keys, tokens, prompts, responses,
tenant IDs, or subscription IDs in this repository.

## Architecture

### Architecture at a glance

The workload caller reaches APIM through the recorded ingress path. APIM validates the client
identity, applies the request, limit, safety, and routing decisions, then uses the recorded backend
identity to call the selected backend. Content Safety and telemetry are separate boundaries. The
API product, identity, network, safety, and operations owners each own part of the path.

`gateway-design-record.json` hands the design to implementation. Session 07 preflight uses it for
the actual backend, identity, and network checks before a deployment proposal. The implementation
process changes APIM.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations | Revisit when |
| --- | --- | --- | --- | --- |
| Backend | Record the type and approved endpoint reference, not a runtime URL | Keeps the design usable without storing a sensitive coordinate | The implementation team must resolve the endpoint through its approved secret or configuration path | A backend or endpoint contract changes |
| Ingress and identity | Record the caller credential separately from APIM's backend identity | Keeps caller authorization separate from backend access | Two owners may need to coordinate an incident or rotation | The client type or backend authorization model changes |
| Network | Record inbound path, backend path, and private DNS state | Makes connectivity assumptions reviewable before deployment | The record cannot prove live reachability | A private endpoint, DNS zone, or egress path changes |
| Safety and telemetry | Record the Content Safety path and body-capture policy before policy authoring | Sets the data boundary | The service policy still needs deployment and live validation | Safety thresholds, data classification, or logging policy changes |
| Restore | Record the approved rollback or disable path | Gives operators a bounded response when the route misbehaves | The exact command belongs to the implementation variant | Routing, product, or backend topology changes |

### Architecture guidance

- [AI gateway capabilities in Azure API Management](https://learn.microsoft.com/en-us/azure/api-management/genai-gateway-capabilities)
- [Authenticate and Authorize to LLM APIs](https://learn.microsoft.com/en-us/azure/api-management/api-management-authenticate-authorize-ai-apis)
- [LLM content safety policy](https://learn.microsoft.com/en-us/azure/api-management/llm-content-safety-policy)

## Before you start

The approved nonproduction scope and change reference name the delivery owner. That owner confirms
the record is available for this design session. The owners of the target API product, caller
identity, APIM identity, network route, safety policy, and telemetry must join or provide a
documented decision.

Identify the target backend type and an approved **endpoint reference**, such as a secret-store
record or service configuration name. Do not put the endpoint in the record. Bring the current APIM
tier and instance name. If it does not exist, record the service request and its owner as a
readiness gap.

### Implementation files

| Type | File | Consumer |
| --- | --- | --- |
| Record | [`artifacts/gateway-design-record.json`](artifacts/gateway-design-record.json) | The gateway implementation owner and Session 07 preflight process |

Run the preflight script after completing the record. It reads local JSON and makes no Azure call.
A **read-only deployment preview is unsupported** because this design session does not deploy a
resource.

```powershell
.\scripts\preflight.ps1 -DesignRecordPath .\artifacts\gateway-design-record.json
```

```bash
./scripts/preflight.sh --design-record-path artifacts/gateway-design-record.json
```

## Decisions and stop conditions

Resolve every `__REQUIRED_*__` value in `gateway-design-record.json`. Use an endpoint reference,
not a live endpoint. Keep real values in the customer-approved configuration or secret system.

Set `recordStatus` to `ready-for-implementation` when no readiness-gap entry has `open` status.
Use `approved-with-gaps` when a named owner still has work to do. Every gap needs a short
description, owner, and resolution action. If no gap remains, add a `not-applicable` entry so the
reader can distinguish that decision from an empty list.

Stop the design handoff when any of these conditions applies:

- The target workload, APIM instance or request, backend type, or nonproduction scope is unknown.
- The ingress or backend identity lacks a named owner and a documented authorization path.
- The network owner cannot state the inbound route, backend route, or private DNS state.
- The Content Safety, telemetry body-capture, request, token-limit, safety, routing, or restore
  decision is missing.
- A readiness gap lacks an owner or resolution action.
- The record contains a live endpoint, credential, token, prompt, response, tenant ID, or
  subscription ID.

## Implement

### 1. Record the gateway boundary

Complete the scope, APIM, backend, ingress, identity, and network sections. State whether the APIM
instance exists or whether a named delivery owner must request it. The backend can be a Foundry
Agent Service endpoint, another approved Azure AI endpoint, or another approved backend. Name the
implementation variant required for that backend type.

### 2. Record the runtime decisions and owners

Complete the Content Safety, telemetry, and control sections. State the proposed request size,
token-limit method, safety policy, routing behavior, and restore path. Name the API product,
identity, network, safety, operations, and delivery owners.

### 3. Record readiness and run preflight

Write each actual gap under `readinessGaps`, set the correct record status, then run the paired
preflight command. The check rejects sentinels, empty decisions, invalid gap statuses, and a record
marked ready while a gap remains open.

## Confirm the result

Run preflight against the completed record. Inspect `recordStatus` and `readinessGaps`.

**Expected result:** the script reports a complete, inspectable design without changing Azure
resources. A `ready-for-implementation` record has no open gap. An `approved-with-gaps` record
shows the remaining owner and resolution action.

## After implementation

Keep `gateway-design-record.json` with the target workload's approved change records. The gateway
implementation owner updates it through the usual source-control review path when the backend,
identity, network, APIM tier, safety decision, telemetry boundary, limits, routing, restore path,
or ownership changes.

The Session 07 implementation owner uses this record before proposing the Foundry Agent Service
build. Restore or remove a deployed gateway through that approved implementation variant's change
path. This design record has no Azure resource to remove.
