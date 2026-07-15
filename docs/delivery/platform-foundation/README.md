# Citadel platform-foundation co-delivery workstream

Use this pack when a customer wants the integrated RVAS AI Governance path and
needs a Foundry Citadel Platform foundation. It is a delivery and evidence
handoff pack, not a deployment package. The customer platform team selects,
deploys, and operates the platform in its own environment; the facilitator
coordinates the decision, gates the dependent governance sessions, and
receives agreed evidence.

## Start here

1. Follow the ordered [Citadel installation work package](installation-work-package.md)
   when the customer selects a new Citadel accelerator deployment.
2. Complete [intake](intake.md) and record whether the customer has an
   existing equivalent platform, an existing AI Hub Gateway, or needs a new
   platform workstream.
3. Assign the accountable roles in [RACI](raci.md).
4. Give the platform team the [external accelerator handoff](accelerator-handoff.md).
   This repository does not provide deployment wrappers, IaC, or configuration
   instructions for the accelerator.
5. Use [non-production gateway acceptance](non-production-gateway-acceptance.md)
   before treating the gateway as available to S1, S2, S3, S4, or S6.
6. Capture the customer-operated proof in the [gateway evidence manifest](gateway-evidence-manifest.md)
   and hand it to the governance lead.

## Workstream boundaries

| Platform team delivers | RVAS AI Governance consumes |
|---|---|
| Gateway, API Center records, backend and access contracts, networking, authentication, runtime policies, telemetry, and support model. | Approved evidence, accountable owners, readiness decisions, and gaps that affect governance sessions. |
| Deployment, configuration, operational changes, rollback, and production promotion. | Read-only review and non-production evidence capture; it does not deploy or alter the platform. |

The workstream is complete for governance purposes when the acceptance record is
approved, the evidence manifest is complete, and every deferred item has an
owner and target date. It is not a production-readiness certification.
