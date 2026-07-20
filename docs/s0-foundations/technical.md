# S0 · Foundations & Governance Operating Model — Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-17 · Framework and tooling availability varies by tenant, region, license, and product maturity; verify current status in the [Governance capability guide](../reference/governance-capability-guide.md).

S0 decides who owns AI-agent governance, which framework anchors the baseline,
and where decisions and evidence live. These menus record a concrete adoption
step; they do not recommend deployment or change the environment.

## Decision 1 — What governance operating model owns AI-agent decisions?

Choose against organization size, number of agent-building teams, risk appetite, and the balance between delivery speed and central control. The deciding test is whether the model can name accountable owners, resolve exceptions, and scale without turning governance into theatre.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Centralized governance board** | Small number of high-risk initiatives where one body can review exceptions and priorities | Can slow delivery and become a bottleneck as teams scale | Clear accountability and escalation; record cadence, authority, and exception route |
| **Federated hub-and-spoke** (central policy + domain/product owners) | Multiple business or product teams build agents under shared policy | Requires disciplined handoffs between central governance and local owners | Balances consistency with speed; record policy owner, domain owners, and decision rights |
| **Embedded in-team governance** | Mature product teams already own risk, security, and release decisions | Inconsistent standards if there is no central baseline or review route | Fastest local execution; needs a common baseline, evidence expectation, and escalation path |
| **Hybrid model** | Mixed maturity, mixed risk, or transition from pilot to portfolio | More roles to explain and maintain | Lets high-risk choices escalate centrally while lower-risk work stays with accountable teams |

## Decision 2 — Which control framework anchors the S0 baseline?

The framework should match regulatory exposure, existing certifications, audit or customer expectations, and the language leaders already use. Frameworks can layer; the deciding test is which baseline gives a defensible starting point without pretending S0 has deployed a control.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **NIST AI RMF** | The customer wants a broad governance vocabulary for Govern, Map, Measure, and Manage | Not a certifiable management-system standard by itself | Strong fit for this curriculum; sessions map to NIST functions in the AI governance reference map |
| **ISO/IEC 42001** | The customer needs an AI management-system structure or certification-aligned evidence | Heavier process and audit discipline than a pilot may need | Creates a management-system backlog; record scope, owners, and evidence requirements |
| **Microsoft Responsible AI Standard** | The customer wants Microsoft-aligned principles, impact assessment language, and responsible AI controls | Must be adapted to the customer's own policies and obligations | Useful as a control-language layer; verify current Microsoft guidance before relying on details |
| **EU AI Act risk-tiering** | The customer has EU exposure or needs risk classification for prohibited, high-risk, or lower-risk systems | Legal interpretation and dates vary; do not embed volatile implementation detail | Drives risk-tier routing and legal/compliance ownership; verify current applicability |
| **Existing internal framework** | The customer already has enterprise risk, security, model risk, or SDLC governance | May miss agent-specific identity, data, tool-use, or evidence gaps | Best for adoption if extended deliberately; record which S0/S1-S12 gaps it must cover |

## Decision 3 — What system of record holds governance decisions and evidence?

The record location should fit auditability, scale, retention, and who will maintain it after the workshop. The deciding test is whether the customer can retrieve the decision, alternatives, rationale, owner, and evidence reference without copying sensitive records into the kit.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Dedicated control / decision register** | Governance, risk, or architecture teams already maintain formal decision and control records | Needs disciplined upkeep and integration with delivery backlog | Strong audit trail; record owner, retention, review cadence, and S12 portfolio reference |
| **Purview, Foundry, or API Center records** | The customer wants governance evidence near catalog, model, data, or API assets | Product coverage and feature availability vary; verify current status before delivery | Useful evidence linkage, but S0 still records the customer-owned decision and owner |
| **Spreadsheets or shared documents** | Early pilot, low scale, or no approved GRC tooling yet | Easy to fragment, overwrite, or lose context as the portfolio grows | Acceptable interim record if owner, location, retention, and migration trigger are explicit |
| **Existing enterprise work-management system** | Decisions must route into security, architecture, compliance, or release workflows | Work items can hide rationale unless the template is enforced | Connects decision to adoption backlog; record alternatives and rationale, not just tasks |

## Decisions made & adoption progress

What S0 leaves behind is a baseline maturity assessment and prioritized roadmap that feed the S12 portfolio view.

| Adoption stage | What "done" looks like at S0 |
|---|---|
| **Decided** | The operating model, baseline framework, and record location are chosen with owner, rationale, and known caveats |
| **Backlogged** | Gaps from the baseline are routed to the next session, capability owner, and customer change process |
| **In adoption** | The customer uses the chosen record path and roadmap; S12 compares progress with the baseline |

Capture the choice, alternatives, and rationale in the technical decision record (`labs/s0-foundations/templates/technical-decision-record.template.md`).

## Related references

- [S0 Concepts](concepts.md) — operating model, maturity baseline, risk routing, and customer-owned evidence.
- [Governance capability guide](../reference/governance-capability-guide.md) — capability and availability context to verify before delivery.
- [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md) — NIST mapping, policy-control-visibility-proof lens, and official sources.
