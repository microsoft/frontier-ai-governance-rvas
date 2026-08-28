---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation - Session 14</p>

# Agent fleet governance, multi-region design, and production rehearsal

**270 minutes - Reconcile inventory and test one controlled regional move**

<!-- Notes: Session 13 made release promotion repeatable. This session checks one service while traffic moves to its secondary deployment. -->

---

## Control objective

> Reconcile one governed service's agent and MCP records. Then rehearse routing to its approved secondary deployment and check the expected identity reference, policy version, and trace contract.

Operators must:

- reconcile the approved agent and MCP server;
- distinguish live Azure queries from dated portal snapshots; and
- move regional routing and check the expected identity reference, policy, and tracing on the active path.

<!-- Notes: A second region without service ownership is only spare infrastructure. -->

---

## Why it matters

A secondary deployment helps only when operators can identify the service, move traffic through an approved path, and tell whether its controls still work.

This rehearsal gives the service and delivery owners one visible regional result. It does not turn one service check into fleet-wide lifecycle enforcement.

<!-- Notes: The rehearsal moves traffic, not an identity or registry object. -->

---

## Implementation outcomes

1. Reconcile the governed agent across Foundry Control Plane and Agent 365 without treating either view as the other's replacement.
2. Query stable Azure resources live and label other inventory as a dated operator snapshot.
3. Use one minimal regional Bicep parameter contract, keeping regional gateways with regional backends.
4. Record the primary-region management-plane and regional rate-limit constraints.
5. Route one governed service to its approved secondary deployment, check the expected identity reference, gateway policy, and tracing, then preserve an restore path.

<!-- Notes: Standard mode fits because the plan calls for one visible failover result, not a manufactured blocked test. -->

---

## Focused-route baseline: Sessions 05-09

| Substitute | Live state | Owner result |
|---|---|---|
| 06 Agent | Project, fixed version, model alias, Entra identity | Platform owner gets the expected safe response |
| 07 Gateway | Versioned APIM policy, selectors in the topology | Gateway owner previews one selector and reaches only the backend listed in the topology |
| 08 Inventory | Approved API, agent, and MCP IDs, versions, owners | Inventory owner resolves each ID with no duplicate production record |
| 09 Tool | Workload identity, tool scope, operations, egress, version | Tool owner sees allowed read pass and unauthorized operation block |
| 10 Data | Classification, residency, Purview policy IDs, covered agent | Data owner finds the agent in the policy listed in the inventory |

<!-- Notes: The implementation guide carries the full nine-row focused-route baseline. -->

---

## Focused-route baseline: Sessions 10-13

| Substitute | Live state | Owner result |
|---|---|---|
| 11 Evaluation | Definition, thresholds, baseline, candidate, regression | Quality owner sees candidate pass and regression block |
| 12 Threat defense | Confirmed payload-free report, Defender route | Security owner sees blocked actions and one Defender signal |
| 13 Observability | Logging contract, workbook, alerts, smoke result | Observability owner traces one safe request with separate failures |
| 14 Promotion | Protected environments, specific OIDC subjects, fixed manifest, previous-release restore | Release owner shows allowed production approval and blocked regression |

<!-- Notes: Every substitute has specific state, a decision record, an owner, and the result needed here. -->

---

<!-- _class: section-divider -->

# Reconcile the agent, then test secondary-region routing

Foundry Control Plane shows supported agents across accessible Azure projects. Agent 365 provides the wider enterprise registry.

<!-- Notes: Do not collapse the product boundary. -->

---

## Architecture overview

The design separates the information used to identify the service from the setting that moves
traffic. A dated portal view can inform the rehearsal, but it cannot move the active selector.

| Path | What happens | Decision record |
|---|---|---|
| Inventory | Live Azure resources are compared with dated Foundry Control Plane, Agent 365, Purview, and Defender observations | Recorded IDs, immutable versions, snapshot dates, and owners |
| Traffic | The setting for the active route moves from a healthy primary deployment to the existing secondary path | Customer change system and regional health result |
| Restore | A failed active check returns the same selector through the documented restore path | Customer change system |

<!-- Notes: The same agent appears in several systems because each answers a different operating question. Portal observations are snapshots, not proof of current state. The source-controlled regional contract and runbook govern the rehearsal. The customer change system owns the result. -->

---

## Fleet and regional control

![Live Azure and Foundry state is reconciled with dated Agent 365, Purview, and Defender operator snapshots by recorded owners](assets/diagrams/fleet-control-map.svg)

<!-- Notes: Traffic moves. The active path must report the expected identity reference, policy version, and trace contract. No identity object is moved by this session. -->

---

## Foundry Control Plane view

![Microsoft Foundry](assets/icons/microsoft/azure-ai-foundry.svg)

**Operate > Assets > Agents**

Foundry Control Plane discovers supported agents across the projects a user can access in a
subscription. It shows the version, published state, status, and Entra ID.

