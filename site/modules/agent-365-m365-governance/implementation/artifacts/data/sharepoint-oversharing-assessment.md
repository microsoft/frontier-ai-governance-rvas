# SharePoint oversharing assessment

Use SharePoint Advanced Management and Data Access Governance reports to review grounding sources
before expanding agent access. Keep SharePoint and Purview as the authoritative sources for live
sharing state.

| Field | Decision |
|---|---|
| Agent alias | `__REQUIRED_AGENT_ALIAS__` |
| SharePoint owner | `__REQUIRED_SHAREPOINT_OWNER_ROLE__` |
| Data owner | `__REQUIRED_DATA_OWNER_ROLE__` |
| Grounding source alias | `__REQUIRED_GROUNDING_SOURCE_ALIAS__` |
| Review date | `__REQUIRED_REVIEW_DATE__` |
| Access scope alias | `__REQUIRED_ACCESS_SCOPE_ALIAS__` |

## Findings

| Check | Required state | Decision |
|---|---|---|
| Broad links | No unresolved broad sharing link remains in the approved grounding source | `__REQUIRED_BROAD_LINK_DECISION__` |
| Everyone except external users | Not present, or explicitly accepted for synthetic nonproduction data | `__REQUIRED_EEEU_DECISION__` |
| Stale permissions | Removed or accepted by the data owner | `__REQUIRED_STALE_ACCESS_DECISION__` |
| Sensitive content | Label state matches the Purview owner decision | `__REQUIRED_SENSITIVE_CONTENT_DECISION__` |
| Agent grounding | Agent access is no broader than the approved access scope | `__REQUIRED_GROUNDING_ACCESS_DECISION__` |

Do not paste site URLs, file names, user names, or report exports into this record. Use aliases and
owner decisions.
