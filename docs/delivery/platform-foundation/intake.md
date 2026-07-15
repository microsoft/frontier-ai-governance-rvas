# Platform-foundation intake

Complete this intake with the customer platform owner before scheduling a
gateway-dependent validation session. Record answers in the customer's
approved work-tracking system; do not put credentials, secrets, or customer
data in this repository.

## Deployment decision

| Question | Record |
|---|---|
| Which path applies? | Existing equivalent platform, existing AI Hub Gateway/Citadel Governance Hub, or new accelerator deployment. |
| What is in scope? | Non-production environment, subscriptions, regions, application/use-case routes, and intended backend services. |
| Who accepts the platform? | Named platform owner and delegated APIM, network, security-runtime, and application owners. |
| What is the source version? | Accelerator repository, branch or release, immutable commit, deployment/change record, and date selected. |
| What is deferred? | Production rollout, unsupported capabilities, additional routes, or controls not needed for the initial governance evidence. |

An equivalent platform may be used. Record how it supplies the same evidence
instead of relabeling it as Citadel.

## Readiness intake

The platform team confirms the applicable accelerator prerequisites and records
their result for the selected environment:

- approved subscription, region, service quota, resource-provider, and cost
  ownership;
- landing-zone, network, DNS, private-connectivity, and egress decisions;
- APIM and API Center ownership; approved backend services and their
  connection/access contracts;
- application client identity, gateway authentication method, and non-production
  test caller;
- Content Safety/runtime-policy availability and policy owner where S3 runtime
  evidence is required;
- Log Analytics/Application Insights/SIEM destination, retention, access, and
  correlation approach;
- deployment pipeline, change record, rollback owner, support/on-call route,
  and production-promotion authority.

Mark a missing prerequisite as **blocked** with an owner and target date. Do
not substitute an unapproved direct backend call for a gateway acceptance test.

## Session gates

| Milestone | Governance use |
|---|---|
| Platform path and owners recorded | S0 can establish the ownership and readiness backlog. |
| Non-production gateway acceptance passed | S1 authentication evidence, S2 gateway data-protection evidence, and S3 gateway runtime evidence may start. |
| Gateway telemetry and contracts handed over | S4/S5 may correlate evaluation or test results; S6 may reconcile exposure records. |
| Deferred items owned | S6 records the remaining platform gaps; it does not deploy the platform. |
