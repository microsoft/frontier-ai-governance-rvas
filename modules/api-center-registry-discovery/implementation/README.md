# Implementation - Azure API Center registry discovery for approved MCP servers

## Module scope

### What we will do

**Objective.** Give developers a controlled way to find MCP servers that already passed governance, without
exposing draft or retired entries.

Configure Microsoft Entra-protected registry discovery for MCP servers already governed through
Sessions 07 and 08. The API Center configuration owner limits Data API visibility to MCP records
at the approved `Production` lifecycle stage, and the client owner configures supported developer
clients to use the default-workspace MCP registry endpoint. The check then reads the full registry
and confirms every approved server name appears with no unexpected name; it prints counts, not
names or credentials.

### Why it matters

**Problem.** Session 07 creates the inventory record, and Session 08 sets runtime authorization and tool
security. Developers still need a controlled way to find only the servers that passed those
decisions. Without that boundary, a client can list draft or retired entries beside approved
servers, and the registry starts to look like an approval system when it's only an inventory.

**Solution.** This module adds that boundary: Data API visibility limited to `Production`-stage MCP records,
reached through Microsoft Entra sign-in.

### Boundaries

This module changes only Data API visibility and the developer registry client configuration for
MCP servers already in the Session 07 inventory. A server becomes discoverable only after it
passes the Session 08 runtime decision and moves to the `Production` lifecycle stage.

Azure API Center holds the registry contents, lifecycle state, Data API visibility, and portal
access. Microsoft Entra ID holds sign-in state and the Azure API Center Data Reader assignment. The
repository stores only the client settings and ownership record.

Discovery does not grant access to an MCP server or its tools, and it isn't a per-user allowlist.
Runtime authentication, authorization, approval, and telemetry stay with Session 08 and the server
platform. The separate API Center MCP server at `/mcp` (Standard tier, broader catalog search) is
out of scope.

## Architecture

### Architecture at a glance

The flow starts with the MCP server record in the Session 07 inventory. The server owner and
security owner complete the Session 08 runtime checks. The API Center configuration owner then
sets the record's lifecycle stage to `Production` and configures Data API visibility with two
built-in conditions: `API type = MCP` and `Lifecycle stage = Production`.

The documented registry endpoint is:

```text
https://<api-center-name>.data.<region>.azure-apicenter.ms/workspaces/default/v0.1/servers
```

Use that path exactly. The same Microsoft Learn page currently shows a shortened example that
omits `/workspaces`; the documented endpoint format includes it.

Developer clients authenticate through Microsoft Entra ID. The developer access group has Azure API
Center Data Reader at the API Center resource scope. `registry-client-settings.json` records the
delegated data-plane scope and references the portal application and tenant values in the approved
configuration system.

The client or approved adapter reads the registry and receives MCP server metadata, including
names, remotes or packages, transports, and optional `_meta` values. The operational check reads
each response page, compares `server.name` with the ownership record, and stops if an approved name
is missing or another name appears.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
|---|---|---|---|
| Discovery endpoint | Default-workspace MCP registry endpoint ending in `/v0.1/servers` | Uses the current Microsoft-documented registry path | The page's shortened example is inconsistent; nondefault workspace paths are not documented |
| Developer authentication | Microsoft Entra ID with Azure API Center Data Reader at the API Center scope | Avoids anonymous catalog access and uses the documented data-plane role | The role reads every record that matches the global visibility filter |
| Approval signal | Built-in `Production` lifecycle stage plus MCP API type | Works with documented built-in visibility conditions | Lifecycle becomes a release gate and must be governed carefully |
| Client configuration | Client-neutral JSON settings | The same settings can support different approved clients | A client-specific adapter must map them to the current client setting |
| Restore | Portal-led restore using the recorded prior configuration reference | Avoids guessing an unsupported management API | Restore is an owner action rather than one command |

### Architecture guidance

