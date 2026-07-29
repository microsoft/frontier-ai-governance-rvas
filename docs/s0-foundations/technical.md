# S0 · Foundations & Governance Operating Model: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Start from Microsoft Cloud Adoption Framework for AI, Well-Architected Framework for AI, and AI Center of Excellence guidance. Verify current Microsoft guidance, tenant tooling, region, and license status before delivery.

## Microsoft default

Default to a customer AI governance forum anchored in Microsoft Cloud Adoption Framework for AI, Well-Architected Framework for AI, and AI Center of Excellence guidance. S0 records the operating model, baseline framework, and system of record that every later session uses.

## Decision tree

1. **If a customer governance forum already owns AI risk**, use it and add agent-specific decision rights.
2. **If ownership is split across business, security, data, and platform teams**, use a federated hub-and-spoke model with escalation to the central forum.
3. **If only product teams own decisions today**, keep embedded ownership but require the shared S0 baseline and exception route.
4. **If no owner can approve, defer, reject, or route**, block the roadmap item until a sponsor names the forum and record location.

| Decision | Microsoft default | Choose an exception only when |
|---|---|---|
| Operating model | CAF/AI Center of Excellence-aligned forum plus domain owners | A regulated internal forum is already authoritative and can carry S0-S13 fields |
| Baseline framework | CAF for AI + Well-Architected AI, mapped to NIST AI RMF or ISO/IEC 42001 as needed | Legal/compliance requires a different primary framework |
| Record location | Customer governance/control register with links to Purview, Foundry, API Center, or Azure work items | No approved register exists; use a temporary owned document with a migration trigger |

## Decision-rights and RACI matrix

| Role | Accountable | Responsible | Consulted | Informed |
|---|---|---|---|---|
| Executive sponsor | Risk appetite, funding, escalation, forum authority. | Names accountable forum. | Portfolio, legal/risk, business owners. | Roadmap outcomes. |
| Governance lead | S0 baseline, decision route, exception process, forum cadence. | Runs forum and backlog routing. | Security, data, platform, operations. | All session owners. |
| Product/business owner | Purpose, value hypothesis, user scope, accepted business risk. | Maintains use-case ownership. | Governance and release owners. | Support and operations. |
| Platform owner | Platform capability, environment readiness, gateway/telemetry route. | Routes platform, tool/API, runtime, and operating work. | Identity, security, operations. | Product and governance. |
| Identity owner | Identity sponsorship, authority model, lifecycle route. | Routes identity decisions. | Security, platform, app owner. | Control-plane steward. |
| Data/compliance owner | Data classification, privacy, retention, investigation route. | Routes data decisions. | Legal/risk, platform, product. | Release owner. |
| Security/runtime owner | Runtime controls, red-team route, incident handoff. | Routes runtime, adversarial-testing, and in-process decisions. | SOC, legal/risk, platform. | Portfolio forum. |
| Release/change owner | DEV/PRE/PRO gate, rollback, production approval process. | Routes agent-admission, evaluation, and LLMOps decisions. | Operations, product, security. | Governance forum. |
| Operations owner | Monitoring, alerts, support, FinOps, operating review. | Routes operating decisions. | Platform, product, finance. | Portfolio forum. |
| Portfolio owner | Roadmap, prioritization, re-baseline trigger. | Routes portfolio decisions. | Sponsor, finance, governance. | Session owners. |

## Exception template

| Field | Required record |
|---|---|
| Exception reference | Customer record ID, scope, affected workload/session, request date. |
| Risk statement | What requirement is not met and what could happen. |
| Compensating control | Temporary equivalent control, owner, coverage limit, evidence reference. |
| Owner and approver | Request owner, risk owner, approval authority, escalation route. |
| Duration | Review date, expiry date, renewal criteria, stop condition. |
| Evidence | Customer-held evidence reference, reviewer, retention owner. |
| Impact | Release/roadmap impact, affected domains, portfolio visibility. |
| Closure | Remediation target, validation reference, closure owner, recurrence check. |

## Escalation cadence and SLA model

| Trigger | Escalation target | Suggested SLA record |
|---|---|---|
| Missing accountable owner | Governance lead and executive sponsor. | Owner named or item blocked by next forum. |
| Expired exception | Risk owner and governance forum. | Review before expiry; escalation if no disposition. |
| Production-impacting blocker | Release/change owner and sponsor. | Same-cycle decision or hold recorded. |
| Cross-domain conflict | Governance forum with affected domain owners. | Conflict owner and target decision date. |
| High-risk red-team or runtime finding | Security/SOC/risk and release owner. | Immediate route per customer severity model. |
| Portfolio dependency concentration | Portfolio forum and baseline owner. | Re-baseline trigger and roadmap decision date. |

## Evidence-system field model

Later sessions should use the same minimum fields so decisions can roll up
without copying sensitive evidence.

| Field | Purpose |
|---|---|
| Decision reference | Stable customer record ID or link placeholder. |
| Scope | Workload, environment, session, version, included/excluded boundaries. |
| Owner | Accountable owner, evidence owner, receiving owner. |
| Decision state | Approve, defer, reject, route, blocked, accepted risk, or session-specific state. |
| Evidence reference | Customer-held record, not raw evidence. |
| Evidence limits | Freshness, coverage, unsupported areas, assumptions. |
| Exception | Exception reference, expiry, compensating control, approver. |
| Backlog | Gap, owner, acceptance test, target date, release/roadmap impact. |
| Review trigger | Date, material change, incident, release stage, or portfolio re-baseline signal. |

## Platform checks

Inspect these customer-owned records; store only safe references in this repo.

| Check | Microsoft product/control record |
|---|---|
| Governance owner and cadence | AI Center of Excellence charter, architecture review board, risk committee, or customer GRC record |
| Baseline maturity | CAF for AI assessment, Well-Architected AI review notes, NIST/ISO mapping, S0 roadmap |
| Decision register | Customer GRC/work-management record, Purview/Foundry/API Center links, retention owner |
| Exception handling | Exception record with reason, equivalent control, owner, evidence location, target date, and review trigger |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Operating model | one forum can approve, defer, reject, or route each AI-agent decision and has named domain owners | Governance sponsor |
| Baseline framework | the chosen Microsoft baseline and any regulatory overlay are mapped to ownership gaps | Governance/risk owner |
| Evidence record | decisions include alternatives, rationale, owner, evidence location, target date, and review trigger | Records/GRC owner |
| Roadmap | each foundation gap is assigned to a capability owner or customer process | Portfolio owner |

## Boundary note

S0 creates a governance baseline and backlog only; customer change, production approval, and sensitive evidence stay in customer systems.

## Related references

- [S0 Concepts](concepts.md): operating model, maturity baseline, risk routing, and customer-owned evidence.
- [Governance capability guide](../reference/governance-capability-guide.md): capability and availability context.
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md): required playbook shape.
- [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md): official reference sources.
