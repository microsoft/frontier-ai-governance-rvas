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

> Locate one governed service's agent and MCP records in their native services. Then rehearse routing to its approved secondary deployment. Check the expected identity reference, policy version, and trace fields.

Operators:

- locate the approved agent and MCP server in their native services;
- inspect live Azure resources and native service state; and
- move regional routing and check the expected identity reference, policy, and tracing on the active path.

<!-- Notes: A second region without named operators and a tested restore path is only spare infrastructure. -->

---

## Why it matters

A secondary deployment helps when operators can identify the service, move traffic through an approved path, and tell whether its controls still work.

This rehearsal gives the service and delivery owners one visible regional result. It does not make one service check fleet-wide lifecycle enforcement.

<!-- Notes: The rehearsal moves traffic, not an identity or registry object. -->

---

## Implementation outcomes

1. Locate the governed agent and MCP server in their native services.
2. Query Azure resources live and inspect current records in each native service.
3. Use the regional Bicep parameter file. Keep regional gateways with regional backends.
4. Record the primary-region management-plane and regional rate-limit limits.
5. Route one governed service to its approved secondary deployment. Check the expected identity reference, gateway policy, and tracing, then keep a restore path.

<!-- Notes: Standard mode fits because the plan calls for one visible failover result, not a manufactured blocked test. -->

---

## What must already work: Sessions 05-09

Teams joining at Session 14 use this table to confirm the required state before the rehearsal.
Sessions 05-13 remain the guided path for building these controls.

| Existing control | What must already work | How the owner confirms it |
|---|---|---|
| 05 Agent baseline | Project, fixed version, model alias, Entra identity | Platform owner gets the expected safe response |
| 06 Gateway | Versioned APIM policy, selectors in the topology | Gateway owner previews the selected selector and reaches only the backend listed in the topology |
| 07 Inventory | Approved API, agent, and MCP IDs, versions, owners | Inventory owner resolves each ID with no duplicate production record |
| 08 Tool security | Workload identity, tool scope, operations, egress, version | Tool owner sees allowed read pass and unauthorized operation block |
| 09 Data governance | Classification, residency, Purview policy IDs, covered agent | Data owner finds the agent in the policy listed in the inventory |

<!-- Notes: The implementation guide carries the full nine-row prerequisite table for teams joining at Session 14. -->

---

## What must already work: Sessions 10-13

| Existing control | What must already work | How the owner confirms it |
|---|---|---|
| 10 Evaluation | Definition, thresholds, baseline, candidate, regression | Quality owner sees candidate pass and regression block |
| 11 Threat defense | Confirmed payload-free report, Defender route | Security owner sees blocked actions and one Defender signal |
| 12 Observability | Telemetry definition, workbook, alerts, smoke result | Observability owner traces one safe request with separate failures |
| 13 Promotion | Protected environments, deployment metadata, and previous-release restore | Release owner sees approval after what-if |

<!-- Notes: Every row identifies the existing control, the state needed for this rehearsal, and the owner who checks it. -->

---

<!-- _class: section-divider -->

# Reconcile the agent, then test secondary-region routing

Foundry Control Plane shows supported agents across Azure projects you can access. Agent 365 provides the enterprise registry.

<!-- Notes: Do not collapse the product boundary. -->

---

## Architecture overview

This rehearsal separates service records from the traffic setting that changes. Native services
retain agent, MCP, identity, and inventory state. The repository keeps regional parameters and
wrapper interfaces. The routing control changes the active selector.

| Part | What happens | Where the state lives |
|---|---|---|
| Identify | Native service views and Azure Resource Manager identify the governed service and its regional resources. | Native platforms |
| Check | Customer health checks confirm both deployments are ready before traffic changes. | Customer health system |
| Switch | The approved routing control moves the active selector from the primary path to the secondary path. | Customer change system |
| Verify and restore | The active-path check confirms the expected identity, policy, endpoint, and traces. A mismatch restores the primary selector. | Customer change system and runbook |

<!-- Notes: The same agent appears in several systems because each answers a different operating question. The regional parameter file supplies the expected values, the runbook gives the restore steps, and the customer change system records approval and outcome. -->

---

