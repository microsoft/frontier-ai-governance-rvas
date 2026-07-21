# S3 · Enterprise Platform & Trust Boundaries: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-17 · Named Microsoft platform capabilities,
    including Azure AI Landing Zones, Microsoft Foundry, Azure API Management,
    Azure API Center, private endpoints, and VNet integration, change over time;
    verify current status, availability, licensing, and regional limitations
    before delivery. See the [Platform technical guide](../reference/platform-technical-guide.md).

S3 decides platform topology, trust-boundary/network isolation, and gateway or
registry placement. It leaves a trust-boundary decision and platform work list;
it does not deploy anything. Later implementation follows the customer's
architecture, security, network, and change processes.

![S3 illustrative Azure platform pattern: callers cross an optional gateway trust boundary to orchestration or hosted execution, private data access, identity, and observability layers. The pattern identifies decisions and evidence expectations; it does not claim a deployed topology.](../assets/diagrams/s3-gateway-trust-boundary.svg)

## Decision 1: Platform topology / landing zone

Choose against the existing Azure footprint, target scale, shared versus
isolated tenancy, operational ownership, and whether a new platform foundation
is justified for the bounded workload.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Azure AI Landing Zones / Foundry Citadel-style greenfield platform** | The organization needs a new shared AI platform foundation, clear separation of duties, and room to standardize gateway, identity, network, and telemetry patterns | Highest platform build and ownership effort; verify current status, availability, and fit before using named accelerator or Foundry/Citadel patterns | Record the target platform owner, trust boundaries, operating model, and work list before any build starts |
| **Integrate into an existing landing zone** | The customer already has a governed Azure estate with network, identity, logging, and change processes that can absorb the AI workload | Existing standards may not yet cover model access, tool access, or AI gateway patterns; verify current platform capability | Record the deltas the existing platform must close and route them to the owning architecture/security process |
| **Per-team platforms** | Teams need isolated experimentation or have distinct data, residency, or operational constraints that make shared tenancy unsuitable | Can fragment controls, telemetry, gateways, and ownership if not coordinated | Record what remains centralized, what is team-owned, and how S12 portfolio visibility will reconcile the split |

## Decision 2: Trust boundary & network isolation

Choose against data sensitivity, compliance/residency expectations, required
connectivity to on-premises systems or data stores, and the evidence later
needed to show the intended path was actually used.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Public endpoints behind a gateway only** | Data sensitivity and policy allow public service endpoints, while runtime access is mediated through a governed gateway route | Simpler topology, but public exposure assumptions and gateway use still need later evidence | Record the gateway boundary, allowed ingress/egress assumptions, and the S6 evidence needed to prove traffic followed the route |
| **Private endpoints / VNet integration** | Sensitive data, tenant policy, or service connectivity requires private service access for the workload path | Service coverage and configuration support vary; verify current status, availability, and limitations for each named capability | Record which boundaries are expected to be private, the platform owner, and the evidence needed before treating the route as operating |
| **Hub-and-spoke private networking** | The workload depends on shared connectivity, on-premises systems, central inspection, or multiple data stores | More routing, ownership, and troubleshooting complexity across teams | Record the hub, spoke, hybrid, and inspection owners plus the handoff needed for runtime assurance |

### Azure implementation track: make the intended path reviewable

**Control chain to decide.** Map the caller, selected gateway or ingress route,
orchestration/hosted execution, data and tool dependencies, identity boundary,
and telemetry destination. Private Endpoints and private DNS zones can be
selected for data, model, registry, or observability access; they are options
within the chosen topology, not a universal topology or an automatic control.

**Failure modes to test in the customer design.** A gateway shown in a diagram
may not mediate the actual route; a public fallback can defeat a private-path
assumption; DNS can resolve differently across linked networks; hybrid routing
can add an unowned dependency; and a telemetry destination can exist without
covering the selected path.

**Evidence and record.** For each boundary, record the expected purpose,
ingress/egress assumption, private-connectivity/DNS expectation if selected,
hybrid dependency, accountable owner, evidence source, blind spot, and the
later session that can review the path. Architecture diagrams and verbal
confirmation remain design inputs, not operating evidence.

**Backlog sequence.** Resolve ownership and topology assumptions first, then
route network, DNS, gateway, identity, and telemetry changes to the appropriate
customer process. S5 records published interfaces, S6 reviews an approved
non-production gateway path, and S11 owns operating coverage; none of those
steps is authorized by this S3 review.

## Decision 3: Governance hub / gateway placement

Choose against the need for centralized routing, safety enforcement, telemetry,
policy ownership, and a registry system of record for APIs, model access, and
runtime contracts.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **AI Hub Gateway (Azure API Management) + Azure API Center registry** | The customer needs a dedicated AI gateway boundary plus a registry for API/model access contracts and ownership | Requires platform ownership and current-product verification for Azure API Management AI gateway and Azure API Center capabilities | Record gateway owner, registry owner, routing scope, safety/telemetry expectations, and backlog items |
| **Existing API management estate** | A governed API management platform already handles routing, authentication, policy, logging, and operational ownership | Existing controls may not yet fit AI/model traffic, tool calls, or registry needs; verify current feature coverage | Record the AI-specific gaps and the customer process that will extend the existing estate |
| **No central gateway yet** | Early discovery, low-authority prototype, or isolated team platform where central routing is not approved or not justified | Leaves centralized enforcement, telemetry, and registry coverage absent or fragmented | Record the gap explicitly, define compensating controls or stop conditions, and route the decision to S12 portfolio planning |

## Decisions made & adoption progress

S3 ties the platform part of the **S0 maturity baseline** to the **S12 portfolio**
by turning topology, network-isolation, and gateway choices into a customer-owned
platform backlog rather than a deployment claim.

| Adoption stage | What "done" looks like at S3 |
|---|---|
| **Decided** | A platform topology, trust-boundary/network-isolation approach, and governance hub/gateway placement are selected with rationale, assumptions, owner, and verified-status caveat |
| **Backlogged** | Landing-zone, private-connectivity, gateway, registry, telemetry, identity-boundary, and runtime-proof prerequisites are routed to platform/security/change owners |
| **In adoption** | The platform team implements outside this session; governance records the decision and S6/S9/S12 later reconcile evidence, catalog, and portfolio status |

Capture the selected options, alternatives, assumptions, and owners in the
technical decision record
(`labs/s3-platform-foundation/templates/technical-decision-record.template.md`);
the platform team owns deployment; governance records the decision.

## Related references

- [S3 Concepts](concepts.md): trust boundaries, gateway boundary, private-connectivity assumptions, telemetry coverage, and platform backlog.
- [Platform technical guide](../reference/platform-technical-guide.md): platform layers, gateway/network placement, and current-status checks.
- [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md): Azure Policy, API Management, API Center, and related governance references.
- [Governance capability guide](../reference/governance-capability-guide.md): capability availability and governance context to verify before delivery.
