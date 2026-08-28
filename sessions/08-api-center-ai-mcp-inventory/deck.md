---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation - Session 08</p>

# Azure API Center and the AI/MCP inventory

210 minutes - Three required entries in a searchable design-time inventory

<!-- Notes: Session 07 established runtime enforcement. This session adds three selected assets with owners and required metadata. -->

---

## Control objective

> Add three selected assets to API Center: deploy the Session 05 agent API, synchronize the Session 07 APIM API, and register an approved remote MCP server.

Give each entry an owner, lifecycle state, classification, and runtime location.

### Result check

- API Center adds the [Session 05](../05-governed-agent-baseline/) agent API and synchronizes the [Session 07](../07-apim-ai-gateway/) APIM API.
- The API program owner registers the approved remote MCP server through the native asset flow.
- Each entry contains twelve required governance properties.
- The read-only check finds no missing metadata in the governed inventory.

<!-- Notes: This is a design-time control. It does not replace runtime authorization. -->

---

## Implementation outcomes

1. Deploy a tagged API Center with required metadata.
2. Synchronize the [Session 07](../07-apim-ai-gateway/) APIM source through managed identity.
3. Add the [Session 05](../05-governed-agent-baseline/) agent API and register the approved remote MCP server.
4. Keep the direct agent definition in source control. Maintain API Center metadata for synchronized and portal-added assets.
5. Check the three required entries and APIM integration state. Review native MCP health manually.

<!-- Notes: Keep the discussion anchored to the current inventory, not every API Center feature. -->

---

## Why it matters

The three required entries show developers and owners what is available, where it runs, and who must review or retire it.

Missing ownership and lifecycle decisions become visible before an asset is treated as approved.

<!-- Notes: Keep the value tied to these three entries, not the whole API estate. -->

---

## Control boundaries

- Scope covers the Session 05 agent API, Session 07 APIM API, and the approved remote MCP server.
- API Center imports every API from the linked APIM instance. Owners must complete required metadata for any additional synchronized APIs before the link is created; they are outside this session's required result.
- API Center stores their approved design-time inventory metadata.
- Foundry, APIM, and the MCP server report their own runtime state.
- API Center inventories and supports discovery; it does not authorize or block runtime calls.
- Session 09 governs MCP tool use.
- Separate optional modules cover Foundry Toolbox reuse, API Center registry discovery, and A2A inventory. None is enabled here.

<!-- Notes: Inventory is useful because its runtime limits are explicit. -->

---

<!-- _class: section-divider -->

# Design-time inventory, runtime enforcement

Definitions and ownership flow into API Center. Live requests go through APIM.

API Center answers **what exists and who owns it**. APIM controls **what happens on each call**.

<!-- Notes: The services are complementary, not interchangeable. -->

---

## Two products, distinct jobs

<div class="cards">
<div class="card">

![Azure API Center](assets/icons/microsoft/azure-api-center.svg)

### Azure API Center

Stores the design-time entry and owner metadata used for discovery. It neither receives nor enforces
runtime traffic.

</div>
<div class="card">

![Azure API Management](assets/icons/microsoft/azure-api-management.svg)

### Azure API Management

Receives live requests, checks callers and policy, then replaces authorization before sending the
request to a backend.

</div>
</div>

<!-- Notes: Never describe API Center as a gateway or APIM as the catalog source of truth. -->

---

## Architecture overview

<!-- _class: diagram -->

![Direct agent registration, one-way APIM synchronization, and manual remote MCP registration converge on API Center while APIM enforces the separate runtime request path](assets/diagrams/api-center-inventory-flow.svg)

<!-- Notes: Follow the three inbound paths. The control ends at inventory and source health, before runtime enforcement. -->

---

## What this means

API Center stores design-time metadata for the three required assets. Bicep adds the Foundry agent
definition. A read-only managed identity imports every API from the APIM instance, and the API
program owner registers the approved remote MCP server in the portal.

API Center stores the resulting metadata. Foundry, APIM, and the MCP server keep their runtime
state. This session covers inventory and source health. Live requests stay on the APIM path.
Session 09 uses the MCP entry and runtime location.

---

## The inventory model

```text
API Center
├─ checks every entry against the required metadata schema
├─ groups the selected entries in the default workspace
├─ associates the agent with its Foundry nonproduction environment
├─ adds the Session 05 agent API, version, definition, and deployment
├─ reads APIs through the Session 07 APIM source integration
└─ registers the approved remote MCP server through the native asset type
```

