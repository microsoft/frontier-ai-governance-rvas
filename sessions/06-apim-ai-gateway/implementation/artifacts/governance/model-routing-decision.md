# APIM model-routing decision

This record keeps the routing decision for the Session 06 APIM gateway. APIM remains authoritative
for the live backend pool and policy. This file records the owner-approved routing boundary that the
deployment must preserve.

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

Do not enable the secondary backend until the service owner approves all of these checks:

| Check | Required state |
|---|---|
| Endpoint compatibility | The secondary endpoint exposes the same Responses-compatible operation shape as the primary endpoint |
| Model compatibility | The secondary model supports the same request fields, response fields, safety behavior, latency expectation, and tool boundary used by the primary route |
| Agent version | The selected secondary agent version is immutable and approved for this workload |
| Data residency | The route keeps processing inside the approved geography or documented zone |
| Quota and cost | The owner approves the PTU or pay-as-you-go fallback impact |
| Safety | The same model-level RAI policy and APIM Content Safety policy apply |
| Telemetry | Correlation and token metrics use the same low-cardinality dimensions |
| Restore | The platform owner can disable the secondary route without changing the primary path |

## Related gateway paths

Microsoft Foundry can surface a Foundry-native AI Gateway setup path through the Foundry portal,
backed by Azure API Management. This session keeps the repository-owned APIM deployment as the
operational route.

## Preview boundary

The unified model API can route by model name across multiple providers, but it remains outside this
session's implementation path. Record it as a monitor-only option unless the organization approves a
separate preview adoption decision.

## Token counter boundary

APIM token counters are gateway-local. For multi-region routing, the API product owner splits the
approved workload allowance by region in Session 14 rather than assuming one shared global counter.
