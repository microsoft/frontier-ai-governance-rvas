# Implementation - API Center private tool catalog to Foundry Toolbox

## Module scope

### What we will do

Connect an approved remote MCP server in Azure API Center to a dedicated versioned Toolbox in
Microsoft Foundry. The work uses the API Center private tool catalog in Foundry Tools to discover
and configure the server, then creates a Toolbox version that exposes the approved tool and
requires approval for every call.

The observable result is a version-specific Toolbox MCP endpoint whose `tools/list` response
contains exactly the approved namespaced tool.

### Why it matters

Session 07 establishes the inventory record. Session 08 establishes the MCP security boundary. This
module connects those decisions to the reusable runtime surface that agent teams can consume
without rebuilding the same tool configuration for every agent.

The connection also exposes drift. If the API Center deployment endpoint, Foundry project
connection, allow list, or Toolbox result no longer matches the approved record, preflight or the
live check stops.

### Boundaries

This optional module sits outside the 14-session sequence. It handles the MCP server record in API
Center, the related Foundry project connection, a new dedicated Toolbox, and the approved MCP tool
in an approved nonproduction scope.

The private tool catalog experience is in public preview and its API Center authentication, access,
and discovery steps are portal-led. The module does not invent an API for that handoff. The preview
decision and successful discovery under **Build > Tools** must be recorded before Toolbox creation.

Azure API Center remains authoritative for the inventory record and deployment metadata. The MCP
server remains authoritative for the live tool contract. The Foundry project connection owns
runtime authentication, while the Toolbox version owns the allowed tool and approval setting.

This module does not create an MCP server, change its authorization model, add a tool to an agent,
or call the tool. It does not claim that API Center access settings alone enforce every runtime
call. Agent integration remains with the owners of
[Session 05](../../../sessions/05-governed-agent-baseline/), and MCP runtime controls remain with
[Session 08](../../../sessions/08-mcp-tool-security/).

## Architecture

### Architecture at a glance

The flow moves from API Center through the Foundry project connection to the runtime endpoint:

1. The API catalog owner keeps the MCP server record in API Center, including its version,
   deployment, access, and authentication metadata.
2. The Foundry tool owner opens the intended project, goes to **Build > Tools**, finds the private
   catalog by its API Center name, selects the MCP server record in API Center, and completes its
   project connection.
3. The Toolbox deployment process creates an immutable version from
   `toolbox-version.json`. The version refers to that project connection, exposes the approved tool,
   and requires approval for every call.
4. Agent teams consume the unversioned Toolbox endpoint. The implementation check uses the
   version-specific endpoint so it can inspect the exact created version.

The repository owns the catalog record and Toolbox version payload. Live API Center, project
connection, and Toolbox state remain authoritative. The endpoint hash in the catalog record links
the API Center deployment to the Toolbox payload without retaining the endpoint in the governance
record.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations | Revisit when |
|---|---|---|---|---|
| Catalog source | The MCP server record in API Center | Reuses the Session 07 inventory and owner metadata | The Foundry Tools private catalog is public preview and portal-led | Microsoft publishes a stable automated catalog-to-project connection API |
| Reuse boundary | A new dedicated Toolbox | Gives agents a stable consumer endpoint and keeps this change isolated | A separate Toolbox adds a managed object and owner | The tool becomes part of an already governed multi-tool Toolbox |
| Tool exposure | The `allowed_tools` list contains one entry | Keeps the runtime surface narrow and makes drift visible | A tool rename requires a new Toolbox version | The MCP owner intentionally changes the public tool contract |
| Approval | `require_approval` set to `always` | Agent runtimes receive the requirement with the tool metadata | The runtime must still present and enforce the approval interaction | Session 08 approves a different action-specific policy and the runtime supports it |
| Validation | `tools/list` against the version-specific endpoint | Checks the immutable version before agent reuse | It confirms discovery and approval metadata, not business behavior | A safe, non-mutating operation is approved for an additional runtime check |

### Architecture guidance