Use [Register and discover MCP servers in your API
inventory](https://learn.microsoft.com/en-us/azure/api-center/register-discover-mcp-server) for the
registry endpoint, supported client categories, remote and local MCP records, and optional `_meta`
mapping.

Use [Set up and customize your API Center
portal](https://learn.microsoft.com/en-us/azure/api-center/set-up-api-center-portal) for Microsoft
Entra access, the Azure API Center Data Reader role, anonymous-access risk, and the global Data API
visibility boundary.

Use [Enable and view Azure API Center portal view - VS Code
extension](https://learn.microsoft.com/en-us/azure/api-center/enable-api-center-portal-vs-code-extension)
when the developer path uses the Azure API Center extension for Visual Studio Code and GitHub
Copilot agent-mode tools. That extension path needs the runtime host, portal application client ID,
and tenant ID supplied through the approved configuration system.

## Before you start

Confirm these prerequisites:

- The API Center name, region, resource-scope alias, and default workspace belong to the approved
  nonproduction or production discovery boundary.
- The approved MCP server record exists in Session 06 and has an owner, environment, deployment or
  package, transport, and lifecycle decision.
- Session 08 has completed runtime authentication, authorization, tool, and telemetry decisions.
- The API Center portal uses Microsoft Entra ID. Anonymous access is off.
- The developer group has Azure API Center Data Reader at the exact API Center resource scope.
- The client owner knows which supported client or adapter reads `registry-client-settings.json`.
- The API Center configuration owner has recorded the prior Data API visibility configuration in
  the approved change system.
- The approved OAuth client can supply a short-lived token for
  `https://azure-apicenter.net/Data.Read.All` through an environment variable without writing it to
  disk.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Runtime | [`artifacts/registry-client-settings.json`](artifacts/registry-client-settings.json) | The developer-client configuration pipeline or approved client adapter |
| Record | [`artifacts/registry-ownership.json`](artifacts/registry-ownership.json) | The API Center configuration owner and MCP server owners |

After resolving artifact values in the approved private configuration path, run preflight in
**Implement › 1. Complete the client and ownership records**. It checks the exact endpoint path,
default workspace, Microsoft Entra mode, Azure API Center Data Reader role, delegated scope,
global visibility conditions, approved names, and ownership markers. A read-only deployment preview
is unsupported for Data API visibility, so the Azure portal preview is the required change review.

## Decisions and stop conditions

### Discovery scope

Choose the API Center that already owns the Session 07 inventory. Record its name and region in the
private copy of `registry-client-settings.json`. The generated endpoint must end with
`/workspaces/default/v0.1/servers`.

Stop if the proposed path uses the portal hostname, the `/mcp` catalog endpoint, a shortened
`/default/v0.1/servers` path, a nondefault workspace, or an undocumented API version.

### Approval and lifecycle

The server owner, runtime owner, and security owner decide when an MCP record may use the
`Production` lifecycle stage. The ownership record names those roles and the next review date.
Design, Preview, Deprecated, and ownerless records stay outside the discoverable condition.

Stop if `Production` is already used for another meaning, if a synchronized source can overwrite
the lifecycle value without the approval path, or if the portal preview contains a record that is
not in `approvedServers`.

### Authentication and client access

Use Microsoft Entra ID. The developer group receives Azure API Center Data Reader at the exact API
Center resource scope. The client configuration pipeline resolves the portal application and
tenant references from its approved private store.

Stop if anonymous access is enabled, if the role is assigned above the intended API Center scope,
or if a client requires a secret to be committed in its configuration file.

### Visibility boundary

Configure two built-in Data API visibility conditions:

1. `API type` equals `MCP`.
2. `Lifecycle stage` equals `Production`.

Review the portal preview before saving. Microsoft documents that visibility applies globally to
all users and related data-plane consumption features.

Stop if the current portal cannot express both conditions, if the conditions are combined in a way
that exposes either all MCP records or all Production APIs, or if custom metadata is being treated
as an authorization rule.

### Client integration

`registry-client-settings.json` is input to the approved client adapter. The client owner maps
`registry.endpoint` and the Microsoft Entra references to the client's current supported settings.

Stop if the client silently falls back to a public registry, merges another registry without an
owner decision, or stores an access token in source control.

## Implement

### 1. Complete the client and ownership records

Resolve every `__REQUIRED_*__` value in the approved private configuration path. Add one
`approvedServers` entry for every server that passed the Session 08 runtime decision. Keep the
approved names identical in both JSON files.

Run preflight:

```powershell
$targetScope = "<approved API Center discovery scope alias>"
.\scripts\preflight.ps1 -TargetScope $targetScope
```

```bash
target_scope="<approved API Center discovery scope alias>"
./scripts/preflight.sh --target-scope "$target_scope"
```

### 2. Set the approved lifecycle stage

In the Azure portal, open the approved API Center and select Inventory > Assets. Open every MCP
server in the ownership record and set its approved version lifecycle to **Production** through the
normal inventory change path.

Keep candidate servers at Design or Preview. Mark retired servers Deprecated before
their next client discovery window.

### 3. Configure developer access

Under Consumption > Portal settings, confirm that Microsoft Entra ID is configured and
anonymous access is disabled. Confirm the developer group has **Azure API Center Data Reader** at
the exact API Center resource scope.

This role controls access to visible data-plane records. The discovered MCP server's runtime
authorization controls server and tool calls.

### 4. Configure Data API visibility

Under Consumption > Data API settings, configure API visibility with the two built-in
conditions recorded in `registry-ownership.json`. Use the portal preview to compare the visible MCP
records with `approvedServers`.

Save the change only when every previewed MCP server name is approved and every approved name is
present.

### 5. Configure the client path

For Visual Studio Code, GitHub Copilot, or another registry-capable tool, map
`registry.endpoint` into the client's current MCP registry setting. If the Azure API Center
extension for Visual Studio Code is the chosen path, also provide the data-plane host, portal
application client ID, and tenant ID from the approved configuration system.

Use only the documented API Center data-plane endpoint.

### 6. Check live discovery

Have the approved OAuth credential helper place a short-lived token for the documented API Center
data-plane delegated scope in the `API_CENTER_ACCESS_TOKEN` environment variable. The scripts read
the token from the environment and do not print or retain it.

```powershell
.\scripts\check-discovery.ps1
```

```bash
./scripts/check-discovery.sh
```

The scripts follow cursor pagination, compare returned `server.name` values with the ownership
record, and avoid printing unexpected names.

## Confirm the result

Run the live discovery check from a developer network path with the same Microsoft Entra access
boundary used by the supported client.

The script reports every returned server name as approved, confirms every approved server name is
present, reports zero unapproved server names, and reads every registry page. The client can then
display the approved server record without receiving an MCP server credential.

## After implementation

Keep both JSON files with the API Center operating configuration. The API Center configuration
owner owns Data API visibility and the registry metadata mapping. Server owners own lifecycle and
review dates. The client configuration owner maintains the adapter that maps `registry-client-settings.json`
to the current Visual Studio Code, GitHub Copilot, or other supported client setting.

Run `check-discovery` after a lifecycle change, visibility change, registry-client update, or MCP
record synchronization. An unexpected count stops the rollout. Remove the registry from managed
client configuration until the API Center owner restores the allowlist.

Restore uses the approved portal change path. First remove or disable the registry entry in the
client-management system. Then restore the prior Data API visibility configuration referenced in
`registry-ownership.json`. Return affected MCP records to their previous lifecycle stage only when
the inventory owner approves that change. Leave the Session 07 inventory and Session 08 runtime
controls in place.

No removal script is included. Microsoft Learn does not document a stable management API for Data
API visibility, and a script could not prove that it was restoring the recorded prior state.
