# Claude Code and Desktop through a Foundry AI gateway

## Module scope

### What we will do

Put an identity-controlled gateway between Claude developer tools and Foundry.
Configure one native Anthropic API in Azure API Management, then connect Claude
Code and Claude Desktop. An assigned user receives a streaming model response;
APIM rejects an invalid identity or an unassigned model before calling Foundry.

### Why it matters

Developer-managed provider keys make individual access and spend difficult to
control. APIM validates the signed-in user, applies a monthly model budget, and
uses its own managed identity to call Foundry.

### Boundaries

This optional module extends **Control live AI traffic**, beside the numbered
sessions. It configures an existing nonproduction APIM instance,
two Entra applications, and managed client settings. Live Azure and Entra state
remains authoritative. This route invokes Claude models directly; it does not
deploy a Foundry Agent Service agent or govern local tools and MCP calls.
The operations owner takes over usage monitoring and client rollout.

## Architecture

### Architecture at a glance

Claude Code obtains an Entra access token through an Azure CLI helper. Desktop
signs in through the browser with authorization code and PKCE, then sends an
Entra ID token. Both clients call the same HTTPS gateway base URL.

```text
Claude Code / Claude Desktop
  -> optional Application Gateway WAF
  -> APIM: validate client -> resolve budget -> enforce token quota
  -> Foundry /anthropic/v1/messages, authenticated with APIM managed identity
```

Entra authenticates the user. APIM validates the issued token against the exact
tenant and application, requires `Gateway.Invoke`, and uses normalized `upn`
plus model as the monthly counter key. The policy removes client key headers
and replaces `Authorization` before forwarding to Foundry.

The backend is `https://<foundry-resource>.services.ai.azure.com/anthropic`.
If the APIM API suffix is `foundry`, both clients use
`https://<gateway-hostname>/foundry`. APIM removes its API suffix when it builds
the backend path, so `/foundry/v1/messages` reaches `/anthropic/v1/messages`.
Application Gateway, when used, must preserve that mapping and the query string.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
| --- | --- | --- | --- |
| Protocol | Native Anthropic Messages passthrough | Preserves tools, beta fields, and streaming | OpenAI-compatible import is a different protocol |
| Caller tokens | Separate Code access-token and Desktop ID-token validators | Each audience has its own claim contract | Desktop ID-token acceptance is specific to this documented gateway integration |
| Backend identity | APIM managed identity | No provider keys on developer devices | APIM acts as a shared principal; Foundry does not authorize the end user |
| Budgets | API-included fragment with defaults and UPN overrides | Applies without relying on product policy selection | UPN changes can create a new balance; counters are gateway-local |
| Network | Existing approved path, optional WAF | Avoids deploying a second gateway just for this module | Public APIM must be restricted if WAF is the approved sole entry point |

The token policy limits prompt and completion usage. Streaming counts are
estimated, and concurrent calls can exceed a quota before their responses are
processed. **A token quota is not a hard currency budget.** Cache-related usage
and billed Claude Consumption Units need separate cost reconciliation.

### Architecture guidance

