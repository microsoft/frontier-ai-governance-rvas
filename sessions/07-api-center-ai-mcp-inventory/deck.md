---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Session 06</p>

# Azure API Center and the AI/MCP inventory

180 minutes · Add three owned assets to a searchable design-time inventory

---

## Why it matters

> Add the Session 04 agent API, synchronize the Session 06 APIM API, and register an approved remote MCP server in API Center.

By the end of the session:

- A tagged API Center holds the direct agent definition and required metadata schema.
- Its managed identity reads the exact Session 06 APIM service.
- The approved remote MCP server is registered through the native portal flow.
- The inventory check finds the three entries once, with their required metadata.

API Center supports discovery. APIM and Session 08 control runtime use.

<!-- Notes: Keep the boundary clear. This is inventory, not runtime authorization. -->

---

<!-- _class: two-column -->

## Architecture

<div class="columns">
<div>

Bicep deploys API Center and the direct agent API.

A one-way APIM integration imports every API from the linked instance. The API Center identity gets **API Management Service Reader Role** at that service scope.

The API program owner registers the remote MCP server in the portal.

API Center owns design metadata. Foundry, APIM, and the MCP runtime own live state.

</div>
<div>

![API Center tracks design-time inventory while API Management remains on the separate runtime request path.](assets/diagrams/api-center-inventory-flow.svg)

</div>
</div>

<!-- Notes: Live requests do not pass through API Center. -->

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Required answer |
|---|---|
| Inventory | API Center is the approved record for these assets |
| APIM boundary | Every imported API has a metadata owner |
| Plan and region | Free or Standard and a currently advertised region |
| Access | Contributor on the API Center resource group; time-bound User Access Administrator on the exact APIM service |
| MCP server | Approved remote, read-only HTTPS Streamable HTTP endpoint |

Stop if another inventory is authoritative, the APIM link would import ownerless assets, or either role scope is broader than approved.

<!-- Notes: The APIM integration imports the whole instance, not one selected API. -->

---

## Metadata and safety gates

Every entry records:

- business and technical owner;
- asset kind, classification, and permitted consumers;
- model/provider, residency profile, and risk tier;
- evaluation destination, review date, expiry date, and Session 06 marker.

Stop for unresolved values, embedded credentials, a write-capable MCP server, local `stdio`, or an
expiry date with no operating response.

At expiry, the technical owner renews, retires, or quarantines the entry within one business day.

<!-- Notes: Required metadata changes who must act. It does not authorize runtime calls. -->

---

<!-- _class: implementation -->

## Implementation path

**Total facilitated work: 180 minutes.** Schedule the APIM synchronization wait separately.

1. Complete the deployment inputs and metadata decisions.
2. Run preflight and inspect the ARM `what-if`.
3. Deploy API Center, the direct agent definition, and the APIM reader integration.
4. Resume after synchronization reports healthy.
5. Complete metadata on the synchronized entries.
6. Register the native remote MCP server.
7. Run the read-only inventory check.

Initial APIM synchronization can take up to 24 hours. Do not create a duplicate API while waiting.

<!-- Notes: Use two delivery windows when synchronization does not finish during the first. -->

---

## Preflight protects the change

- Every `__REQUIRED_*__` value is resolved.
- JSON, OpenAPI, and Bicep parse or compile.
- Runtime URLs are remote HTTPS values and stay outside source control.
- Azure CLI targets the approved subscription and resource group.
- The region, APIM tier, Session 06 marker, reader role, and names match.
- The preview changes only the marked API Center scope and exact reader assignment.

The reader role is `71522526-b88f-4d52-b57f-d31fc3546d0d` on the Session 06 APIM service.

<!-- Notes: Stop on unrelated replacement, removal, or broader access. -->

---

## Confirm the result

Run the paired `check-inventory` script after synchronization and MCP registration.

Expected result:

- The direct agent API, synchronized Session 06 API, and MCP server each appear once.
- Required metadata is complete.
- The APIM integration points to the approved source.
- The script writes no inventory export.

When the service response omits source health, check it in the portal. Confirm the native MCP
deployment location and runtime health there too. This is not end-to-end runtime validation.

<!-- Notes: This is the one standard-mode observable check. -->

---

<!-- _class: two-column -->

## Operate and restore

<div class="columns">
<div>

### Keep in operation

- API program owner: service and schema
- Asset owners: ownership, consumers, review, expiry
- Data and risk owners: classification, residency, risk
- APIM owner: integration and reader assignment
- Developers: API definitions

</div>
<div>

### Remove safely

Confirm no later session or approved consumer relies on the inventory.

Check the Session 06 marker, remove the exact APIM reader assignment, then delete only the marked API Center.

APIM, Foundry, the MCP runtime, runtime policies, and repository definitions remain.

</div>
</div>

<!-- Notes: Removal follows the approved Azure change path. -->

---

## Handoff to Session 08

Session 06 leaves:

- one searchable design-time inventory;
- three selected assets with named owners and lifecycle metadata;
- a read-only APIM source integration; and
- production-shaped deployment and check scripts.

[Session 08](../08-mcp-tool-security/) constrains MCP identities, tools, arguments, outputs, and side effects.

<!-- Notes: Inventory says what exists. Session 08 governs what the tools can do. -->

---

<!-- _class: closing -->

# Thank you!
