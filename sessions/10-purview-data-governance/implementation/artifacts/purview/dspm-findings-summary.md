# DSPM findings summary

Record owned summaries from Microsoft Purview DSPM for AI. Do not paste prompts, responses,
source names, file URLs, user names, raw activity rows, or exported reports into this file.

| Field | Decision |
|---|---|
| Review date | `__REQUIRED_FINDINGS_DATE__` |
| Data owner | `__REQUIRED_DATA_OWNER_ROLE__` |
| Agent owner | `__REQUIRED_AGENT_OWNER_ROLE__` |
| Information protection owner | `__REQUIRED_INFORMATION_PROTECTION_OWNER_ROLE__` |
| Agent instance alias | `__REQUIRED_AGENT_INSTANCE_ALIAS__` |
| Foundry subscription alias | `__REQUIRED_FOUNDRY_SUBSCRIPTION_ALIAS__` |

## Findings

| Category | Summary | Decision | Owner role |
|---|---|---|---|
| Sensitive grounding data | `__REQUIRED_SENSITIVE_GROUNDING_SUMMARY__` | `__REQUIRED_SENSITIVE_GROUNDING_DECISION__` | `__REQUIRED_DATA_OWNER_ROLE__` |
| Agent oversharing path | `__REQUIRED_OVERSHARING_SUMMARY__` | `__REQUIRED_OVERSHARING_DECISION__` | `__REQUIRED_AGENT_OWNER_ROLE__` |
| Unlabelled generated content | `__REQUIRED_GENERATED_CONTENT_SUMMARY__` | `__REQUIRED_GENERATED_CONTENT_DECISION__` | `__REQUIRED_INFORMATION_PROTECTION_OWNER_ROLE__` |

## Handling boundary

Keep Purview as the authoritative source for raw findings. This file records the owner decision and
the short remediation summary needed after the session.
