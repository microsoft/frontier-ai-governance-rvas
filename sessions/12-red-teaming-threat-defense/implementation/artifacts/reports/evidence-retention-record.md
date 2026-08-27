# Red-team evidence retention record

This record defines what the repository may retain after a red-team run. Foundry, Defender, and the
SOC system remain authoritative for detailed run records and alert evidence.

| Item | Repository handling | Owner |
|---|---|---|
| Authorization scope | Retain `authorization-scope.json` | `__REQUIRED_SECURITY_OWNER_ROLE__` |
| Reviewed taxonomy ID | Retain ID and name only | `__REQUIRED_SECURITY_OWNER_ROLE__` |
| Baseline and post-remediation run IDs | Retain IDs and report URLs only | `__REQUIRED_SECURITY_OWNER_ROLE__` |
| Aggregate ASR by category, strategy, and evaluator | Retain in scorecard and before/after report | `__REQUIRED_RELEASE_OWNER_ROLE__` |
| Attack prompts | Do not retain | `__REQUIRED_SECURITY_OWNER_ROLE__` |
| Agent responses | Do not retain | `__REQUIRED_SECURITY_OWNER_ROLE__` |
| Tool payloads | Do not retain | `__REQUIRED_TOOL_OWNER_ROLE__` |
| Defender prompt evidence | Do not retain | `__REQUIRED_DEFENDER_OWNER_ROLE__` |
| SOC incident record | Retain reference only | `__REQUIRED_SOC_OWNER_ROLE__` |

Stop if any retained file contains raw prompt text, response text, tool arguments, tool results,
prompt evidence, user identities, tenant IDs, subscription IDs, or source document names.
