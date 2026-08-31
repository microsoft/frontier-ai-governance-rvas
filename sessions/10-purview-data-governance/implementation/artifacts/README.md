# Implementation artifacts

Session 10 keeps two operational files in source control:

| Path | Purpose | Authoritative state |
|---|---|---|
| `governance/coverage-handoff.md` | Records cross-product ownership where no platform provides a single view. | Microsoft Purview and the approved change system hold policy, label, DSPM, and DLP state. |
| `operations/agent-activity-audit-query.json` | Defines the payload-free Agent 365 audit query used by both scripts. | Microsoft Purview Audit holds the returned activity. |

Keep DLP portal values, DSPM summaries, simulation results, audit exports, label observations, and
screenshots in Microsoft Purview or the approved change system, not the repository.
