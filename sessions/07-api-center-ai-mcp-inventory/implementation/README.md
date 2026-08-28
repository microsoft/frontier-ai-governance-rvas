# Azure API Center and the AI/MCP inventory

## Session scope

### What we will do

Record **three selected assets in API Center**: the
[Session 05](../../05-governed-agent-baseline/implementation/README.md) agent API, the synchronized
[Session 06](../../06-apim-ai-gateway/implementation/README.md) APIM API, and one approved remote
MCP server. The owned result is one searchable design-time inventory where those records carry the
required owner, lifecycle, classification, risk, review, and runtime-location metadata.

### Why it matters

These three records give developers and owners a shared answer to what is available, where it runs,
and who must review or retire it. Missing ownership and lifecycle decisions become visible before
someone treats an asset as approved for use.

### Boundaries

The scope is these three records, not every asset in the API estate. API Center is authoritative
for their design-time inventory metadata. Foundry, APIM, and the MCP runtime remain authoritative
for live service state. The APIM source integration is read-only and one-way; native MCP
registration uses the supported portal path because the stable ARM surface does not expose those
fields.

API Center inventories and supports discovery. It does not inspect, authorize, or block runtime
calls. APIM owns runtime controls for the synchronized route, and
[Session 08](../../08-mcp-tool-security/implementation/README.md) governs MCP tool use. Production
discovery, write-capable MCP tools, and unrelated estate assets are excluded.

Four optional modules can build on this inventory without changing Session 07:

- [API Center private tool catalog to Foundry Toolbox](../../../modules/foundry-tool-catalog-integration/implementation/README.md)
  creates one curated, reusable Toolbox;
- [Azure API Center registry discovery](../../../modules/api-center-registry-discovery/implementation/README.md)
  exposes the approved MCP server set to supported developer clients; and
- [A2A agent inventory in Microsoft Agent 365](../../../modules/a2a-agent-inventory/implementation/README.md)
  confirms the enterprise inventory record through a supported Agent 365 integration; and
- [A2A agent discovery in Azure API Center](../../../modules/a2a-api-center-discovery/implementation/README.md)
  publishes a runtime-owned A2A interface for developer discovery when that catalog entry is needed.

Each module has its own access and lifecycle decisions. None is enabled here.

## Architecture

### Architecture at a glance

API Center gives the team one design-time catalog for this governed path. Three sources feed it.
Bicep registers the Session 05 agent API and its OpenAPI definition directly. A one-way integration
reads every API from the Session 06 APIM instance, using a managed identity with API Management
Service Reader Role. The API program owner adds the approved remote MCP server through the
supported portal form. After APIM synchronization creates its record, the asset owner maintains
its metadata in API Center.

![The direct agent definition, one-way APIM synchronization, and portal-based MCP registration feed API Center; APIM remains on the separate runtime request path](../assets/diagrams/api-center-inventory-flow.svg)

These paths carry definitions, runtime locations, and ownership metadata. Live API traffic never
passes through the catalog; it continues to follow the APIM request path and its policies.

API Center is the record for design-time metadata and discovery. Foundry, APIM, and the MCP server
still report their own runtime state. The boundary ends with the inventory and the health of its
sources. API Center neither inspects nor blocks a call. Session 08 receives the MCP record and
runtime location for tool-security work.

### Design choices and tradeoffs

| Decision | Chosen approach | Why this shape works | Tradeoff | Revisit when |
|---|---|---|---|---|
| Inventory scope | Register the direct agent, the synchronized APIM API, and one remote MCP server | The inventory covers this governed path without claiming to cover the whole estate | Assets outside these sources remain outside the control | The API program owner approves a broader source boundary and names its metadata owners |
| APIM ingestion | Use one-way synchronization with API Management Service Reader Role | API definitions stay aligned without giving API Center write access to APIM | The first sync can take up to 24 hours and imports every API in the APIM instance | Selective synchronization or a narrower APIM source becomes available |
| MCP registration | Use the native portal flow and keep the resulting metadata in API Center | The registration follows the supported native MCP model | A person must complete it because the stable Azure Resource Manager API does not expose those fields | Microsoft publishes a stable MCP resource contract |
| State ownership | Let API Center own design metadata while each service owns its runtime state | The catalog does not pretend to report live health | Owners must reconcile metadata when a service changes | A supported integration can safely update the same fields from runtime state |
| Plan | Record Free or Standard, then confirm the plan in the portal | The support and cost choice remains explicit | Stable Bicep does not set the plan | The service API exposes supported plan deployment |

### Architecture guidance