## Fleet and regional control

The service owner identifies the governed agent in Foundry Control Plane and Agent 365, then finds
its MCP server in the API inventory. Azure Resource Manager checks the project, telemetry resource,
and API Management topology. The active-path health result is temporary. The customer change system
records the outcome.

<!-- Notes: Traffic moves. The active path must report the expected identity reference, policy version, and trace fields. No identity object is moved by this session. -->

---

## Foundry Control Plane view

![Microsoft Foundry](assets/icons/microsoft/azure-ai-foundry.svg)

**Operate > Assets > Agents**

Foundry Control Plane discovers supported agents across the projects a user can access in a
subscription. It shows the version, published state, status, and Entra ID.

Application Insights supplies run, error, token, cost, and trace views. Missing inventory can mean
the operator lacks access. It does not prove the agent is absent.

<!-- Notes: Record the exact agent ID and immutable version. A name alone cannot reconcile this view with Agent 365 or Microsoft Entra. -->

---

## Agent 365 and Microsoft Entra

![Microsoft Agent 365](assets/icons/microsoft/agent-365.svg)

**Agent 365** provides the complete registry across Microsoft and non-Microsoft agents.
**Microsoft Entra** remains the identity and access control plane for the agent.

**AI Reader is a privileged tenant role.** Use a time-bound PIM-eligible activation for inventory,
then let it expire at the end of the approved window.

If the registry record is missing, a temporarily activated **Agent Registry Administrator**
registers the existing agent during pre-work. Identity changes require **Agent ID Administrator**.

<!-- Notes: Agent 365 answers which agents the enterprise has registered. Microsoft Entra answers which identity the agent uses and how that identity is governed. The rehearsal moves neither object. -->

---

<!-- _class: two-column -->

## Check Purview and Defender coverage

<div class="columns">
<div>

![Microsoft Purview](assets/icons/microsoft/microsoft-purview.svg)

### Purview

Start at the agent instance. Confirm audit and data classification there.

Other controls need policy inclusion. The owner also checks whether DLP affects later agent steps.

</div>
<div>

![Microsoft Defender XDR](assets/icons/microsoft/microsoft-defender-xdr.svg)

### Defender

Record whether Unified RBAC is not activated, partially activated, or active for all in-scope
workloads. Then record whether visibility uses Entra Security Reader, Defender Unified RBAC, or a
mixed model.

Confirm the expected agent runtime and risk signals. Defender keeps threat investigation and
protection records alongside its existing user, app, and device records.

</div>
</div>

<!-- Notes: Visibility is checked in the native products. No screenshot package is created. -->

---

<!-- _class: decision -->

## Decision gate 1 - Fleet identity

Resolve the service identifiers:

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
| Service state | Native service views plus live Azure queries | Read current state from the services that store it | Operators need access to each service |
| Gateway topology | One Premium (classic) multi-region instance or separate regional gateways | Keeps the approved network and isolation design | Accept the primary management plane or the added release work |
| Restore | Move the approved selector and keep the secondary deployment | Narrows the restore and leaves standby ready | Session 13 controls drift; capacity cost continues |

<!-- Notes: Session 13 promotes regional configuration. Session 14 moves traffic and checks the active path. -->

---

<!-- _class: decision -->

## Decision gate 2 - Regional gateway patterns

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

API Management does not make a single-region backend regional. Cross-region backend calls keep the latency and dependency that the secondary gateway was meant to remove.

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

The service and delivery owners must approve:

1. no policy change while the primary management plane is unavailable;
2. regional rate and token counters are not a global limit;
3. internal routing and DNS are customer responsibilities;
4. both regions meet model, quota, data, network, and tool requirements; and
5. the restore authority is present during the rehearsal.

<!-- Notes: If one limit is unacceptable, choose a different topology before deployment. -->

---

## Deploy through the existing Bicep entrypoint

The Session 14 control definition names:

- the customer Bicep entrypoint that deploys and updates the full regional stack;
- the `region.parameters.json` deployment inputs;
- a health-check script for the secondary deployment; and
- a routing-control script for the approved selector move.

Do not deploy a partial `Microsoft.ApiManagement/service` definition beside the existing definition.

