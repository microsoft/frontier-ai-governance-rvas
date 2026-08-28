# Implementation artifacts

These files define the records that API Center exposes for discovery. API Center stores definitions,
deployments, runtime locations, and owner metadata. API Management still validates and controls
runtime calls.

| Path | Operational purpose |
|---|---|
| `api-center/main.bicep` | API Center, system identity, metadata schemas, workspace, Foundry environment, agent API record, and scoped APIM reader module |
| `api-center/apim-reader.bicep` | Exact API Management Service Reader Role assignment in the existing APIM resource group |
| `api-center/metadata-schemas.json` | Required API metadata definitions and allowed governance values |
| `catalog/catalog-records.json` | Shared metadata source plus the Session 06 agent, synchronized APIM, and native MCP record values |
| `catalog/specs/policy-assistant-agent.openapi.json` | OpenAPI definition imported for the direct agent endpoint |
| `environments/sandbox.json` | Approved API Center, APIM, Foundry, and integration coordinates |

Runtime URLs, credentials, tokens, prompts, responses, and telemetry stay outside the repository.
Preflight rejects every `__REQUIRED_*__` value before deployment.

The stable `Microsoft.ApiCenter@2024-03-01` resources deploy the catalog and API records. The API
program owner uses the supported portal form for the native MCP record until a stable ARM resource
exposes those fields. The live script checks required metadata and APIM integration health. The
native MCP deployment location and runtime health remain manual portal checks.
