# Implementation artifacts

These files define the direct agent API deployment. API Center stores its inventory metadata, the
synchronized APIM entries, and the native MCP server entry. API Management still controls runtime calls.

| Path | Operational purpose |
|---|---|
| `api-center/main.bicep` | Defines API Center, its system identity, metadata schemas, workspace, Foundry environment, direct agent API, and scoped APIM reader module |
| `api-center/apim-reader.bicep` | Assigns API Management Service Reader Role in the existing APIM resource group |
| `api-center/metadata-schemas.json` | Defines required API metadata and allowed governance values |
| `api-center/agent-api-definition.json` | Defines the direct Session 05 agent API and its required metadata |
| `catalog/specs/policy-assistant-agent.openapi.json` | Supplies the OpenAPI definition for the direct agent endpoint |
| `environments/sandbox.json` | Names the approved API Center, APIM, Foundry, and integration resources |

Keep runtime URLs, credentials, tokens, prompts, responses, and telemetry outside the repository.
Preflight rejects every `__REQUIRED_*__` value before deployment.

The stable `Microsoft.ApiCenter@2024-03-01` resources deploy the service and direct agent API. The
API program owner uses the supported portal flow to maintain the native MCP server entry and
synchronized APIM metadata. The live script checks required metadata and APIM integration health.
The owner checks the native MCP deployment location and runtime health in the portal.
