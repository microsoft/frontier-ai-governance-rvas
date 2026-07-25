# S6 · Security Runtime

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">Security / SOC</span> <span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & what the customer keeps

The customer leaves with one reviewable runtime artifact: **a redacted gateway
proof for an approved non-production request.**

The proof is a gateway proof manifest that conforms to
[`contracts/gateway-proof.schema.json`](../../contracts/gateway-proof.schema.json).
It contains safe references and a `correlation_id`.

The adapter does not deploy a safety platform or prove a direct Content Safety
call. The customer platform and security owners must match the `correlation_id`
to gateway telemetry before they accept it as enforcement evidence.

Where a customer needs to map defence-in-depth before adoption, the
customer-owned runtime control matrix records the selected identity/network,
gateway, model/agent, and tool boundaries, along with response ownership and
evidence limits. Accept it only alongside the gateway proof.

### What happens next

**Next customer action:** assign any route, policy, telemetry, or correlation
gap to the customer platform or security owner; use the accepted proof only when
later assurance needs it.

### Plain decision and default path

**Decision question:** *Approve, defer, reject, or route the selected gateway,
application, or defense-in-depth runtime enforcement design?* An approval is a
customer decision record, not a production-control approval.

The default is layered Azure/Microsoft enforcement: Microsoft Entra identity and
network controls, an Azure API Management or approved gateway route, supported
Azure AI safety controls where verified, and application or tool controls for
context the gateway cannot see. Use application-only enforcement or another
customer control only when route coverage, latency, capability status, and
evidence ownership make the default unsuitable. Record the exception owner,
reason, compensating control, target date, and re-review trigger. Verify
availability and feature limits before relying on any service.

S6 produces a runtime-control backlog: approve, defer, reject, or route the proof;
remediate route, policy, or telemetry gaps; route safety work; or block
S7/S9/S11 dependencies until correlation is accepted.

Security reviewers may use Microsoft Defender for Cloud and AI security posture
capabilities for broader security and threat context where the customer has them
enabled. See [Defender AI security posture management](https://learn.microsoft.com/en-us/azure/defender-for-cloud/ai-security-posture)
for product context. The S6 artifact is still the gateway proof and reviewed
correlation.

## 2. Prerequisites

- A deployed customer gateway with an approved non-production route and runtime policy.
- A customer operator who can supply authentication without recording it here.
- Customer-owned request and telemetry record locations.
- Named platform and security reviewers who can interpret the telemetry.

## 3. Why this session matters

Runtime evidence must show the path the agent used. S6 records a redacted
request correlation without changing production traffic. A component diagnostic
can troubleshoot part of the stack. Accept gateway-path proof only from the correlated gateway evidence.

## 4. Rollback and handoff

The adapter changes no gateway configuration. If the customer stops the test, it
uses its own approved gateway and evidence-retention processes. The final
customer record contains the approval, deferral, rejection, or routing decision.
Handoff to S7 includes accepted correlation evidence and its limits; handoff to
S9 includes the route, owner, version, and runtime-control exception record.