- [Azure API Center overview](https://learn.microsoft.com/en-us/azure/api-center/overview) explains the design-time inventory boundary and its relationship with API Management.
- [Synchronize APIs from Azure API Management instance](https://learn.microsoft.com/en-us/azure/api-center/synchronize-api-management-apis) defines the one-way source integration and synchronization timing.
- [Inventory and discover MCP servers in your API Center](https://learn.microsoft.com/en-us/azure/api-center/register-discover-mcp-server) describes native remote MCP registration and environment association.

## Before you start

Confirm these prerequisites:

- Sessions 01-05 are complete in the approved nonproduction scope.
- Azure CLI 2.57.0 or later and the current `apic-extension` are installed.
- The deployment operator is signed in to the approved subscription and has a time-bound
  **Contributor** role assignment on the exact resource group where this session deploys API
  Center.
- The role-assignment operator has time-bound **User Access Administrator** on the exact
  [Session 06](../../06-apim-ai-gateway/implementation/README.md) APIM instance. This assignment permits creation of the **API Management Service Reader
  Role** (`71522526-b88f-4d52-b57f-d31fc3546d0d`) assignment at that APIM scope.
- The API program owner has chosen Free or Standard after reviewing current limits, support, and
  cost. The Free plan has no Microsoft support; the documented Standard benefit requires an eligible
  linked Standard, Standard v2, Premium, or Premium v2 APIM instance.
- The APIM source boundary is approved for synchronization. The integration imports every API from
  the linked APIM instance. If that instance contains unrelated APIs, their owners must complete the
  same mandatory metadata before linking; otherwise stop and do not create the integration.
- The [Session 05](../../05-governed-agent-baseline/implementation/README.md) agent account, project, agent name, and direct endpoint are known.
- The [Session 06](../../06-apim-ai-gateway/implementation/README.md) API ID `policy-assistant-responses` is present and carries its implementation
  marker.
- One existing remote, read-only MCP server uses an approved HTTPS Streamable HTTP endpoint.
- The selected API Center region is currently advertised by the `Microsoft.ApiCenter` provider.
- The business, technical, data, risk, residency, evaluation, review, expiry, and consumer decisions
  have named owners in API Center.
- The direct-agent deployment definition is complete before deployment.
- Plan two delivery windows. The 240 minutes covers active work across both windows, not the APIM
  synchronization wait.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/api-center/main.bicep`](artifacts/api-center/main.bicep) | The Session 07 API Center deployment scripts |
| Deployment | [`artifacts/api-center/apim-reader.bicep`](artifacts/api-center/apim-reader.bicep) | The Session 07 API Center deployment scripts |
| Deployment | [`artifacts/api-center/metadata-schemas.json`](artifacts/api-center/metadata-schemas.json) | The API Center metadata-schema resources |
| Deployment | [`artifacts/api-center/agent-api-definition.json`](artifacts/api-center/agent-api-definition.json) | The Session 07 API Center deployment scripts |
| Deployment | [`artifacts/catalog/specs/policy-assistant-agent.openapi.json`](artifacts/catalog/specs/policy-assistant-agent.openapi.json) | The API Center definition import |
| Deployment | [`artifacts/environments/sandbox.json`](artifacts/environments/sandbox.json) | The Session 07 preflight, deployment, and inventory-check scripts |

### Official documentation

Use Microsoft’s [API Management synchronization guide](https://learn.microsoft.com/en-us/azure/api-center/synchronize-api-management-apis)
when checking supported assets, one-way synchronization, and expected update timing.

## Decisions and stop conditions

Resolve every `__REQUIRED_*__` value before deployment. Use role or group names rather than personal
data where the customer's data-handling rules permit it.

### Which assets API Center records

**API Center is the design-time source of truth** for the governed AI path. It contains the direct
agent endpoint, the APIM runtime API, and the approved remote MCP server. The APIM integration is
one-way from APIM to API Center. It does not deploy or change APIs in APIM.

Stop if the APIM integration would import unrelated assets with no owner for their metadata, if a
different API Center is already the customer source of truth, or if another inventory must remain
authoritative. Do not create a second catalog to avoid reconciling ownership.

### Plan and region

Record `Free` or `Standard` in `sandbox.json`. Free is suitable only when its current limits and lack
of Microsoft support are accepted for this nonproduction scope. If Standard is selected, confirm
that the linked APIM tier qualifies for the documented benefit or that separate cost is approved.
The stable `2024-03-01` Bicep service resource does not expose plan selection, so the API program
owner confirms or upgrades the approved plan in the portal after the APIM link is created.

Stop if the selected region is not advertised by the live `Microsoft.ApiCenter` provider, the plan
decision is unresolved, or the customer assumes an APIM link grants a benefit on an ineligible tier.

### Required metadata and owner decisions

Every in-scope asset has these properties:

| Property | Decision |
|---|---|
| Business owner | Accountable role or group |
| Technical owner | Operating role or group |
| AI asset kind | `ai-api`, `agent-api`, or `mcp-server` |
| Data classification | `public`, `internal`, `confidential`, or `restricted` |
| Permitted consumers | One or more approved groups or workload classes |
| Model/provider | Model provider, or `not-applicable` for a non-model MCP server |
| Residency profile | Approved processing and storage boundary |
| Risk tier | `low`, `moderate`, `high`, or `critical` |
| Evaluation results URL | Owned evaluation record or evaluation backlog |
| Last review and expiry | ISO dates with expiry after review |
| Implementation session | `07-api-center-ai-mcp-inventory` |

Stop if an owner is not recorded, the classification or residency decision is unresolved, the
evaluation URL has no accountable destination, or expiry is used without an operating response.
Required metadata is not a substitute for runtime authorization.

The API program owner defines the schema and allowed values. Each asset's business owner approves
permitted consumers and lifecycle. The technical owner maintains the runtime location and review
date. The data owner sets classification and residency; the risk owner sets the risk tier and
evaluation destination.

When a record reaches `expiryDate`, its technical owner has one business day to renew it after
review, mark it retired and remove it from discovery, or quarantine it from approved use while the
record is investigated. An expired record must not remain listed as an approved asset.

### APIM synchronization

The API Center system identity receives only API Management Service Reader Role on the exact APIM
service. The integration imports specifications and assigns the `testing` lifecycle to synchronized
assets. Microsoft states that synchronization normally completes within minutes but can take up to
24 hours.

Stop if the API Center identity would receive contributor access, if the APIM source is in a
different directory, if the Session 06 API marker is absent, or if initial synchronization has not
completed. Do not create a duplicate manual API record while waiting.

### MCP registration

Use the native **Register an asset > MCP server** flow. Enter the runtime URL from
`$env:SESSION07_MCP_SERVER_URL`; do not write it into the repository. Select Streamable HTTP as the
approved runtime path. API Center may also generate an SSE definition as product behavior; this
session does not design a new SSE transport.

Stop if the server is write-capable, uses local `stdio`, lacks an approved HTTPS endpoint, embeds a
credential in its URL, or has no runtime owner. [Session 08](../../08-mcp-tool-security/implementation/README.md) adds tool authorization, blocked-write,
and prompt-injection controls. Registration here does not approve the MCP server for production use.

The split is deliberate. Stable `Microsoft.ApiCenter@2024-03-01` ARM resources deploy the API
Center service, metadata schemas, workspace, API versions, definitions, environments, and
deployments. The current portal form registers the newer native MCP server record because those MCP
fields are not exposed by that stable ARM API. The API program owner owns this manual registration
until Microsoft publishes a supported stable resource contract.

### Discovery and linting

API Center's managed analysis and ruleset are authoritative for the OpenAPI and AsyncAPI
definitions in this session.

The Azure portal inventory is the discovery experience for this session. This session does not configure the API Center portal or private discovery. A later change must name
the user or group principals that can discover APIs, the API Center read role and assignment scope,
the approved hostname, and the network owner before either surface is enabled. Discovery remains
separate from APIM runtime enforcement.

## Implement

Use **two delivery windows** because APIM synchronization can take up to 24 hours. When registering
the remote server, follow Microsoft’s [MCP inventory and discovery
guidance](https://learn.microsoft.com/en-us/azure/api-center/register-discover-mcp-server).

### 1. Window one: confirm readiness

Confirm `agent-api-definition.json` and `sandbox.json`. The definition supplies the direct agent
API's desired state. API Center remains the authoritative location for synchronized APIM and native
MCP metadata.
Keep subscription IDs, runtime URLs, credentials, tokens, prompts, responses, and telemetry outside
source control.

Set runtime values in the shell:

```powershell
$approvedSubscriptionId = $env:AZURE_SUBSCRIPTION_ID
$session05AgentBaseUrl = $env:SESSION07_AGENT_BASE_URL
$remoteMcpServerUrl = $env:SESSION07_MCP_SERVER_URL
$remoteMcpServerTitle = "approved remote MCP server title"
```
```bash
approved_subscription_id="${AZURE_SUBSCRIPTION_ID:?Set AZURE_SUBSCRIPTION_ID.}"
session05_agent_base_url="${SESSION07_AGENT_BASE_URL:?Set SESSION07_AGENT_BASE_URL.}"
remote_mcp_server_url="${SESSION07_MCP_SERVER_URL:?Set SESSION07_MCP_SERVER_URL.}"
remote_mcp_server_title="approved remote MCP server title"
```

The direct agent URL must end at:

```text
https://<account>.services.ai.azure.com/api/projects/<project>/agents/<agent>/endpoint/protocols/openai
```

### 2. Run preflight and inspect the preview

```powershell
.\scripts\preflight.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -Session05AgentBaseUrl $session05AgentBaseUrl `
  -RemoteMcpServerUrl $remoteMcpServerUrl
```
```bash
./scripts/preflight.sh --approved-subscription-id "$approved_subscription_id" --session05-agent-base-url "$session05_agent_base_url" --remote-mcp-server-url "$remote_mcp_server_url"
```

Preflight parses the direct-agent definition and deployment inputs, checks all 12 metadata
definitions, validates the current OpenAPI contract, rejects unknown decision sentinels, and verifies
the runtime URL shapes. It checks
Azure CLI and `apic-extension`, the approved subscription and resource group, live API Center
provider locations, APIM tier and source marker, the stable reader role, and name collisions. It
then compiles the Bicep and runs an ARM `what-if`.

Stop if `what-if` replaces or removes an unrelated resource, targets a different APIM instance,
changes a broader role assignment, or introduces a runtime URL into source control.

### 3. Deploy the API Center control

```powershell
.\scripts\deploy.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -Session05AgentBaseUrl $session05AgentBaseUrl `
  -RemoteMcpServerUrl $remoteMcpServerUrl
```
```bash
./scripts/deploy.sh --approved-subscription-id "$approved_subscription_id" --session05-agent-base-url "$session05_agent_base_url" --remote-mcp-server-url "$remote_mcp_server_url"
```

The script reruns preflight, deploys the marked API Center, imports the approved agent OpenAPI
definition, and creates the GA APIM integration with specification import enabled. The integration
creates its own APIM environment and deployment records.

In the API Center portal, confirm the plan matches `sandbox.json`. If the required decision is
Standard, complete the approved upgrade after the eligible APIM integration exists.

Wait for the [Session 06](../../06-apim-ai-gateway/implementation/README.md) API title **Governed policy assistant Responses API** to appear once in the
API Center inventory. If synchronization does not complete during the session, stop at this point and
resume after the source reports healthy. Do not register the same API manually.

### 4. Window two: maintain the synchronized API metadata

Resume only after the source is healthy and synchronization has completed. In API Center, open the
single synchronized **Governed policy assistant Responses API** record and set its required metadata.
The API owner maintains that live record, including ownership, permitted consumers, classification,
residency, risk, evaluation destination, review date, and expiry.

### 5. Register the approved remote MCP server

In the Azure portal, open the deployed API Center:

1. Select **Inventory > Assets > Register an asset > MCP server**.
2. Enter the approved MCP title, summary, description, version, lifecycle, and metadata.
3. Add one remote using `$remoteMcpServerUrl`.
4. Associate it with the approved nonproduction runtime environment.
5. Keep the selected runtime transport on Streamable HTTP and create the record.

Do not paste credentials, tokens, tool output, prompts, or customer data into the catalog.

### 6. Review API analysis and native deployment state

Open the two OpenAPI definitions and review the managed API analysis. The implementation definition should
have operation descriptions, an operation ID, and success and authorization responses. In the
portal, inspect the native MCP deployment and confirm its Streamable HTTP location matches the
approved runtime URL. This manual check remains necessary because the stable ARM and CLI surfaces
used here do not expose the native MCP deployment-health contract.

## Confirm the result

Run the **read-only inventory check**:

```powershell
.\scripts\check-inventory.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -RemoteMcpServerTitle $remoteMcpServerTitle
```
```bash
./scripts/check-inventory.sh --approved-subscription-id "$approved_subscription_id" --remote-mcp-server-title "$remote_mcp_server_title"
```

Expected result: the three selected records each appear once with the required metadata, and the
APIM integration resolves to the implementation source. The script checks
provisioning state when the response exposes it and writes no inventory export. The owner confirms
source health manually when that field is absent, and always checks the native MCP deployment
location and runtime health in the portal.

The script treats a record with missing ownership or required metadata as orphaned and checks the
APIM source integration live. Native MCP deployment location and runtime health are manual checks
on the current supported surface. Do not describe this check as end-to-end runtime validation.

## After implementation

Keep the **API Center inventory in operation**, including the service, system identity, required
metadata schema, APIM integration, direct agent API, native MCP record, definitions, deployments,
and scripts. The API program owner owns the API Center service and metadata
schema. Business and technical owners maintain their records. The data and risk owners maintain
classification, residency, risk tier, review, and expiry. The APIM owner maintains the source
integration. Developers own definition quality.

Run this implementation only against the nonproduction inventory scope listed in the control
definition. It does not approve
production discovery, public access, an MCP write path, an API Center portal, a private endpoint, a
Foundry tool catalog, registry-based MCP discovery, A2A inventory, or a custom analysis profile.

If the API Center inventory must be removed, the API program owner first confirms that no later
session or approved consumer depends on it. Use the approved Azure change path to check the live
`implementationSession` tag, remove the exact APIM reader assignment, and delete only the marked API
Center. Its workspace, metadata, inventory records, definitions, deployments, and integrations are
removed with it. The APIM instance, Foundry agent, remote MCP runtime, runtime policies, and
repository definitions remain.
