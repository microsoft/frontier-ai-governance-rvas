# Retained evidence checklist

Use this checklist to decide what remains in the repository after Session 10. Keep the live
Microsoft Purview and Agent 365 records authoritative.

| Item | Repository handling | Owner |
|---|---|---|
| DLP policy name, mode, scope, and label ID | Retain in `agent365-dlp-policy-template.json` and `coverage-handoff.md` | `__REQUIRED_DLP_INCIDENT_OWNER_ROLE__` |
| DSPM finding summaries | Retain in `dspm-findings-summary.md` and `coverage-handoff.md` | `__REQUIRED_DATA_OWNER_ROLE__` |
| Agent activity query shape | Retain in `operations/agent-activity-audit-query.json` | `__REQUIRED_AUDIT_OWNER_ROLE__` |
| Raw prompts and responses | Do not retain | `__REQUIRED_AUDIT_OWNER_ROLE__` |
| Unified audit exports | Do not retain | `__REQUIRED_AUDIT_OWNER_ROLE__` |
| Screenshots with tenant, user, source, or file data | Do not retain | `__REQUIRED_PURVIEW_OPERATOR_ROLE__` |
| Policy simulation result | Observe in Microsoft Purview; record only pass/fail and owner decision | `__REQUIRED_DLP_INCIDENT_OWNER_ROLE__` |
| Generated-content label behavior | Retain the observed label behavior and compensating control | `__REQUIRED_INFORMATION_PROTECTION_OWNER_ROLE__` |

Stop if an item contains customer content, user identities, source URLs, file names, prompt text, or
response text.