Application Insights supplies the run, error, token, cost, and trace views. Missing inventory can
mean that the operator lacks access; it does not prove that the agent is absent.

<!-- Notes: Record the exact agent ID and immutable version. A name alone cannot reconcile this view with Agent 365 or Microsoft Entra. -->

---

## Agent 365 and Microsoft Entra

![Microsoft Agent 365](assets/icons/microsoft/agent-365.svg)

**Agent 365** provides the complete registry across Microsoft and non-Microsoft agents.
**Microsoft Entra Agent ID** remains authoritative for identity.

Use tenant-scoped **AI Reader** for inventory.

A missing registry record returns to a temporary **Agent Registry Administrator** in pre-work.
Identity changes require **Agent ID Administrator**.

<!-- Notes: Agent 365 answers which agents the enterprise has registered. Microsoft Entra answers which identity the agent uses and how that identity is governed. The rehearsal moves neither object. -->

---

<!-- _class: two-column -->

## Check Purview and Defender coverage

<div class="columns">
<div>

![Microsoft Purview](assets/icons/microsoft/microsoft-purview.svg)

### Purview

Start the check from the agent instance. Confirm audit and data classification there.

Other controls require policy inclusion. The owner also checks whether DLP affects later agent
steps.

</div>
<div>

![Microsoft Defender XDR](assets/icons/microsoft/microsoft-defender-xdr.svg)

### Defender

Confirm the expected agent runtime and risk signals. Defender keeps the threat investigation and
protection record alongside its existing user, app, and device records.

</div>
</div>

<!-- Notes: Visibility is checked in the native products. No screenshot package is created. -->

---

<!-- _class: decision -->

## Decision gate 1 - Fleet identity

Resolve one record:

- Foundry project and agent name;
- fixed agent version;
- Agent 365 registry ID;
- Microsoft Entra agent identity ID;
- Application Insights resource;
- accountable agent owner.

Stop on a duplicate, ownerless, or version-ambiguous production record.

<!-- Notes: Names alone are not enough to reconcile the views. -->

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Chosen approach | Why | Requirement |
|---|---|---|---|
| Inventory | Live Azure queries plus dated portal observations | Separates current state from snapshots | Owners review snapshot dates before rehearsal |
| Gateway topology | One Premium (classic) multi-region instance or separate regional gateways | Keeps the approved network and isolation design | Accept the primary management plane or the added release work |
| Restore | Move one selector and keep the secondary deployment | Narrows the restore and leaves standby ready | Session 13 controls drift; capacity cost continues |

<!-- Notes: Session 13 owns regional configuration promotion. Session 14 moves traffic and checks the active path. -->

---

<!-- _class: decision -->

## Decision gate 2 - Regional gateway pattern

| One multi-region instance | Separate regional gateways |
|---|---|
| Premium (classic) | Approved production tier per service |
| Same API Management service resource ID; separate regional gateway URL, backend URL, subnet, and public IP values | Different service resource IDs and separate regional values |
| Regional gateways share configuration | Release path applies the same policy revision |
| Public traffic manager in external mode | Customer traffic layer chooses a gateway |
| Customer routing still required in internal mode | Separate isolation and blast radius |

<!-- Notes: Premium v2 supports zones but not multi-region deployment. -->

---

## Co-locate gateways and backends

![Azure API Management](assets/icons/microsoft/azure-api-management.svg)

Primary gateway -> primary backend

Secondary gateway -> secondary backend

API Management does not make a single-region backend regional. Cross-region backend calls keep the latency and dependency the secondary gateway was meant to remove.

<!-- Notes: The deployment preview must show the complete regional stack, including its backend. -->

---

## Record API Management regional limits

For one Premium (classic) multi-region instance:

- only gateways are replicated;
- management plane and developer portal remain primary-region;
- secondary gateways serve the latest synchronized configuration;
- internal mode needs customer-owned cross-region routing; and
- request, rate, and token counters are regional.

<!-- Notes: A healthy secondary gateway does not make the management plane regional. -->

---

<!-- _class: decision -->

## Decision gate 3 - Operational limits

The service and delivery owners must accept:

1. no policy change while the primary management plane is unavailable;
2. regional rate and token counters are not a global limit;
3. internal routing and DNS are customer responsibilities;
4. both regions meet model, quota, data, network, and tool requirements; and
5. the restore authority is present during the rehearsal.

<!-- Notes: If one limit is unacceptable, choose a different topology before deployment. -->

---

## Deploy through the existing Bicep entrypoint

The Session 14 control definition points to:

- the customer Bicep entrypoint that owns the full regional stack;
- one minimal `region.parameters.json` contract;
- a fixed customer health script; and
- a fixed customer routing script.

Do not deploy a partial `Microsoft.ApiManagement/service` definition beside the existing one.

<!-- Notes: Parallel ownership is a configuration-loss risk. -->

