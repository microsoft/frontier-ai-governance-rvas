# Implementation artifacts

| Path | Type | Consumer | Owner | Purpose |
|---|---|---|---|---|
| `control-definition.json` | Runtime | Preflight and rehearsal wrappers | Platform owner | Binds the approved scope to customer controls. |
| `regional/region.parameters.json` | Runtime | Preflight and rehearsal wrappers | Platform owner | Supplies selectors and expected values for both paths. |
| `regional/failover-runbook.md` | Record | Service continuity and routing operators | Service continuity owner | Directs the move, check, restore, and final check. |

The health control writes temporary results outside the repository. The wrappers remove them after
each check.
