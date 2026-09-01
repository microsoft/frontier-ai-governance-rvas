# Implementation artifacts

Session 15 keeps the source-controlled files used for regional rehearsals. Native platforms and
the customer change system retain live state, decisions, and runtime results.

| Path | Type | Consumer | Updater | Review cadence | Operational purpose |
|---|---|---|---|---|---|
| `control-definition.json` | Runtime | Session 15 preflight scripts and regional rehearsal operators | Platform owner | Before a rehearsal and after the Bicep entrypoint or customer script interface changes | Binds the approved Azure scope and customer script paths used by the wrappers. |
| `regional/region.parameters.json` | Deployment | The customer Bicep deployment, Session 15 preflight scripts, and routing wrappers | Platform owner | With every regional deployment change and before a rehearsal | Supplies regional deployment inputs and expected active-path values. |
| `regional/failover-runbook.md` | Record | Service continuity and routing operators | Service continuity owner | Before every scheduled rehearsal and after a routing, topology, or restore-process change | Directs the approved selector move and restore sequence. |

`control-definition.json` is a machine contract. `region.parameters.json` is source-controlled
configuration for the customer Bicep entrypoint. The runbook is the human-owned operating record
in this tree. It names its owner and review cadence.

Preflight reads Azure Resource Manager and API Management live. The rehearsal wrappers write
temporary health output to a customer-managed directory outside the repository, delete it after
the check, and send the outcome to the customer change system.