---

<!-- _class: implementation -->

## Reconcile inventory and run the regional failover

Before preflight, record one governed agent and one MCP server. Query the stable Azure resources live.

Capture Agent 365, Purview, and Defender observations as a dated operator snapshot. Complete the secondary-region deployment before the timed rehearsal.

**Timebox: 130 minutes**

1. Match project, logs, agent, and store identifiers across the source configuration files.
2. Reconcile live Azure resources and dated portal views.
3. Run decision preflight.
4. Confirm the secondary path was deployed through the existing [Session 13](../13-cicd-promotion-controls/) release control.
5. Run controlled failover; its wrapper repeats ready preflight before health and routing.

<!-- Notes: Keep the maintenance window for the final routing move, not for unresolved design work. -->

---

## Preflight stays read-only

### Decisions

Named values, approved scope, snapshot date, HTTPS endpoints, repository paths, script syntax, Bicep lint, and Bicep build.

### Ready

Active Azure subscription, API Management IDs, tiers and regions, additional location when used, then Azure deployment what-if.

Neither phase deploys or moves traffic.

The inventory operator uses Azure **Reader** at subscription scope and tenant **AI Reader**.

The security operator uses **Purview Data Security AI Viewer** plus Microsoft Entra **Security Reader**. Azure what-if requires temporary **Contributor** on the approved regional resource group.

<!-- Notes: Human role activations expire after the rehearsal. A clean compile is not a clean deployment preview. -->

---

## Customer script boundary

PowerShell and Bash use paired, fixed interfaces.

### Health

`Readiness|Active + Region + temporary ResultPath`

Returns version, identity, policy, endpoint, and trace status with no sensitive input.

### Routing

`Preview|Failover|Restore + FromSelector + ToSelector + ApprovedScope + ChangeRecordId`

No secret argument. No free-form command string.

<!-- Notes: Fixed interfaces make the flow readable without owning the customer's traffic platform. -->

---

## Stop conditions

- unresolved owner, scope, or version;
- missing live Azure resources or an outdated portal snapshot;
- unsupported API Management tier or topology;
- remote backend without an approved reason;
- no internal routing path;
- unrelated what-if deletion or replacement;
- health or routing script outside the repository;
- missing restore authority.

Keep the current selector.

<!-- Notes: A short change window is not permission to weaken a gate. -->

---

## Controlled failover sequence

<!-- _class: diagram -->

![The regional failover checks primary health, confirms secondary readiness, previews and moves the selector, verifies the secondary path, then restores the primary selector](assets/diagrams/regional-failover-sequence.svg)

<!-- Notes: The script leaves the secondary selector active long enough for the owner to observe the result. -->

---

## The failover steps

1. Freeze infrastructure and policy changes.
2. Rerun ready preflight.
3. Service owner checks secondary readiness fields.
4. Preview primary-to-secondary routing.
5. Delivery owner confirms the high-impact production traffic move listed in the runbook.
6. Move the selector listed in the topology.
7. Check the active secondary path.

---

## Confirm the result

Expected on the active secondary path:

- fixed agent version listed in the topology;
- expected Microsoft Entra agent identity;
- expected API Management policy version;
- endpoint and trace checks pass;
- no sensitive synthetic input; and
- the operational record contains the active secondary result.

<!-- Notes: The runtime record stays in the customer's approved operational system. -->

---

## Restore path

the approved routing restore path:

1. checks primary readiness;
2. previews secondary-to-primary routing;
3. has the service owner accept readiness and the delivery owner confirm the high-impact traffic move;
4. restores only the primary selector listed in the topology; and
5. checks the active primary path.

The secondary region remains deployed.

<!-- Notes: Region removal is a later infrastructure decision, not rehearsal cleanup. -->

---

## Live state and ownership

The exercise checks one governed service through its agent and MCP records.

Fleet-wide lifecycle enforcement is outside this session. The rehearsal does not move an identity or registry object between regions.

| Owner | Operational responsibility |
|---|---|
| Platform owner | Inventory coordinates and infrastructure definitions |
| Service owner | Capacity, routing, runbook, and maintenance window |
| Security owner | Purview and Defender visibility |
| Delivery owner | Rehearsal authority and stop decision |

<!-- Notes: The source systems keep live inventory, audit, deployment, and logs records. -->

---

## Recap

- One governed agent and one MCP server
- Live stable Azure queries plus a dated portal snapshot
- One minimal regional parameter contract
- Co-located gateway and backend paths
- Primary management-plane limits recorded
- Regional counters treated correctly
- Controlled failover with expected identity-reference, policy, and trace checks
- Restore without deleting the secondary region

<!-- Notes: Keep wider fleet work in the customer's normal operating backlog. -->

---

<!-- _class: closing -->

# Thank you!

<!-- Notes: Close on ownership and the next scheduled rehearsal. -->
