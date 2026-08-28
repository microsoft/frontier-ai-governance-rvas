# Implementation artifacts

Session 14 keeps the source-controlled files that repeat the regional rehearsal. Native platforms
and the customer change system retain live state, decisions, and runtime results.

| Path | Type | Consumer | Updater | Review cadence | Operational purpose |
|---|---|---|---|---|---|
| `control-definition.json` | Runtime | Session 14 preflight scripts and regional rehearsal operators | Platform owner | Before a rehearsal and after the Bicep entrypoint or customer script interface changes | Binds the approved Azure scope and customer script paths used by the wrappers. |
| `regional/region.parameters.json` | Deployment | The customer Bicep deployment, Session 14 preflight scripts, and routing wrappers | Platform owner | With every regional deployment change and before a rehearsal | Supplies regional deployment inputs and expected active-path values. |
| `regional/failover-runbook.md` | Record | Service continuity and routing operators | Service continuity owner | Before every scheduled rehearsal and after a routing, topology, or restore-process change | Directs the approved selector move and restore sequence. |

`control-definition.json` is a machine contract. `region.parameters.json` is desired-state
configuration consumed by the customer Bicep entrypoint. The runbook is the sole human-owned
operational record in this tree, and its ownership and review cadence appear in the file itself.

Preflight queries Azure Resource Manager and API Management live. The rehearsal wrappers send
transient health output to a customer-managed directory outside the repository, delete it after
the check, and direct the outcome to the customer change system.
