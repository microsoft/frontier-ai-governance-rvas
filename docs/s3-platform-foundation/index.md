# S3 · Enterprise Platform & Trust Boundaries

## 1. Outcome & what the customer keeps

The customer leaves with a platform-boundary review and a runtime-assurance handoff.

They leave with:

- A customer-owned review of the enterprise platform boundary, including trust boundaries, owners, evidence expectations, and coverage limits.
- A decision on whether the workload is ready for runtime assurance or needs platform prerequisites first.
- A runtime-assurance handoff that names open gaps, owners, stop conditions, and evidence references.
- Where useful, a customer-owned profile that lists the environment, owners,
  route assumptions, evidence needed, and backlog.

`labs/s3-platform-foundation/` contains blank offline templates only. Keep workload data, credentials, network details, event records, and completed evidence in the customer's approved system.

### Plain decision

**Question:** **Do we approve, defer, reject, or route this platform-readiness
decision?** Default to the Azure/Microsoft platform pattern: Microsoft Foundry,
a customer-adopted Citadel/AI Hub Gateway accelerator where applicable, and
Azure API Management for the AI gateway boundary. An alternative requires architecture-owner rationale,
platform record location, acceptance criterion, and target date. It is not a system
change or production approval.

### What happens next

**Next customer action:** route the selected platform prerequisites to the
customer's architecture, network, identity, security, or release process before
asking runtime assurance to rely on the path.

S3 produces a platform backlog: proceed to runtime assurance, close landing-zone,
AI gateway, API Center, or telemetry prerequisites, or pause for missing
ownership or evidence.

The AI gateway is the trust boundary for runtime access. In this curriculum, that usually means Azure API Management acting as the gateway layer for AI APIs and model access. Platform changes still go through the customer's architecture, network, identity, security, or release processes before S6/S7/S9 rely on the path.

## 2. Prerequisites

- A bounded workload and review question.
- A platform owner, security owner, evidence owner, and decision owner.
- A customer-approved location for records and an agreed stop condition.
- Existing customer-held architecture, network, identity, gateway, or telemetry materials that can be cited by reference, if available.
- A clear statement of what this review can and cannot claim.

This session maps evidence expectations; it does not inspect, validate, or
change the environment.

- **Included:** trust boundaries; private-connectivity assumptions; ingress and egress paths; hybrid dependencies; identity boundaries; telemetry coverage; platform-security ownership; AI gateway boundary; and readiness for runtime assurance.
- **Excluded:** deployment, configuration, network testing, live integration, traffic capture, access changes, data transfer, and acceptance of a control as operating.
- **Evidence rule:** record references, coverage, dates, interpretation, and limits. Do not copy records, payloads, identifiers, diagrams with sensitive detail, or claims into the templates.

A reference architecture can guide the discussion. It is not evidence that the design is deployed or operating.

## 3. Why this session matters

AI requests cross users, apps, gateways, model services, tools, data sources,
and logs. S3 makes each boundary, owner, and evidence expectation explicit
before runtime assurance relies on the path.

Read [S3 Concepts](concepts.md) for the vocabulary and reasoning behind the review.

## 4. Detailed facilitation reference

!!! warning "Evidence-first and report-only"
    No deployment, live integration, or environment access occurs in this
    session. Stop any topic lacking an owner, approved record location, or
    bounded evidence claim.

**Timebox:** 90 minutes. **Roles:** facilitator, platform owner, security owner, evidence owner, and decision owner. Invite network, identity, hybrid-service, and runtime-assurance specialists when they need to interpret a boundary. **To start:** you need a bounded workload, an approved record location, a decision owner, and a stop condition.

**What the customer actually does:** the platform owner maps the enterprise platform and AI gateway boundary, then the decision owner records what is ready, missing, or blocked.

Read [Technical decisions](technical.md) first. It covers platform topology,
network isolation, and gateway options and selection criteria.

1. **Set the review contract** *(10 min)* - state the workload, decision, boundaries, approved records location, and stop condition. The facilitator asks: **"What can this review state, and what remains unverified?"** A missing owner or records location blocks the affected topic.
2. **Map trust, connectivity, and gateway boundaries** *(20 min)* - identify the workload, operator, identity, network, data, service, administration, and AI gateway boundaries. Record expected private-connectivity controls, ingress points, egress destinations, and hybrid dependencies. For the gateway, name Azure API Management when it is the customer route and record what API or model access it is expected to mediate. The facilitator asks: **"Where does authority or data handling change?"** and **"Which topology, network-isolation, or gateway option fits this scope, and what evidence would support that choice later?"**
3. **Review identity and dependency boundaries** *(15 min)* - record the expected caller, workload, operator, and privileged-administration identity boundaries. Note delegated authority, secrets handling, and external or hybrid dependencies. Do not validate credentials or access. A missing accountable owner is a finding, not a reason to guess.
4. **Define telemetry evidence and coverage** *(20 min)* - identify the expected event classes, correlation method, retention decision, reviewer, coverage window, and known blind spots. The facilitator asks: **"Which events should prove this path later?"** and **"Which boundary has no coverage yet?"** Keep "not observed" separate from "not covered." Telemetry references show that evidence is expected. They do not prove a control operated.
5. **Assign platform-security ownership** *(15 min)* - assign each boundary and evidence gap to an accountable platform or security owner. The decision owner records one of `ready_for_runtime_assurance`, `needs_evidence`, `accepted_risk`, `deferred`, or `blocked`, with rationale, selected technical-decision option, owner, and next review.
6. **Hand off to runtime assurance** *(10 min)* - provide the bounded review reference, open gaps, evidence expectations, decision, owners, and stop conditions. Runtime assurance chooses its own authorized observation and validation method. It must not treat this review as proof of operation. Include the technical decision record reference and platform backlog rows for landing-zone, AI gateway, API Center, telemetry, private-connectivity, identity-boundary, or customer-change items required before implementation continues.

## 5. Verification & evidence capture

- [ ] Each stated boundary names its purpose, accountable owner, Azure landing-zone/API Management record, coverage limit, and status.
- [ ] Ingress, egress, private-connectivity assumptions, and hybrid dependencies are stated without claiming they were tested.
- [ ] The AI gateway or Azure API Management boundary is named where it mediates runtime access.
- [ ] Identity and telemetry boundaries separate expected coverage from observed operation.
- [ ] Each gap, empty result, or blocker has an owner, decision, next action, and review date.
- [ ] The runtime-assurance handoff states what still needs authorized observation or validation.

Use the blank `labs/s3-platform-foundation/templates/platform-boundary-review.template.md`, `labs/s3-platform-foundation/templates/runtime-assurance-handoff.template.md`, `labs/s3-platform-foundation/templates/platform-control-profile.template.md`, and `labs/s3-platform-foundation/templates/technical-decision-record.template.md` in the approved records location. Retain only references in the delivery record.

## 6. Change boundary

This session authorizes no change. Network, identity, platform, telemetry, and runtime changes stay in the customer's approved change process, including safety review, rollback, verification, and evidence retention.