The API Center itself carries the [Session 01](../01-platform-baseline/) ownership and lifecycle tags.

---

<!-- _class: decision -->

## Decision 1 - Which assets to add to API Center

Resolve before deployment:

1. Is this API Center the approved inventory for these assets?
2. Is the APIM source boundary approved?
3. Who owns every synchronized API?
4. Must another catalog remain the approved inventory for any of these assets?

Stop if linking APIM would create entries with no metadata owner or leave two catalogs claiming to
be the approved inventory.

<!-- Notes: A broad integration is not harmless if nobody owns the imported entries. -->

---

## Plan and region are explicit decisions

| Decision | Stop condition |
|---|---|
| API Center region | Not advertised by the live provider |
| Free plan | Limits or lack of Microsoft support are unacceptable |
| Standard plan | APIM tier is ineligible and separate cost is unapproved |

The stable `2024-03-01` Bicep service resource does not expose plan selection. Confirm or upgrade the approved plan in the portal after linking APIM.

<!-- Notes: The linked Standard benefit applies only to documented APIM tiers. -->

---

## Twelve required properties

| Ownership and use | Risk and lifecycle |
|---|---|
| Business owner | Data classification |
| Technical owner | Residency profile |
| AI asset kind | Risk tier |
| Approved consumers | Evaluation results URL |
| Model/provider | Last review date |
| Implementation session | Expiry date |

The API program owner defines the schema. Asset, data, and risk owners keep their values current.

Required metadata makes missing decisions visible. It does not grant access.

<!-- Notes: Use role or group names instead of personal data where possible. -->

---

<!-- _class: decision -->

## Decision 2 - Metadata quality

Stop when:

- An owner is only a free-text placeholder.
- Classification or residency is unresolved.
- The evaluation link has no accountable destination.
- Expiry has no operating response.
- Approved consumers are defined as “everyone.”

Dates use `YYYY-MM-DD`; expiry must be later than the last review.

At expiry, the technical owner renews after review, retires and hides the entry from discovery, or quarantines it from approved use within one business day.

<!-- Notes: The catalog is useful only when the metadata changes operating behavior. -->

---

## APIM integration is read-only and one-way

![Azure API Management](assets/icons/microsoft/azure-api-management.svg)

- API Center gets **API Management Service Reader Role** on the Session 07 APIM instance.
- The GA integration imports APIs, definitions, environments, and deployments.
- APIM changes synchronize to API Center; catalog edits do not flow back.
- Initial synchronization usually takes minutes but can take up to 24 hours.

Do not create a duplicate API entry while synchronization is pending.

<!-- Notes: The identity cannot change APIM runtime configuration. -->

---

## Agent endpoint registration

![Microsoft Foundry Agent Service](assets/icons/microsoft/foundry-agent-service.svg)

Stable Bicep registers:

- One REST API record
- Version `1.0.0` in `testing`
- One OpenAPI definition
- One Foundry nonproduction deployment
- Runtime URL supplied only at deployment

The definition contains no committed server URL.

<!-- Notes: The direct endpoint entry remains useful even though clients should use APIM. -->

---

<!-- _class: decision -->

## Decision 3 - Remote MCP server

The MCP server entry requires:

- Existing remote, read-only server
- Approved HTTPS Streamable HTTP endpoint
- Runtime owner and approved consumers
- Classification, residency, and risk tier
- Review, expiry, and evaluation destination

Stop for local `stdio`, embedded credentials, or write-capable tools. [Session 09](../09-mcp-tool-security/) governs tool use.

<!-- Notes: Registration is inventory, not approval for production or consequential writes. -->

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Chosen approach | Benefit | Cost |
|---|---|---|---|
| APIM ingestion | One-way synchronization with reader access | Definitions follow APIM without write rights | Sync can take 24 hours and imports the whole instance |
| MCP registration | Native portal flow with metadata maintained in API Center | Uses the supported MCP asset model | Manual entry remains |
| Runtime state | Keep it in Foundry, APIM, and MCP | The catalog does not pretend to be health monitoring | Owners update API Center metadata after changes |
| Inventory scope | Three required assets | Clear ownership boundary | Other synchronized APIs need metadata but stay outside this session's required result |