Use Microsoft’s [private tool catalog
guidance](https://learn.microsoft.com/en-us/azure/foundry/agents/how-to/private-tool-catalog)
for the current Azure API Center registration, authorization, access, and **Build > Tools**
discovery path. The page marks this feature as public preview and notes that Azure RBAC changes can
take up to 24 hours to appear.

Use [Create and manage a toolbox in
Foundry](https://learn.microsoft.com/en-us/azure/foundry/agents/how-to/tools/toolbox) for Toolbox
versioning, the `v1` data-plane route, the default and version-specific MCP endpoints, and the
`tools/list` check. A Toolbox version is immutable. The first version of a new Toolbox becomes its
default version.

The [MCP tool
guidance](https://learn.microsoft.com/en-us/azure/foundry/agents/how-to/tools/model-context-protocol)
defines project connections, `allowed_tools`, approval settings, and the Toolbox reuse pattern.
Treat the remote server's tool metadata and results as untrusted input even when its catalog record
is approved.

## Before you start

Confirm:

- the MCP server record in API Center from Session 07 is approved and identifies the remote MCP
  server version and deployment;
- the Session 08 owner has approved the exact MCP tool name and the server's authentication path;
- the API catalog owner has approved public-preview use in this nonproduction scope;
- the operator has Azure API Center Data Reader on the exact API Center resource;
- the operator has Foundry User on the exact project and Foundry Project Manager if the catalog
  configuration creates a project connection;
- the agent release owner understands that Toolbox approval metadata still needs an enforcing
  runtime approval experience;
- Azure CLI is signed in to the intended tenant;
- Azure Developer CLI 1.25 or later has the `microsoft.foundry` extension; and
- Python 3 is available for the payload checks and the final read-only query.

Complete every `__REQUIRED_*__` value under
[`artifacts/`](artifacts/README.md) in an approved private working copy. Do not commit the completed
copy because it contains tenant-specific resource coordinates and the MCP endpoint.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Record | [`artifacts/governance/catalog-toolbox-binding.json`](artifacts/governance/catalog-toolbox-binding.json) | The API catalog owner and Foundry tool owner |
| Deployment | [`artifacts/toolbox/toolbox-version.json`](artifacts/toolbox/toolbox-version.json) | The Foundry Toolbox deployment process |
| Runtime | [`artifacts/operations/check_toolbox.py`](artifacts/operations/check_toolbox.py) | The Foundry tool owner |

The module uses **standard mode** because it makes a bounded configuration change and performs a
read-only observable check. It does not need a failure-path exercise or a delivery-owner
checkpoint.

Allow 180 minutes. The private catalog's Azure RBAC assignment can take up to 24 hours to
propagate, so assign access before the delivery window.

## Decisions and stop conditions

### Accept the preview and portal boundary

Set `previewDecision.privateToolCatalog` to
`accepted-for-approved-nonproduction-scope` only after the named decision owner accepts the Azure
preview terms and operating limits.

Set `previewDecision.catalogDiscovery` to `confirmed-in-foundry-tools` only after the operator opens
the intended Microsoft Foundry project, goes to **Build > Tools**, filters by the API Center name,
and sees the MCP server record in API Center.

Stop if the record is absent. Check the API Center Data Reader assignment, the selected Foundry
project, the API Center asset version and deployment, and the possible RBAC propagation delay. Do
not bypass the catalog with an unreviewed custom MCP entry.

### Reconcile the source record

Copy the selected API Center asset, version, and deployment names into
`catalog-toolbox-binding.json`. Put the runtime endpoint only in `toolbox-version.json`, then
record its SHA-256 digest in `sourceRecord.mcpEndpointSha256`.

The API catalog owner compares the endpoint entered in Foundry with the current API Center
deployment. A matching digest proves that the two module files refer to the same endpoint without
duplicating the endpoint in the governance record.

Stop if:

- the API Center lifecycle state is not approved;
- the deployment has no runtime URL;
- the endpoint differs between API Center, the project connection, and the Toolbox payload;
- the authentication method differs from the Session 08 decision;
- the project connection is missing or belongs to another project; or
- the selected MCP server exposes no exact tool name approved by Session 08.

### Keep the Toolbox narrow

This module creates a new dedicated Toolbox. Set `initialToolboxState` to `absent`, and stop if a
Toolbox with the chosen name already exists. This avoids adding a version to a Toolbox with unknown
consumers or tools.

`toolbox-version.json` must contain one MCP object, one `allowed_tools` value, and
`require_approval: "always"`. Set `expectedNamespacedTool` to
`<server_label>.<allowed_tool_name>`.

The approval value is metadata returned to the agent runtime. The runtime must still show the
pending action and wait for a user decision. Do not treat the Toolbox endpoint itself as the
approval enforcement point.

### Keep credentials out of the files

Configure authentication during the private-catalog flow or in the resulting Foundry project
connection. Do not add API keys, bearer tokens, OAuth client secrets, or authorization headers to
either JSON artifact.

Stop if the catalog flow cannot represent the approved authentication mode. Return the decision to
the Session 08 identity and security owners instead of storing a credential in the Toolbox
payload.

## Implement

### 1. Complete the catalog record

Fill `catalog-toolbox-binding.json` with the approved scope, source record, owner roles, Foundry
names, and restore owner. Use a new Toolbox name reserved for this MCP connection.

Calculate the normalized endpoint digest. Trim a final `/` before hashing.

```powershell
$mcpEndpoint = Read-Host "Approved MCP endpoint"
$normalizedEndpoint = $mcpEndpoint.TrimEnd("/")
$endpointHash = [Convert]::ToHexString(
    [Security.Cryptography.SHA256]::HashData(
        [Text.Encoding]::UTF8.GetBytes($normalizedEndpoint)
    )
).ToLowerInvariant()
$endpointHash
```

```bash
read -r -p "Approved MCP endpoint: " mcp_endpoint
normalized_endpoint=${mcp_endpoint%/}
printf '%s' "$normalized_endpoint" | sha256sum | cut -d' ' -f1
```

Store the endpoint in `toolbox-version.json` and its digest in the catalog record. Keep the filled
files in the approved private configuration store.

### 2. Configure the catalog item in Foundry Tools

In the Azure portal, open the exact API Center resource. Confirm the MCP server's authorization
configuration and its **Details > Versions > Manage access (preview)** settings.

Then open the intended project in the Microsoft Foundry portal:

1. Go to **Build > Tools**.
2. Find the private tool catalog by the API Center name.
3. Select the MCP server record in API Center.
4. Review its setup requirements and configure it for the project.
5. Record the resulting project connection name in both artifacts.

This is the current documented portal handoff. If the portal does not expose the record or cannot
create a connection that matches the approved authentication mode, stop. There is no module-owned
fallback API.

### 3. Run preflight

```powershell
$projectEndpoint = "https://<foundry-account>.services.ai.azure.com/api/projects/<project>"
$approvedTargetScope = "<approved-nonproduction-scope>"
.\scripts\preflight.ps1 `
  -ProjectEndpoint $projectEndpoint `
  -ApprovedTargetScope $approvedTargetScope
```

```bash
project_endpoint="https://<foundry-account>.services.ai.azure.com/api/projects/<project>"
approved_target_scope="<approved-nonproduction-scope>"
./scripts/preflight.sh \
  --project-endpoint "$project_endpoint" \
  --approved-target-scope "$approved_target_scope"
```

Preflight checks the exact scope, preview approval, portal discovery decision, endpoint digest,
project connection, one-tool allow list, approval setting, implementation marker, and Toolbox name
collision.

Microsoft Foundry does not provide a read-only deployment preview for Toolbox version creation.
Preflight records `previewSupported` as false through this explicit message, inspects the existing
project connection, and requires the dedicated Toolbox name to be absent before the POST.

### 4. Create the first Toolbox version

Use the Microsoft Foundry `v1` data-plane route. The first version of a new Toolbox becomes the
default version.

```powershell
$binding = Get-Content .\artifacts\governance\catalog-toolbox-binding.json -Raw |
  ConvertFrom-Json
$payload = Get-Content .\artifacts\toolbox\toolbox-version.json -Raw
$token = az account get-access-token `
  --resource https://ai.azure.com `
  --query accessToken `
  --output tsv
$createUri = "$projectEndpoint/toolboxes/$($binding.foundryBinding.toolboxName)/versions?api-version=v1"
$created = Invoke-RestMethod `
  -Method Post `
  -Uri $createUri `
  -Headers @{ Authorization = "Bearer $token" } `
  -ContentType "application/json" `
  -Body $payload
$toolboxVersion = [string]$created.version
$versionEndpoint = "$projectEndpoint/toolboxes/$($binding.foundryBinding.toolboxName)/versions/$toolboxVersion/mcp?api-version=v1"
```

```bash
binding_path="./artifacts/governance/catalog-toolbox-binding.json"
payload_path="./artifacts/toolbox/toolbox-version.json"
toolbox_name=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["foundryBinding"]["toolboxName"])' "$binding_path")
token=$(az account get-access-token --resource https://ai.azure.com --query accessToken --output tsv)
create_uri="$project_endpoint/toolboxes/$toolbox_name/versions?api-version=v1"
created=$(curl --fail --silent --show-error \
  --request POST \
  --url "$create_uri" \
  --header "Authorization: Bearer $token" \
  --header "Content-Type: application/json" \
  --data-binary "@$payload_path")
toolbox_version=$(printf '%s' "$created" | python3 -c 'import json,sys; print(json.load(sys.stdin)["version"])')
version_endpoint="$project_endpoint/toolboxes/$toolbox_name/versions/$toolbox_version/mcp?api-version=v1"
unset token
```

Do not print or retain the access token. Record the returned version number in
`observedState.toolboxVersion`. Do not store either Toolbox endpoint in the repository.

### 5. Hand the consumer endpoint to agent owners

The reusable consumer endpoint omits `/versions/{version}` and always serves the Toolbox
`default_version`:

```text
{project_endpoint}/toolboxes/{toolbox_name}/mcp?api-version=v1
```

Pass it through the approved runtime configuration path to agent teams. Do not add it directly to
the Session 05 agent as part of this module. That owner decides when the agent release is ready to
consume the Toolbox and how the runtime presents approval requests.

## Confirm the result

Run the read-only `tools/list` check against the version-specific endpoint created in the previous
step:

```powershell
$expectedTool = $binding.foundryBinding.expectedNamespacedTool
python .\artifacts\operations\check_toolbox.py `
  --endpoint $versionEndpoint `
  --expected-tool $expectedTool
```

```bash
expected_tool=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["foundryBinding"]["expectedNamespacedTool"])' "$binding_path")
python3 ./artifacts/operations/check_toolbox.py \
  --endpoint "$version_endpoint" \
  --expected-tool "$expected_tool"
```

The check passes when the immutable Toolbox version returns exactly one tool named
`<server_label>.<allowed_tool_name>` and its metadata says `require_approval` is `always`. It does
not invoke the remote tool or retain the response.

Set `observedState.checkedAtUtc` after the check. Keep the version number and check time in the
private operational copy of the catalog record.

## After implementation

Keep the catalog record, Toolbox version payload, check utility, and paired preflight scripts. The
API catalog owner maintains the MCP server record in API Center. The Foundry tool owner owns the
project connection and dedicated Toolbox. The agent release owner decides which agents consume the
stable Toolbox endpoint and confirms that their runtime enforces approval.

Reconcile the connection after an API Center deployment URL, authentication setting, exposed tool
name, project connection, or Toolbox default version changes. Update the endpoint digest and create
a new immutable Toolbox version rather than editing the prior version.

To restore the pre-module state, first move every consuming agent away from the Toolbox endpoint.
The restore owner then checks that the Toolbox description contains
`implementationSession=optional-module-foundry-tool-catalog-integration`, confirms that the
Toolbox still contains only this module's MCP connection, and deletes that exact dedicated Toolbox
through the approved Microsoft Foundry change path. Remove the project connection only when its
owner confirms that no other tool or agent uses it. Keep the MCP server record in API Center unless
the API catalog owner separately retires the underlying MCP server.
