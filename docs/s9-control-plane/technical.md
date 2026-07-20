# S9 · Control Plane, Catalog & Lifecycle — Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-17 · Availability and naming for Azure API Center,
    Microsoft Foundry catalog capabilities, Agent 365, Microsoft Entra Agent ID,
    and related platform features can change by tenant, region, and licensing.
    Verify current status, coverage, and limitations before delivery. See the
    [Governance capability guide](../reference/governance-capability-guide.md).

Choose the authoritative record, reconciliation method, and lifecycle rule for
one bounded population. S9 records the choices; customer processes implement
any resulting change.

## Decision 1 — What is the authoritative catalog / system of record?

Choose the record the customer will treat as authoritative for the declared
population, based on existing authority, estate coverage, integration effort,
and stewardship ownership.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Azure API Center** (where current availability and scope are verified) | APIs and tools are already governed there, and API ownership is the strongest source of truth | May not cover every agent, model, identity, or lifecycle state without additional records | Strong tool/API inventory anchor; record excluded agents, models, and lifecycle fields explicitly |
| **Microsoft Foundry catalog / project records** (where current feature status is verified) | Foundry is already the engineering control point for agents, models, tools, traces, and evaluations | Coverage depends on platform adoption and current feature availability; may not include non-Foundry estates | Good fit for Foundry-owned agents; record cross-platform gaps and customer steward ownership |
| **Customer control-register** (spreadsheet or approved record using the S9 schema) | The estate spans multiple platforms or no platform catalog is authoritative yet | Manual stewardship burden; only as current as the customer's review cadence | Valid authoritative record when owner, scope, fields, and review cadence are explicit |
| **Federated authoritative view** (platform catalogs plus control-register) | Different systems are authoritative for different fields or estates | Requires field-level ownership and reconciliation rules; ambiguity can create drift | Strongest for mixed estates if each field has an owner, source, and conflict-resolution rule |

## Decision 2 — How is recorded control state reconciled against platform reality?

The deciding factors are portfolio size, drift risk, staffing capacity, and how
quickly a stale catalog could create governance risk.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Manual periodic review** | Small or low-change population with clear owners and low drift risk | Relies on calendar discipline and human review; drift can persist between reviews | Record cadence, reviewer, evidence references, exceptions, and next review date |
| **Evidence-driven reconciliation** | Moderate portfolio where approved exports, reports, or evidence packs can be compared offline | Still requires evidence preparation and interpretation; no live enforcement | Creates a repeatable reconciliation backbone for S11 operating cadence and S12 portfolio views |
| **Automated inventory sync** (after current platform/API status is verified) | Large or fast-changing portfolio where drift risk exceeds manual capacity | Engineering work, permissions, failure handling, and data-quality ownership are required | Backlog as a separate implementation; S9 records scope, source authority, owner, and validation route |
| **Exception-triggered review** | Material changes, incidents, audit requests, or lifecycle transitions drive review timing | Not enough by itself for steady-state assurance | Use only alongside a baseline cadence; record trigger, approver, and closure validation |

## Decision 3 — How are change, versioning, and retirement governed?

Decide what counts as material change, who owns version/deprecation decisions,
and how retirement is evidenced before an entry is treated as closed.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Material-change threshold** | Authority, tool use, data handling, model behavior, ownership, or operating scope can change meaningfully | Requires judgment and consistent interpretation by owners | Retriggers the right assurance path; record trigger, decision owner, and review reference |
| **Version and deprecation ownership** | Agents, tools, models, evaluators, prompts, or datasets have release versions or dependency impact | Version records can drift from catalog and evidence unless stewarded | Name the version owner, deprecation notice path, affected dependencies, and S11/S12 handoff |
| **Retirement / decommission path** | Suspended, retired, withdrawn, or decommissioned entries need accountable closure | Closure is not proven by a label or blank entry | Record permitted destination, closure owner, validation reference, recurrence check, and retained record |
| **Portfolio dependency mapping** | Shared tools, models, APIs, or evaluators affect multiple agents or business owners | Mapping can be incomplete until estates mature | Prevents silent downstream impact; unresolved dependencies remain backlog, not approval |

## Decisions made & adoption progress

S9 turns the S0 control-plane baseline into an authoritative catalog and
lifecycle cadence, then feeds the S11 operating rhythm and S12 portfolio view as
the reconciliation backbone.

| Adoption stage | What "done" looks like at S9 |
|---|---|
| **Decided** | The authoritative record, reconciliation method and cadence, and material-change/versioning/retirement rules are chosen for the bounded population |
| **Backlogged** | Catalog gaps, source-of-truth conflicts, sync work, lifecycle fixes, and evidence routes are owned with dates, validation references, and S11/S12 dependencies |
| **In adoption** | Stewards are maintaining the record outside the session; reconciliation findings feed S11 cadence and S12 portfolio risk review |

Record the choice, alternatives considered, and adoption stage in
`labs/s9-control-plane/templates/technical-decision-record.template.md`.

## Related references

- [S9 Concepts](concepts.md) — catalog stewardship, lifecycle trail, reconciliation, and closeout accountability.
- [Governance capability guide](../reference/governance-capability-guide.md) — current capability and availability context to verify before delivery.
- [Platform technical guide](../reference/platform-technical-guide.md) — platform governance surfaces and customer-owned implementation boundaries.
- [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md) — official reference sources for catalog, identity, audit, and lifecycle evidence.
