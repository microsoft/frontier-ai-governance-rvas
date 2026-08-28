---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation - Session 07</p>

# Azure API Center and the AI/MCP inventory

**240 minutes - One searchable design-time inventory**

<!-- Notes: Session 06 established runtime enforcement. This session records three selected assets with owners and required metadata. -->

---

## Control objective

> Record three selected assets in API Center: the Session 05 agent API, the synchronized Session 06 APIM API, and one approved remote MCP server.

Each record has an owner, lifecycle state, classification, and runtime location.

### Result check

- The [Session 05](../05-governed-agent-baseline/) agent and [Session 06](../06-apim-ai-gateway/) APIM API are inventoried.
- One approved remote MCP server is registered as a native asset.
- Twelve governance properties are required and populated.
- The read-only check finds no missing metadata in the governed inventory.

<!-- Notes: This is a design-time control. It does not replace runtime authorization. -->

---

## Implementation outcomes

1. Deploy a tagged API Center with required metadata.
2. Synchronize the [Session 06](../06-apim-ai-gateway/) APIM source through managed identity.
3. Register the [Session 05](../05-governed-agent-baseline/) agent endpoint and one remote MCP server.
4. Keep one shared metadata source in the API Center operating repository and the APIM reconciliation path.
5. Check required metadata and APIM integration state, then review native MCP health manually.

<!-- Notes: Keep the discussion anchored to the current inventory, not every API Center feature. -->

---

## Why it matters

The three selected records give developers and owners a shared answer to what is available, where it runs, and who must review or retire it.

Missing ownership and lifecycle decisions become visible before an asset is treated as approved.

<!-- Notes: Keep the value tied to these records, not the whole API estate. -->

---

## Control boundaries

- Scope covers the Session 05 agent API, Session 06 APIM API, and one approved remote MCP server.
- API Center is the source of truth for their design-time inventory metadata.
- Foundry, APIM, and the MCP server remain the live source for runtime state.
- API Center inventories and supports discovery; it does not authorize or block runtime calls.
- Session 08 governs MCP tool use.

<!-- Notes: Inventory is useful because its runtime limits are explicit. -->

---

<!-- _class: section-divider -->

# Design-time inventory, runtime enforcement

Definitions and ownership flow into API Center. Live requests flow through APIM.

API Center answers **what exists and who owns it**. APIM controls **what happens on each call**.

<!-- Notes: The services are complementary, not interchangeable. -->

---

## Two products, distinct jobs

<div class="cards">
<div class="card">

![Azure API Center](assets/icons/microsoft/azure-api-center.svg)

### Azure API Center

Holds the design record and owner metadata used for discovery. It neither receives nor enforces
runtime traffic.

</div>
<div class="card">

![Azure API Management](assets/icons/microsoft/azure-api-management.svg)

### Azure API Management

Receives live requests, checks callers and policy, then replaces authorization before it sends the
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

API Center provides one design-time catalog for this governed path. Bicep registers the Foundry
agent definition. A read-only managed identity imports every API from the APIM instance, and the
API program owner registers the approved remote MCP server in the portal.

API Center owns the resulting metadata. Foundry, APIM, and the MCP server keep their runtime state.
The boundary ends at inventory and source health. Live requests stay on the APIM path. Session 08
receives the MCP record and runtime location.

---

## The inventory model

```text
API Center
├─ checks every record against the required metadata schema
├─ groups governed records in the default workspace
├─ associates the agent with its Foundry nonproduction environment
├─ records the Session 05 agent API, version, definition, and deployment
├─ reads APIs through the Session 06 APIM source integration
└─ records the approved remote MCP server through the native asset type
```

The API Center itself carries the [Session 01](../01-platform-baseline/) ownership and lifecycle tags.

---

<!-- _class: decision -->

## Decision 1 - Which assets API Center records

Resolve before deployment:

1. Is this API Center the owned AI inventory?
2. Is the APIM source boundary approved?
3. Who owns every synchronized API?
4. Does another catalog own this record?

Stop if linking APIM would create unowned records or a competing source of truth.

<!-- Notes: A broad integration is not harmless if nobody owns the imported records. -->

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

At expiry, the technical owner renews after review, retires and hides the record from discovery, or quarantines it from approved use within one business day.

<!-- Notes: The catalog is useful only when the metadata changes operating behavior. -->

---

## APIM integration is read-only and one-way

![Azure API Management](assets/icons/microsoft/azure-api-management.svg)