<!-- Notes: Two deployment definitions for the same API Management resource can overwrite configuration. -->

---

<!-- _class: implementation -->

## Reconcile inventory and run the regional failover

Before preflight, locate one governed agent and one MCP server in their native services. Query the
Azure resources used by the rehearsal. Complete the secondary-region deployment before the timed
rehearsal.

**Timebox: 130 minutes**

1. Match project, logs, agent, and store identifiers across the source configuration files.
2. Check live Azure resources and the relevant native service views.
3. Run decision preflight.
4. Confirm the secondary path was deployed through the existing [Session 13](../13-cicd-promotion-controls/) release control.
5. Run controlled failover; its wrapper repeats ready preflight before health and routing.

<!-- Notes: Keep the maintenance window for the final routing move, not for unresolved design work. -->

---

## Preflight stays read-only

### Decisions

Named values, approved scope, HTTPS endpoints, repository paths, script syntax, Bicep lint, and Bicep build.

### Ready

Active Azure subscription, API Management IDs, tiers and regions, additional location when used, then Azure deployment what-if.

Neither phase deploys resources or moves traffic.

The inventory operator uses Azure **Reader** at subscription scope and a time-bound PIM activation
for privileged tenant **AI Reader**.

The security operator uses **Purview Data Security AI Viewer** plus a time-bound Microsoft Entra
**Security Reader** activation. Azure what-if requires temporary **Contributor** on the approved
regional resource group.

<!-- Notes: Human role activations expire after the rehearsal. A clean compile is not a clean deployment preview. -->

---

## Rehearsal script interfaces

The wrappers call the team's paired PowerShell or Bash scripts. Health checks do not change
traffic. Routing control is the sole traffic-changing interface.

### Health

`Readiness` checks the secondary deployment before the preview. `Active` checks the same safe
request through the secondary selector after failover.

Both modes receive `Region` and a temporary `ResultPath`. They write version, identity, policy,
endpoint, and trace status with no sensitive input. A failed result stops the rehearsal.

### Routing

`Preview` shows the named selector move and makes no change. `Failover` moves traffic after
delivery-owner approval. `Restore` returns traffic to the primary selector through the approved
change process.

Every mode receives `FromSelector`, `ToSelector`, `ApprovedScope`, and `ChangeRecordId`. It
accepts no secret or free-form command string.

<!-- Notes: The wrappers call the scripts in a fixed sequence. The health script reports readiness and active-path state. The routing script previews, changes, or restores the approved selector pair. -->

---

## Stop if any of these apply

- unresolved owner, scope, or version;
- missing live Azure resources or a native service record for the governed agent or MCP server;
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

Use this approved routing restore path:

1. checks primary readiness;
2. previews secondary-to-primary routing;
3. has the service owner accept readiness and the delivery owner confirm the high-impact traffic move;
4. restores only the primary selector listed in the topology; and
5. checks the active primary path.

The secondary region remains deployed.

<!-- Notes: Region removal is a later infrastructure decision, not rehearsal cleanup. -->

---

## Responsibilities after the rehearsal

The exercise checks one governed service through its agent and MCP records.

Fleet-wide lifecycle enforcement is outside this session. The rehearsal does not move identity or registry objects between regions.

| Owner | Operational responsibility |
|---|---|
| Platform owner | Maintains inventory identifiers and infrastructure definitions |
| Service owner | Capacity, routing, runbook, and maintenance window |
| Security owner | Purview and Defender visibility |
| Delivery owner | Rehearsal authority and stop decision |

<!-- Notes: The source systems keep live inventory, audit, deployment, and logs records. The repository retains desired configuration and the maintained restore runbook. -->

---

## Recap

- Governed agent and MCP server records
- Native service views plus live Azure queries
- Regional parameter file
- Co-located gateway and backend paths
- Primary management-plane limits recorded
- Regional counters treated correctly
- Controlled failover with expected identity-reference, policy, and trace checks
- Restore without deleting the secondary region

<!-- Notes: Keep wider fleet work in the customer's normal operating backlog. -->

---

<!-- _class: closing -->

# Thank you!

<!-- Notes: Close on named responsibilities and the next scheduled rehearsal. -->