<!-- Notes: Revisit portal entry when Microsoft publishes a stable MCP resource contract. -->

---

## Definition quality

API Center automatically analyzes OpenAPI and AsyncAPI definitions with a managed Spectral baseline.

The saved rules add:

- Operation descriptions
- Operation IDs
- Success responses
- Resource-oriented paths

Test custom rules locally before applying them to a managed analysis profile.

<!-- Notes: Lint findings guide correction; they are not runtime safety controls. -->

---

## Files used to deploy and check the inventory

```text
api-center/
  main.bicep
  apim-reader.bicep
  metadata-schemas.json
  agent-api-definition.json
catalog/
  specs/policy-assistant-agent.openapi.json
environments/sandbox.json
scripts/
  preflight.ps1
  deploy.ps1
  check-inventory.ps1
  manual removal guidance
```

<!-- Notes: Runtime URLs and credentials remain outside source control. -->

---

<!-- _class: implementation -->

## Create the approved AI/MCP inventory

Use two delivery windows. Window one deploys and links the source. Window two resumes after APIM synchronization to update metadata and confirm the result.

The 210 minutes covers active work in both windows. It does not include the wait of up to 24 hours.

Timebox: 210 minutes

1. Resolve scope, ownership, metadata, region, and runtime decisions.
2. Confirm Contributor on the API Center resource group and time-bound User Access Administrator on the approved APIM instance.
3. Run preflight and inspect the ARM `what-if`.
4. Deploy API Center and link the APIM source.
5. Set the synchronized API metadata in API Center.
6. Register the native remote MCP server.
7. Run the read-only inventory check.

<!-- Notes: If synchronization is pending, stop and resume; do not create a duplicate entry. -->

---

## Preflight safety gates

- All metadata values are complete before window one.

- Every required decision sentinel is resolved.
- All JSON and OpenAPI artifacts parse.
- Twelve required metadata schemas are present.
- Runtime URLs are remote HTTPS values and remain outside source.
- The GA APIM integration command passes preflight.
- The region is advertised for API Center.
- The approved APIM instance, tier, Session 07 marker, and reader role match.
- Existing names are absent or carry the Session 08 marker.

<!-- Notes: Preflight compiles Bicep and ends with a resource-group what-if. -->

---

## Apply the control

```powershell
.\scripts\deploy.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -Session05AgentBaseUrl $session05AgentBaseUrl `
  -RemoteMcpServerUrl $remoteMcpServerUrl
```

Then maintain the synchronized APIM metadata and register the MCP server in API Center.

Expected state: one marked inventory with the three required entries. Do not commit a runtime URL.

<!-- Notes: The MCP runtime itself is not changed. -->

---

## Confirm the result

Set `$remoteMcpServerTitle` to the exact title assigned during the API Center MCP registration.

```powershell
.\scripts\check-inventory.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -RemoteMcpServerTitle $remoteMcpServerTitle
```

Expected result:

- The agent API, APIM API, and MCP server each appear exactly once.
- The three required entries have all 12 required properties. Any additional APIs synchronized from the linked APIM instance also need complete metadata before the source is linked.
- The script reports `PASS` and writes no export.

<!-- Notes: This is the single visible standard-mode check. -->

---

## Live state and ownership

| Live state | Owner |
|---|---|
| Inventory scope and metadata schema | API program owner |
| Business, technical, review, and expiry values | Asset owners |
| Classification, residency, and risk tier | Data and risk owners |
| APIM source integration and reader assignment | APIM owner |
| OpenAPI definition and style rules | API developers |

Removal deletes only the marked API Center and APIM reader assignment.

<!-- Notes: APIM, Foundry, and the MCP runtime remain. -->

---

## Recap

- Add the three required assets: direct agent API, synchronized APIM API, and remote MCP server.
- Require the same metadata for the direct agent, synchronized APIM API, and remote MCP server.
- Assign API Management Service Reader Role to the API Center managed identity on the Session 07 APIM instance.
- Run managed definition analysis and the missing-metadata check.

Next, constrain MCP identities, tools, arguments, outputs, and side effects in [Session 09](../09-mcp-tool-security/).

<!-- Notes: The registry now knows what exists; the next session governs what tools can do. -->

---

<!-- _class: closing -->

# Thank you!

<!-- Notes: Close on owned discovery and the transition to MCP runtime security. -->
