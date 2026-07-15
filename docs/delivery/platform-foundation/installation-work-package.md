# Citadel installation work package

Use this facilitator-led work package when a customer selects Citadel for the
integrated governance path. The customer platform team owns all deployment and
privileged operations. Complete each step in order and record outcomes in the
customer's approved work-tracking and change systems.

## 1. Confirm the decision and inputs

With the platform owner, record:

- the selected path: existing equivalent platform, existing Citadel/AI Hub
  Gateway, or new Citadel accelerator deployment;
- the non-production scope, intended gateway routes, approved backends, and
  evidence consumers;
- named platform, APIM/API Center, network, security-runtime, backend, and
  application owners; and
- the selected accelerator repository, branch or release, immutable commit,
  product status, and customer change record.

Use the [platform-foundation intake](intake.md) as the record. An equivalent
platform is acceptable when it can provide the required evidence; do not
relabel it as Citadel.

## 2. Establish prerequisites and ownership

The platform team confirms the applicable accelerator prerequisites before
deployment, including landing-zone and network decisions, service readiness,
approved backends and access contracts, authentication, telemetry, deployment
pipeline, rollback, support, and promotion authority.

Use the [RACI](raci.md) to assign accountable people. Record each unavailable
prerequisite as blocked with an owner and target date; S0 may proceed with that
readiness backlog, but gateway-dependent validation waits.

## 3. Deploy the external accelerator

The platform team deploys and configures the selected accelerator through the
customer's approved change process. The current [AI Hub Gateway deployment
guidance](https://github.com/Azure-Samples/ai-hub-gateway-solution-accelerator/tree/citadel-v1/guides)
is authoritative for accelerator prerequisites, deployment, configuration, and
validation. Use the [Foundry Citadel
Platform](https://github.com/Azure-Samples/foundry-citadel-platform) reference
architecture for the platform model and [Azure AI Landing
Zones](https://github.com/Azure/AI-Landing-Zones) where applicable.

Give the team the [external accelerator handoff](accelerator-handoff.md). Do
not copy external IaC or commands into the engagement record; confirm the
current source version and guidance immediately before change execution.

## 4. Validate in non-production

After deployment, the customer platform team runs an approved non-production
test through the gateway. Apply the [non-production gateway
acceptance](non-production-gateway-acceptance.md) criteria: an approved caller
uses the gateway path, the documented contract and backend apply, and a
platform owner can correlate the proof with telemetry. Resolve or defer each
exception with an owner and date.

## 5. Prove the gateway path and hand over

For every accepted test, create the [gateway evidence
manifest](gateway-evidence-manifest.md) using safe references only. The
platform owner returns the acceptance decision, manifest, change and rollback
references, support route, and deferred-item list to the governance lead.

The facilitator then releases the relevant session gates: S1–S3 may consume
gateway evidence after acceptance; S4/S5 and S6 use the handed-over contracts
and telemetry records as applicable.

## 6. Respect the delivery boundary

This repository coordinates a customer-owned platform workstream; it does not
install, configure, operate, or certify Citadel. It provides neither
accelerator IaC nor tenant-specific commands or values. Production promotion,
operational support, rollback, and all privileged changes remain with the
customer platform team. Gateway acceptance supports governance evidence only;
it is not a production-readiness certification.