- [Deploy Claude models in Foundry](https://learn.microsoft.com/azure/foundry/foundry-models/how-to/use-foundry-models-claude) defines the hosting choices, deployment names, endpoint, and Entra authentication.
- [APIM token limits](https://learn.microsoft.com/en-us/azure/api-management/llm-token-limit-policy) explains Anthropic support on v2 tiers and counter limits.
- [APIM subscriptions and policy context](https://learn.microsoft.com/en-us/azure/api-management/api-management-subscriptions) explains why these budgets are included at API scope.

## Before you start

The platform owner confirms an existing APIM **Basic v2, Standard v2, or Premium
v2** instance with system-assigned managed identity. Do not infer network,
zone, or multi-region support from the word "v2"; approve the actual tier and
region capabilities for this route.

The Foundry owner confirms Marketplace eligibility, terms, selected model
versions, and where each deployment is hosted. Claude models do not have to be
hosted on Azure. Hosting location does not by itself imply single-region
processing: confirm Global or Data Zone scope against the residency decision.
Use the model card and deployment details, not a client alias, as the model
authority.

The APIM operator needs time-bound **Contributor** on the exact APIM resource
group and **Reader** on the Foundry resource for preflight. The role-assignment
owner needs **User Access Administrator** on the
Foundry resource. That owner grants APIM **Cognitive Services User**, scoped
to the Foundry resource, for the documented keyless inference path. The Entra
owner needs **Application Administrator** to configure the dedicated apps,
enterprise-app assignments, and delegated consent.

Developers need Azure CLI for Code. Desktop needs third-party inference
configuration and version **1.6889.0 or later** for interactive SSO. The
endpoint-management owner confirms the supported build and managed-setting
locations on each device platform.

Use the gateway design principles from
[Session 06](../../../sessions/06-apim-ai-gateway/implementation/README.md).
Its Responses API, agent-specific role, and Content Safety policy are for a
different backend. Do not apply them unchanged to this Messages API.

### Implementation files

| Type | File | Consumer |
| --- | --- | --- |
| Record | [gateway-inputs.json](artifacts/gateway-inputs.json) | The preflight scripts and gateway operator |
| Deployment | [api-policy.xml](artifacts/api-policy.xml) | The API Management gateway runtime |
| Deployment | [budget-fragment.xml](artifacts/budget-fragment.xml) | The API Management gateway runtime |
| Runtime | [claude-code-settings.json](artifacts/claude-code-settings.json) | The endpoint-management owner and Claude Code |
| Runtime | [get-entra-token.sh](artifacts/get-entra-token.sh) | Claude Code on Bash-capable developer devices |
| Runtime | [get-entra-token.ps1](artifacts/get-entra-token.ps1) | Claude Code on PowerShell developer devices |

Copy the artifacts to a protected customer working directory outside source
control. Replace every decision sentinel in those copies. Keep tenant IDs,
resource names, endpoints, UPN overrides, tokens, and MDM exports out of this
repository. Install Python 3 and Azure CLI on the operator workstation.

## Decisions and stop conditions

Record the named owners and approved resources in the customer copy of
`gateway-inputs.json`. The approval flags record decisions Azure cannot infer;
set them to true after the responsible owner has checked the corresponding
item below. Preflight performs read-only resource and file checks. It does not
approve the identity design, WAF rules, or data-handling policy.

| Owner decision | Inspect before approving | Stop when |
| --- | --- | --- |
| Foundry hosting | Model deployment details, Marketplace terms, region scope | Hosting or processing location differs from the residency approval |
| Identity | Two single-tenant apps, token claims, consent, assigned roles | Audience, issuer, or role differs from the policy |
| Budget | Exact lowercase deployment names and monthly allowances | A default or override lacks finance approval |
| Telemetry | Application Insights logger, body bytes, allowed headers, access and retention | A token, prompt, or response body would be logged |
| Network | APIM-to-Foundry reachability and approved client entry point | Clients can bypass a required WAF, or a private backend is unreachable |
| Restore | Prior API policy/settings and client configuration in the approved change store | Restoring the route would remove an unrelated control |

Budget precedence is **explicit user-model override, then model default, then
zero**. An explicit zero blocks that pair. A user absent from the override map
receives defaults only after identity authorization succeeds. To block all
access, remove the user's app-role assignment or set every enabled model to
zero. These examples are token allowances, not recommended spending limits.

UPN is readable but mutable. A rename starts a different counter unless you
plan the transition. For durable identity, change the maps and counter
consistently to `tid:oid` before rollout; do not mix identity schemes between
clients or change schemes mid-period without a budget decision.

The shipped Code validator expects a **v1 access token** with audience
`api://<gateway-api-client-id>`. Configure the API registration to issue v1
tokens and verify the actual result locally. Azure CLI does not determine the
resource's token version. If the API issues v2 access tokens, update that
validator's issuer, discovery URL, audience, and identity claim contract
together. Do not add a broad audience fallback.

The backend policy requests `https://ai.azure.com`, following the current
Foundry Claude guidance. It does not reuse the client's gateway audience.
If that resource token is rejected by the selected deployment, stop and resolve
the hosting/authentication contract with the platform owner.

## Implement

### 1. Prepare Foundry and the approved network path

In Foundry, confirm that each selected Claude deployment is **Succeeded**.
Record its deployment name, hosting option, and model version in the approved
change record. Test a small Messages request through the platform owner's
existing Entra-authorized path before configuring APIM.

Enable APIM's system-assigned managed identity if it is not already enabled.
In Foundry **Access control (IAM)**, grant that identity **Cognitive Services
User** on the resource. Allow role propagation before diagnosing a failed
backend call. Developers do not need their own Foundry role for this route.

If using Application Gateway WAF, use an approved WAF_v2 listener and TLS
certificate. Route to APIM with the correct backend hostname, preserve the API
suffix, and confirm probe health. Restrict APIM to that gateway using the
approved private path or an IP filter with the gateway's observed egress IP.
An unrestricted public APIM endpoint bypasses WAF inspection even though the
API's identity and budget policy still applies.

Start WAF rule tuning in Detection mode with representative non-sensitive
code prompts. Check body-inspection limits and oversized-body behavior.
Use narrow, logged exclusions for demonstrated false positives before
Prevention mode. WAF is not a model safety filter and does not inspect streamed
responses as a prompt/response moderation service.

### 2. Configure the two Entra applications

Create a single-tenant **Gateway API** registration. Set Application ID URI to
`api://<gateway-api-client-id>`, expose admin-consented delegated scope
`AiGateway.Invoke`, and preauthorize Microsoft Azure CLI client
`04b07795-8ddb-461a-bbee-02f9e1bf7b46` for that scope.
Define app role `Gateway.Invoke` for Users/Groups. On the Enterprise
application, enable **Assignment required** and assign approved users or
groups to that role. The identity owner grants the delegated consent required
by the tenant; a noninteractive token helper cannot complete consent.

Create a separate single-tenant **Claude Desktop Gateway** public-client
registration. Under **Mobile and desktop applications**, add exactly
`http://127.0.0.1/callback`, with no fixed port. Create no secret or certificate.
Add optional ID-token claim `upn`, define Users/Groups app role `Gateway.Invoke`,
enable **Assignment required**, and assign the approved cohort to that role.

Inspect token claims locally without sending tokens to a web decoder or
retaining them. Confirm the following contract before setting `identityApproved`.

| Claim | Code access token | Desktop ID token |
| --- | --- | --- |
| `iss` | `https://sts.windows.net/<tenant-id>/` | `https://login.microsoftonline.com/<tenant-id>/v2.0` |
| `aud` | `api://<gateway-api-client-id>` | Bare Desktop client ID |
| `tid` | Approved tenant ID | Same tenant ID |
| `roles` | Contains `Gateway.Invoke` | Contains `Gateway.Invoke` |
| `upn` | Nonempty user UPN | Nonempty optional user UPN |

APIM's Developer Portal OAuth configuration does not establish this trust.
The two `validate-jwt` branches in the API policy establish it.

### 3. Complete the files and run preflight

In the customer copies, replace the tenant and app IDs in the policy and both
helpers. Set Code's base URL to the approved route including its API suffix.
Map each default model alias to an exact lowercase Foundry deployment name.
Set the same names in the budget fragment and approve the token allowances.
Add normalized UPN overrides when needed, using model-to-integer JSON objects.

Set `apiKeyHelper` to the installed command: an executable Bash helper on
macOS/Linux, or `pwsh -NoProfile -File` followed by the quoted installed
PowerShell helper path on Windows. Preserve unrelated device settings when
merging the supplied JSON.

From this module's `implementation` directory, pass the customer copy's
artifact directory directly to preflight:

```powershell
.\scripts\preflight.ps1 -ArtifactsDir "C:\approved-work\claude-gateway"
```

```bash
bash scripts/preflight.sh --artifacts-dir "$HOME/approved-work/claude-gateway"
```

Preflight rejects unresolved decisions, unapproved flags, a different active
Azure subscription or tenant, a classic APIM tier, a missing managed identity,
a missing Foundry resource role, and missing deployments. It checks file
syntax and alignment, not APIM's C# policy compilation.

**Portal policy edits have no ARM what-if preview.** Before saving, the gateway
owner reviews the exact change against the stored prior policy and uses the
portal's effective-policy view to inspect inherited controls. The supplied
backend section sets one nonbuffering `forward-request` instead of inheriting
another forwarding policy. Retain any required inherited backend behavior
explicitly, without introducing a second forward.

### 4. Configure APIM

Create backend `claude-foundry-backend`, protocol HTTPS, with runtime URL
`https://<foundry-resource>.services.ai.azure.com/anthropic`.
Create a **Language Model API / passthrough API**, not an OpenAI-compatible API.
Use API suffix `foundry` or the suffix already approved in the base URL.
Disable **Subscription required**. A product can group the API, but must not
be the identity or budget authority.

Expose `POST /v1/messages` and `POST /v1/messages/count_tokens`. If the wizard
created wildcard operations, remove them and add these two explicit POST
operations with the same paths. Do not open unrelated endpoints. The
`?beta=true` query on Messages must still route normally. Desktop model
discovery is configured explicitly, so this route does not require
`GET /v1/models`; Code's optional `HEAD /api/hello` probe can return 404.

Under **Policy fragments**, import the customer copy of `budget-fragment.xml`
as `claude-foundry-budgets`. Apply the customer copy of `api-policy.xml` at
**API / All operations** scope. Save only after the portal accepts its policy
expressions. The included fragment supplies budgets for every API call
regardless of product context.

Review the full inherited policy. Keep `anthropic-version` and
`anthropic-beta` unchanged, preserve new Anthropic headers and all body fields,
including `cache_control`. Remove transformations that reconstruct Messages
bodies or strip unfamiliar beta values. `preserveContent: true` lets the
policy read the model without consuming the request body.

The token and metric policies run on Messages, not on count_tokens. Both
operations still require an authorized identity and a positive model budget.
The backend `forward-request` disables response buffering. Keep SSE events,
including pings and final usage events, in order through every proxy.

Configure an approved Application Insights logger and API diagnostics.
Set request and response body logging to **0 bytes** and diagnostic verbosity
to **information** for the identity trace. Do not log `Authorization`,
`x-api-key`, cookies, or subscription keys. UPN and object ID are personal
data: approve access and retention. Token metrics are operational estimates;
do not treat them as the invoice.

Enable Application Insights custom metrics with dimensions for the token policy.
APIM limits each dimension to 100 unique values and each namespace to 1,000
active time series; new values beyond those limits are discarded. The per-user
metric is suitable for a bounded pilot. Before a larger rollout, use a bounded
metric dimension and an approved attribution pipeline rather than treating the
UPN metric as a complete chargeback record.

### 5. Connect Claude Code

Install the configured helper with the device's normal managed-file permissions.
Merge the configured settings into the approved Claude Code configuration.
The helper prints only a token to stdout and sends errors to stderr. It retries
once after interactive sign-in to the configured tenant.

Remove conflicting `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN`, and direct
Foundry/provider-mode variables from the managed configuration and launch
environment. This is the generic Messages gateway path selected by
`ANTHROPIC_BASE_URL`, not direct Foundry mode.

Start Code and inspect `/status`: the API base URL must be the gateway.
Confirm `/model` resolves to the managed deployment names. Reopen the client
after changing settings. If the token helper needs initial consent or browser
sign-in, complete it interactively before unattended use.

### 6. Connect Claude Desktop

Follow [Desktop's gateway configuration](https://claude.com/docs/third-party/claude-desktop/gateway)
for the installed supported build. Open **Developer / Configure Third-Party
Inference** and set:

| Setting | Value |
| --- | --- |
| Inference provider | Gateway |
| Gateway base URL | Same approved URL as Code, including `/foundry` |
| Credential kind | Interactive sign-in |
| Gateway auth scheme | Bearer |
| OIDC client ID | Desktop public-client ID |
| OIDC issuer URL | `https://login.microsoftonline.com/<tenant-id>/v2.0` |
| OIDC scopes | Leave unset to use the documented defaults including `offline_access` |
| Redirect port | Leave unset |
| Models | Explicit approved Foundry deployment names |

Use the configuration window's **Export** command for the MDM `.mobileconfig`
or `.reg` payload. The profile needs both `inferenceCredentialKind: "interactive"`
and `inferenceGatewayOidc`. In MDM, the latter is a JSON-encoded string;
do not recreate it as nested plist or registry keys. If scopes are set
explicitly with the default ID-token mode, include `offline_access` to support
silent refresh. Distribute the profile through the approved device-management
path and restart Desktop.

## Confirm the result

### Intended-path check

With the same assigned user and model, send one small non-sensitive prompt
from Code and one from Desktop. Confirm both return a streaming response and
the gateway trace names the expected user, deployment, and request ID.
Check that the `claude-monthly:<upn>:<model>` budget is shared across clients;
use the returned quota headers through the approved diagnostic view. The
remaining value is an estimate, so compare after both requests complete.

Use this body-free query in the connected Log Analytics workspace:

```kusto
AppTraces
| where TimeGenerated > ago(30m)
| where Message == "Authenticated inference request"
| project TimeGenerated,
    callerUpn = tostring(Properties.callerUpn),
    tenantId = tostring(Properties.tenantId),
    objectId = tostring(Properties.objectId),
    requestId = tostring(Properties.requestId),
    model = tostring(Properties.requestedModel)
```

Confirm the selected deployments also respond through count_tokens. A streaming
response must arrive incrementally through its final `message_delta` and
`message_stop` events. Observe normal token renewal during a pilot: Code must
rerun the helper, and Desktop must refresh or request sign-in according to the
tenant's session policy.

### Blocked-path check

Using the same approved nonproduction route, call Messages with no credential
and a token issued for a different audience. Expect **401** and no Foundry
invocation. An assigned user requesting a model absent from the budget map
receives **403**; malformed model JSON receives **400**. Confirm an unassigned
Desktop user cannot sign in to its Enterprise application.

If WAF is required, call APIM directly from outside the approved gateway path:
the network control must reject it. Confirm a representative code prompt
still passes through the WAF listener.

### Delivery-owner checkpoint

The delivery owner observes both clients succeeding and the blocked path before
authorizing a wider device rollout. Stop if streaming is buffered, claims
differ from the approved contract, telemetry contains payloads, or WAF can be
bypassed. Resolve the failed hop before expanding the cohort.

| Symptom | Inspect |
| --- | --- |
| 401 | Token version, issuer, audience, scope, role, or helper failure |
| 403 | Missing UPN, zero/unmapped budget, or exhausted monthly quota |
| 400 on a new feature | Beta header and paired body fields across proxies |
| 404 | API suffix and exact Foundry deployment name |
| Response arrives at once | APIM forwarding and upstream proxy buffering |
| WAF rejects code | Matched rule, body size, and narrow false-positive exclusion |

## After implementation

The gateway owner operates the API, budget fragment, backend identity, and
body-free diagnostics. The identity owner manages assignments and token
contracts. The client owner maintains the exported Desktop profile and Code
settings. Budget changes use the approved APIM policy change path and are
checked against the effective policy.

Connect attribution and budget alerts to
[Session 11](../../../sessions/11-observability-cost-operations/implementation/README.md).
Reconcile token usage against Marketplace charges. Review quota-denial and
authentication-failure rates, and recheck protocol compatibility after client
or WAF ruleset upgrades.

To restore, the gateway owner reinstates the prior API policy, operations, and
diagnostics from the approved change store. The client owner restores the prior
managed settings through MDM. Restoring a policy does not restore a consumed
quota counter.

To retire, first remove this route from managed clients and disable its API.
Check the `optional-module-claude-foundry-ai-gateway` change marker and exact
scope in the customer record. Remove the module-owned API and fragment only
after confirming no other API uses the fragment or backend. The identity owner
removes only this route's assignments and consent; the role owner removes the
APIM Foundry role only when no remaining workload needs it. Keep the shared
APIM, Foundry deployments, WAF, and telemetry resources.

This gateway controls inference through this route. It does not prevent users
with independent credentials from calling another provider, and it does not
govern Code or Desktop's local tools. Direct-egress features such as fast-mode
checks need a separate network decision.
