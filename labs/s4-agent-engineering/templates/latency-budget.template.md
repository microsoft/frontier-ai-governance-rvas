# Latency budget record

Copy this blank record into the customer's approved records system. It records
customer-owned targets, evidence references, and ownership; it does not measure
latency or set a production service-level objective.

## Bounded scenario

| Field | Record |
|---|---|
| Interaction type and user population | |
| p50 / p95 / p99 expectation | |
| Budget owner | |
| Regression owner and review trigger | |
| Evidence location and review date | |

## Component attribution

| Component | Allocation target | Evidence reference | Attribution limit |
|---|---|---|---|
| Model inference | | | |
| Retrieval / vector search | | | |
| Tool calls / external APIs | | | |
| Orchestration / agent loop | | | |
| Gateway / network | | | |
| End-to-end, if available | | Application Insights, OpenTelemetry, or Foundry traces where enabled | |

Foundry tracing is an optional, project-gated evidence source. Record its
sampling, retention, population, and availability limits before using it.

## Implementation backlog

| Backlog item | Applies / N/A / unknown / later | Recommendation and confidence | Evidence reference or gap | Owner | Later session or customer process |
|---|---|---|---|---|---|
| Component attribution and latency evidence source | | | | | Engineering / platform operations |
| Regression threshold, review route, and escalation owner | | | | | Customer operating process / S11 |
| Operating-review handoff for latency drift | | | | | S11 |
