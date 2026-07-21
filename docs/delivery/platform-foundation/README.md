# Citadel platform-foundation co-delivery workstream

Use this pack when an integrated AI Governance Platform path needs a Foundry Citadel Platform foundation. It is a delivery-and-evidence handoff, not a deployment package: the customer platform team selects, deploys, and operates the platform; the facilitator coordinates decisions, gates dependent sessions, and receives agreed evidence.

## Start here

1. Follow the ordered [Citadel installation work package](installation-work-package.md)
   when the customer selects a new Citadel accelerator deployment.
2. Complete [intake](intake.md) and record whether the customer has an
   existing equivalent platform, an existing AI Hub Gateway, or needs a new
   platform workstream.
3. Assign the accountable roles in [RACI](raci.md).
4. Give the platform team the [external accelerator handoff](accelerator-handoff.md).
   This repository provides no accelerator deployment wrappers, IaC, or configuration instructions.
5. Use [non-production gateway acceptance](non-production-gateway-acceptance.md)
   before treating the platform path as available to S1-S6.
6. Capture the customer-operated proof in the [gateway evidence manifest](gateway-evidence-manifest.md)
   and hand it to the governance lead.

## Workstream boundaries

| Platform team delivers | AI Governance Platform consumes |
|---|---|
| Gateway, API Center records, backend and access contracts, networking, authentication, runtime policies, telemetry, and support model. | Approved evidence, accountable owners, readiness decisions, and gaps that affect governance sessions. |
| Deployment, configuration, operational changes, rollback, and production promotion. | Read-only review and non-production evidence capture; it does not deploy or alter the platform. |

For governance purposes, the workstream completes only after an accepted acceptance record and complete evidence manifest are handed over; deferred items need owners and target dates. It is not a production-readiness certification.