- API Center gets **API Management Service Reader Role** on the Session 06 APIM instance.
- The GA integration imports APIs, definitions, environments, and deployments.
- APIM changes synchronize to API Center; catalog edits do not flow back.
- Initial synchronization usually takes minutes but can take up to 24 hours.

Do not create a duplicate API record while synchronization is pending.

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

<!-- Notes: The direct endpoint record remains useful even though clients should use APIM. -->

---

<!-- _class: decision -->

## Decision 3 - Remote MCP server

The API Center record requires:

- Existing remote, read-only server
- Approved HTTPS Streamable HTTP endpoint
- Runtime owner and approved consumers
- Classification, residency, and risk tier
- Review, expiry, and evaluation destination

Stop for local `stdio`, embedded credentials, or write-capable tools. [Session 08](../08-mcp-tool-security/) governs tool use.

<!-- Notes: Registration is inventory, not approval for production or consequential writes. -->

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Chosen approach | Benefit | Cost |
|---|---|---|---|
| APIM ingestion | One-way synchronization with reader access | Definitions follow APIM without write rights | Sync can take 24 hours and imports the whole instance |
| MCP registration | Native portal flow | Uses the supported MCP asset model | Manual entry remains |
| Runtime state | Keep it in Foundry, APIM, and MCP | The catalog does not pretend to be health monitoring | Owners must reconcile metadata after changes |
| Inventory scope | Three selected assets | Clear ownership boundary | The rest of the estate stays outside this control |

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

## Operational control tree

```text
api-center/
  main.bicep
  apim-reader.bicep
  metadata-schemas.json
catalog/
  catalog-records.json
  specs/policy-assistant-agent.openapi.json
environments/sandbox.json
scripts/
  preflight.ps1
  deploy.ps1
  reconcile-inventory.ps1
  check-inventory.ps1
  manual removal guidance
```

<!-- Notes: Runtime URLs and credentials remain outside source control. -->

---

<!-- _class: implementation -->

## Build the owned AI/MCP inventory

Use two delivery windows. Window one deploys and links the source. Window two resumes after APIM synchronization for reconciliation and confirmation.

The 240 minutes covers active work across both windows, not the wait of up to 24 hours.

**Timebox: 240 minutes**

1. Resolve scope, ownership, metadata, region, and runtime decisions.
2. Confirm **Contributor** on the API Center resource group and time-bound **User Access Administrator** on the approved APIM instance.
3. Run preflight and inspect the ARM `what-if`.
4. Deploy API Center and link the APIM source.
5. Reconcile the synchronized API metadata.
6. Register the native remote MCP server.
7. Run the read-only inventory check.

<!-- Notes: If synchronization is pending, stop and resume; do not create a duplicate record. -->

---

## Preflight safety gates

- All metadata records are complete before window one.

- Every required decision sentinel is resolved.
- All JSON and OpenAPI artifacts parse.
- Twelve required metadata schemas are present.
- Runtime URLs are remote HTTPS values and remain outside source.
- Azure CLI and the GA APIM integration command are available.
- The region is advertised for API Center.
- The approved APIM instance, tier, Session 06 marker, and reader role match.
- Existing names are absent or carry the Session 07 marker.

<!-- Notes: Preflight compiles Bicep and ends with a resource-group what-if. -->

---

## Apply the control

```powershell
.\scripts\deploy.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -Session05AgentBaseUrl $session05AgentBaseUrl `
  -RemoteMcpServerUrl $remoteMcpServerUrl
```

Then reconcile the synchronized APIM record and register the MCP server from the API Center record.

Expected state: one marked inventory with the three selected asset paths and no committed runtime URL.

<!-- Notes: The MCP runtime itself is not changed. -->

---

## Confirm the result

```powershell
.\scripts\check-inventory.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId
```

Expected result:

- Agent API, APIM API, and MCP server each appear exactly once.
- Every API in the governed inventory has all 12 required properties.
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

- Inventory the three selected records: direct agent API, synchronized APIM API, and remote MCP server.
- Require the same metadata for the direct agent, synchronized APIM API, and remote MCP server.
- Assign **API Management Service Reader Role** to the API Center managed identity on the Session 06 APIM instance.
- Run managed definition analysis and the missing-metadata check.

Next: constrain MCP identities, tools, arguments, outputs, and side effects in [Session 08](../08-mcp-tool-security/).

<!-- Notes: The registry now knows what exists; the next session governs what tools can do. -->

---

<!-- _class: closing -->

# Thank you!

<!-- Notes: Close on owned discovery and the transition to MCP runtime security. -->
