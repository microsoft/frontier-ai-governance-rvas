# Red-team taxonomy review checklist

Use this checklist before setting `taxonomy.customerReviewed` to `true` in `attack-plan.json`.
Microsoft Foundry remains authoritative for generated attack details. This repository keeps only
the review decision.

| Check | Required state | Owner |
|---|---|---|
| Target agent | Matches `__REQUIRED_AGENT_NAME__` and immutable version `__REQUIRED_AGENT_VERSION__` | `__REQUIRED_AGENT_OWNER_ROLE__` |
| Prohibited actions | Match the approved policy boundary for the synthetic nonproduction agent | `__REQUIRED_SECURITY_OWNER_ROLE__` |
| Tool risk | The only described tool remains the read-only synthetic `get_policy` path | `__REQUIRED_TOOL_OWNER_ROLE__` |
| Sensitive data leakage | Uses synthetic categories and does not include customer data | `__REQUIRED_SECURITY_OWNER_ROLE__` |
| Human review | Reviewer has checked categories, strategy set, and run limits | `__REQUIRED_SECURITY_OWNER_ROLE__` |
| Repository retention | No attack prompts, responses, tool payloads, or evaluator reasons are retained | `__REQUIRED_SECURITY_OWNER_ROLE__` |

## Approval

| Field | Decision |
|---|---|
| Authorization ID | `__REQUIRED_AUTHORIZATION_ID__` |
| Approved taxonomy name | `__REQUIRED_TAXONOMY_NAME__` |
| Approved on | `__REQUIRED_AUTHORIZATION_DATE__` |
| Security owner | `__REQUIRED_SECURITY_OWNER_ROLE__` |
| Agent owner | `__REQUIRED_AGENT_OWNER_ROLE__` |
| Tool owner | `__REQUIRED_TOOL_OWNER_ROLE__` |

Stop if the taxonomy names production data, contains a write-capable tool, widens the authorized
agent scope, or requires retaining raw adversarial content in this repository.
