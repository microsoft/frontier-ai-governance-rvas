# S3 · Enterprise Platform & Trust Boundaries

!!! info "Freshness"
    Last reviewed: 2026-07-27 · Verify current capability availability, platform assumptions, and customer evidence before delivery.

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

## 4. Change boundary

This session authorizes no change. Network, identity, platform, telemetry, and runtime changes stay in the customer's approved change process, including safety review, rollback, verification, and evidence retention.
