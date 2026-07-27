# S5 Tool & API Governance Runbook

Use this runbook to guide the required lab path. The customer inspects its own Microsoft records, records safe references in its approved system, and decides whether the scoped tool/API is admissible, bounded, reviewable, and withdrawable.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, tenant-change details, runtime proof, enforcement evidence, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Entry gate

Confirm the customer has a bounded API, tool, connector, MCP publication, allow-list request, or consuming-agent need; a decision owner, tool owner, API platform owner, identity owner, consuming-agent owner, evidence owner, receiving owners, and an approved records location. If any are missing, stop the decision and create a blocker backlog item.

## Required review flow

1. **Define the tool/API scenario.** Record the business purpose, consumer, operation boundary, side effects, environment, and approved records location.
2. **Classify the route.** Choose the smallest accurate route:
   - `api-center-apim`: cataloged API with API Center metadata, APIM route or exception, auth, rate/quotas, audit, and consumer review;
   - `allow-list`: bounded pilot tool with explicit operations, consumers, expiry, revocation owner, and review date;
   - `connector`: SaaS or platform connector requiring connector governance, permission model, admin consent, DLP/data boundary, and withdrawal path;
   - `mcp-publication`: shared MCP server/tool requiring schema, version, auth scopes, rate/quotas, audit, revocation, and catalog state;
   - `s10-referral`: runtime guardrail, enforcement, monitoring, or gateway proof belongs to S10/runtime/security owner;
   - `reject-unsafe-tool`: unsafe authority, unbounded scope, missing owner, no audit, or no revocation path.
3. **Record owner and version.** Name the tool owner, API platform owner, identity owner, consumer owner, version, lifecycle state, change owner, review cadence, expiry date, and deprecation/withdrawal trigger.
4. **Set operation boundary.** Record read/write/admin operations, data classes, side effects, human approval need, over-scope behavior, and blocked operations.
5. **Review auth scopes.** Record Entra app/JWT audience, scopes/roles, consent owner, credential/secret owner, least-privilege gap, and token/permission review owner.
6. **Review rate and quotas.** Record rate limit, quota, throttling behavior, abuse owner, exception path, and consumer impact.
7. **Review audit and investigation.** Record audit route, correlation field, log/evidence owner, investigation path, retention/export expectation, and blind spots. Do not export telemetry or claim runtime proof.
8. **Run revocation and withdrawal checks.** Record disable path, permission removal, allow-list removal, connector consent withdrawal, MCP unpublish, credential rotation, consumer notification, rollback owner, and evidence/investigation references.
9. **Complete consumer review.** Record consuming agent/app owner, accepted operations, over-scope handling, review result, next review trigger, and release/backlog impact.
10. **Set downstream prerequisites.** Route S3 platform-route gaps, S6/S10 runtime/enforcement referrals, S7 tool behavior or evaluation evidence, and S9 catalog/control-plane lifecycle. If a prerequisite is missing, create a blocker.
11. **Set decision state.** Use one state:
    - `approve`: route, owner, version, auth, rate/quotas, audit, revocation, consumer review, evidence reference, acceptance test, and handoff are complete;
    - `defer`: a gap has a named owner and target date;
    - `reject`: unsafe authority, unbounded scope, unsupported operation, no owner, no auditability, or no feasible withdrawal path;
    - `route`: another owner must decide first;
    - `withdraw`: an admitted tool no longer has owner, version, approved consumer, acceptable scope, audit route, or revocation path;
    - `blocked`: access, ownership, record location, version, auth, rate/quota, audit, revocation, consumer review, or scope clarity prevents a decision.
12. **Create blocker and backlog path.** For each gap, record blocker category, receiving owner, acceptance test, target date, evidence location, consumer/release impact, and next review trigger.
13. **Handoff.** Send the completed decision record and backlog references to API platform, tool, identity, connector, consuming-agent, security/compliance, runtime/S10, evaluation, and control-plane/catalog owners as applicable.

## Blocker categories

Use the smallest accurate category: `owner-missing`, `record-location-missing`, `version-missing`, `api-center-record-missing`, `apim-route-missing`, `allow-list-unbounded`, `connector-governance-missing`, `mcp-publication-incomplete`, `auth-scope-unclear`, `least-privilege-gap`, `rate-quota-missing`, `audit-route-missing`, `correlation-path-missing`, `revocation-path-missing`, `withdrawal-path-missing`, `consumer-review-missing`, `unsafe-write-authority`, `s10-referral-needed`, `s9-catalog-missing`, or `scope-unclear`.

## Completion check

The lab is complete when the customer-owned decision record includes the route, owner, version, operation boundary, auth scopes, rate/quotas, audit, revocation and withdrawal checks, consumer review, downstream handoffs, decision state, blockers or backlog, and receiving handoff. Store final evidence only in the customer-approved records system.
