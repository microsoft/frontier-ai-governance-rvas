# Implementation artifacts

These files define the deployment inputs for the direct agent API. API Center retains the resulting
inventory metadata, synchronized APIM records, and native MCP record. API Management still validates
and controls runtime calls.

| Path | Operational purpose |
|---|---|
| `api-center/main.bicep` | API Center, system identity, metadata schemas, workspace, Foundry environment, direct agent API, and scoped APIM reader module |
| `api-center/apim-reader.bicep` | Exact API Management Service Reader Role assignment in the existing APIM resource group |
| `api-center/metadata-schemas.json` | Required API metadata definitions and allowed governance values |
| `api-center/agent-api-definition.json` | Desired-state definition and required metadata for the direct Session 05 agent API |
| `catalog/specs/policy-assistant-agent.openapi.json` | OpenAPI definition imported for the direct agent endpoint |
| `environments/sandbox.json` | Approved API Center, APIM, Foundry, and integration coordinates |

Runtime URLs, credentials, tokens, prompts, responses, and telemetry stay outside the repository.
Preflight rejects every `__REQUIRED_*__` value before deployment.

The stable `Microsoft.ApiCenter@2024-03-01` resources deploy the service and direct agent API. The
API program owner uses the supported portal flow to maintain the native MCP record and the
synchronized APIM record's metadata. The live script checks required metadata and APIM integration
health. The native MCP deployment location and runtime health remain manual portal checks.
