# Implementation artifacts

These files define the Session 10 Purview control. They contain no prompts,
responses, tenant IDs, user names, source URLs, audit exports, or customer content.

| Path | Operational purpose |
|---|---|
| `governance/coverage-handoff.md` | Product boundary, manual decisions, label, source access, DSPM review, DLP decisions, and live/manual check boundary |
| `operations/agent-activity-audit-query.json` | Agent scope, current operation names, lookback, and safe output fields |
| `purview/agent365-dlp-policy-template.json` | Portal checklist for the scoped Agent 365 DLP policy; not unattended policy automation |
| `purview/dspm-findings-summary.md` | Owned DSPM for AI summary without raw prompts, responses, identities, source names, or URLs |
| `purview/retained-evidence-checklist.md` | Retention boundary for repository records, Purview state, audit results, and blocked content |

Resolve every `__REQUIRED_*__` decision before changing tenant state. The preflight scripts reject
each sentinel, validate the audit query, and check the approved tenant and Graph permission. The
owners review the Markdown handoff and Purview files before manual Purview or DLP work.
