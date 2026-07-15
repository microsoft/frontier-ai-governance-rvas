# External accelerator handoff

This handoff separates the customer platform deployment from the RVAS
governance engagement. The platform team must use the accelerator's current
documentation and its customer-approved change process; this repository does
not wrap, fork, deploy, or configure it.

## Handoff package

Provide the platform team with:

1. the completed [intake](intake.md), named owners, target environment, and
   required evidence consumers;
2. the [Foundry Citadel Platform](https://github.com/Azure-Samples/foundry-citadel-platform)
   reference architecture for the layer model;
3. the [AI Hub Gateway deployment guidance](https://github.com/Azure-Samples/ai-hub-gateway-solution-accelerator/tree/citadel-v1/guides)
   for accelerator prerequisites, deployment, configuration, and validation;
4. [Azure AI Landing Zones](https://github.com/Azure/AI-Landing-Zones) for the
   workload landing-zone foundation; and
5. the [non-production gateway acceptance](non-production-gateway-acceptance.md)
   and [evidence manifest](gateway-evidence-manifest.md) required for the
   governance handoff.

Before work starts, the platform owner records the selected repository,
branch/release, immutable commit, applicable product status, and any departures
from the accelerator guidance in the customer change record. A branch name
alone is not a reproducible deployment record.

## What returns from the platform workstream

The platform owner returns the completed acceptance decision, manifest, change
and rollback references, support route, and a list of deferred items. This is
the handoff to the governance lead—not a request for the facilitator to
operate the gateway.
