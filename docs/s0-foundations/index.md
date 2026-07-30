# S0 · Technical Intake & Feasibility Triage

!!! info "Freshness"
    Last reviewed: 2026-07-30 · Verify current Microsoft service availability,
    customer authority, and evidence locations before delivery.

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Architecture owner</span>

!!! abstract "What is at stake"
    Downstream sessions fail when the team cannot name the actual workload,
    Microsoft surface, owner, or evidence source. S0 turns a broad AI idea into
    one inspectable technical path, or stops before everyone wastes time.

## 1. Inspect one candidate workload

Start with one candidate AI workload, agent, or platform capability. Do not
start with a governance program, a portfolio category, or a generic policy.

Open or identify the customer-owned source systems that describe the candidate:

- Azure subscription, resource group, or landing-zone reference.
- Microsoft Foundry project, Copilot Studio environment, Microsoft 365
  extension record, custom Azure app, or prototype location.
- Entra app registration, service principal, managed identity, workload
  identity, or delegated-user path.
- Data source, retrieval path, prompt/context boundary, tool/API path, and
  output/logging path.
- API gateway, API Center record, connector inventory, or MCP/tool registry
  where one exists.
- Application Insights, Log Analytics, Azure Monitor, Defender, Sentinel,
  Purview, or customer record system that can hold safe evidence references.

The goal is to classify the candidate as ready for a technical session,
blocked, unsupported, or still too vague to inspect.

### Plain decision

**Can this candidate be routed to a specific technical session with a named
owner, source system, evidence location, and first inspection target?**

If the answer is no, stop and fix the intake gap. Do not send the team to S1,
S2, S3, or later sessions with only a concept name and a sponsor.

## 2. Run the 30-minute triage

| Step | What to open or identify | Result to capture |
|---|---|---|
| Scope | Candidate name, environment, lifecycle state, intended users, production/non-production status. | Inspectable / too broad / production-only / owner missing. |
| Microsoft surface | Foundry, Copilot Studio, M365 extensibility, custom Azure app, APIM, API Center, Purview, Defender, Monitor, or other surface. | Primary surface and portal link or safe record reference. |
| Identity path | User identity, app/agent identity, managed identity, service principal, delegated/OBO route, or unknown. | Ready for S1 / identity blocked / not applicable. |
| Data path | Source, retrieval/context, prompt, tool response, model output, log/evidence path. | Ready for S2 / data path blocked / minimization unknown. |
| Platform path | Caller, ingress, gateway/app route, model/backend, tool/API, telemetry destination. | Ready for S3 or S6 / platform route blocked. |
| Tool/API path | Tool, connector, API, operation, permission, quota, logging, withdrawal owner. | Ready for S5 / tool owner missing / unmanaged direct call. |
| Evaluation and red-team need | Candidate change, scenario set, test target, release question, risk category. | Ready for S7/S8 / scenario blocked / target unsupported. |
| Operating path | Alert, query, cost/quota, support queue, run owner, review cadence. | Ready for S10 / operating signal missing. |

## 3. Choose the next technical route

| If the first gap is... | Route to | Accepted when... |
|---|---|---|
| No accountable owner or evidence location | Customer sponsor | Owner and approved records location are named. |
| Identity or permission path unclear | S1 Identity | The app/agent/user identity and permission source can be inspected. |
| Data exposure, Purview, retention, or eDiscovery unclear | S2 Data & Compliance | The source -> prompt/retrieval/tool/output/log path can be traced. |
| Platform route, network, gateway, telemetry, or catalog unclear | S3 Platform Foundation | The request path and Microsoft surface can be opened or referenced. |
| Agent build path or authority unclear | S4 Agent Engineering | The candidate has an action boundary and possible build route. |
| Tool, connector, API, or MCP admission unclear | S5 Tool/API Governance | The operation, auth mode, owner, and withdrawal path can be inspected. |
| Runtime control evidence unclear | S6 Runtime Security | A non-production request path and correlation field can be tested or reviewed. |
| Evaluation readiness unclear | S7 Evaluation | A candidate change, scenario set, and threshold owner exist. |
| Red-team readiness unclear | S8 Red Teaming | A non-production target and written authorization path exist. |
| Inventory or ownership mismatch | S9 Control Plane | The candidate can be reconciled across source systems. |
| Monitoring, cost, alert, or support unclear | S10 Operate & Measure | A telemetry or cost source can be queried. |
| Change lifecycle unclear | S11 LLMOps | Baseline and candidate release references exist. |
| Cross-workload priority unclear | S12 Portfolio | Source records exist for more than one workload. |

## 4. Hard stops

- No named owner who can open the relevant customer system.
- No approved customer records location for safe evidence references.
- Candidate scope is only an idea, slogan, or portfolio theme.
- The only available target is production and the customer has not approved a
  read-only review.
- The review would require copying prompts, outputs, telemetry, exports,
  endpoints, secrets, tenant identifiers, or customer records into this repo.
- The requested decision is legal, funding, procurement, or production approval
  rather than technical triage.

## 5. Change boundary

S0 changes no tenant setting, product configuration, access grant, gateway,
policy, deployment, model route, data source, evidence store, budget, or
production state. It only routes one candidate to the next technical action, or
blocks it until the customer can make it inspectable.

Use [Technical decisions](technical.md) for the intake runbook, result states,
and lab fields.
