# APIM model-routing decision

This record defines the Session 06 APIM gateway routing decision. APIM is authoritative for the
live backend pool and policy. The deployment must preserve this owner-approved boundary.

## Lifecycle

| Field | Operating value |
|---|---|
| Update owner | `__REQUIRED_PLATFORM_OWNER__` |
| Review cadence | Every 90 days and before enabling, disabling, or replacing a secondary backend |
| Consumer | The API product owner approves routing changes with this record. The platform owner applies them through `gateway-control.json` and the Session 06 deployment path. |

| Field | Decision |
|---|---|
| Routing owner | `__REQUIRED_PLATFORM_OWNER__` |
| Product owner | `__REQUIRED_PRODUCT_OWNER__` |
| Safety owner | `__REQUIRED_SAFETY_OWNER__` |
| Operations owner | `__REQUIRED_OPERATIONS_OWNER__` |
| Primary priority | `1` |
| Secondary priority | `2` |
| Secondary backend enabled | `false` |
| Approved routing modes | Priority backend pool; circuit breaker; one retry for 429 or 5xx |
| Deferred routing modes | Weighted load balancing; round-robin; conditional `set-backend-service`; unified model API preview |
| Semantic caching | Deferred |
| Direct Foundry endpoint governance | Owned outside this APIM route |

## Secondary backend activation criteria

Keep the secondary backend disabled until the service owner approves every condition:

| Check | Condition to meet |
|---|---|
| Endpoint compatibility | The secondary endpoint exposes the same Responses-compatible operation shape as the primary endpoint |
| Model compatibility | The secondary model supports the request and response fields, safety behavior, latency expectation, and tool boundary used by the primary route |
| Agent version | The selected secondary agent version is immutable and approved for this workload |
| Data residency | The route keeps processing inside the approved geography or documented zone |
| Quota and cost | The owner approves the PTU or pay-as-you-go fallback impact |
| Safety | The same model-level RAI policy and APIM Content Safety policy apply |
| Telemetry | Correlation and token metrics use the same low-cardinality dimensions |
| Restore | The platform owner can disable the secondary route without changing the primary path |

## Related gateway paths

Microsoft Foundry can expose a Foundry-native AI Gateway setup path in the Foundry portal, backed
by Azure API Management. This session uses the repository-owned APIM deployment as the operating
route.

## Preview boundary

The unified model API can route by model name across providers. It is outside this session's
implementation path. Treat it as monitor-only until the organization approves a separate preview
decision.

## Token counter boundary

APIM token counters are local to each gateway. For multi-region routing, the API product owner
splits the approved workload allowance by region in Session 12. Do not assume a shared global
counter.

## Streaming token accounting

Streaming clients set `stream_options.include_usage` to `true`. The token metric policy uses
reported usage when the response includes it. An interrupted stream can leave that metric
incomplete. The token-limit policy estimates prompt and completion tokens for streaming calls.

Use these values for limits and monitoring. Azure Cost Management and the issued invoice are the
billing records.

Keep `llm-emit-token-metric` before `set-backend-service` in this policy. Its dimensions are API,
product, and subscription. Moving the policy would not add useful attribution to a backend-pool
member.
