---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Session 06</p>

# Operate Citadel telemetry, cost, and incidents

240 minutes · Correlate the path without creating a content archive

---

## Why it matters

Gateway, model, agent, and tool failures look the same without joined telemetry.

One safe correlation ID separates the failing component and connects it to cost, alert, and incident ownership.

---

## Architecture overview

![Azure Monitor](assets/icons/microsoft/azure-monitor.svg)

```text
APIM diagnostics -> Application Insights -> alerts
LLM diagnostics  -> Log Analytics -> operational queries
usage metrics    -> scheduled workflow -> Cosmos DB
Azure billing    -> Cost Management
```

The four paths have different latency, retention, and authority.

---

## Correlation without content capture

```text
gateway span -> agent span -> model or tool span
       \________ safe correlation ID ________/
```

Keep prompts, responses, credentials, and tool payloads out of standard logging. Metadata remains enough to locate the failing component and owner.

---

## Cost is two signals

| Operational allocation | Authoritative bill |
| --- | --- |
| Scheduled usage processing into Cosmos DB | Azure Cost Management |
| Product, model, backend, and application views | Billed Azure cost |
| Useful for showback | Arrives later |

Budgets notify. They do not stop consumption.

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Default |
| --- | --- |
| Content logging | Disabled |
| External export | Disabled |
| Alert source | Application Insights metrics |
| Allocation | Scheduled usage records in Cosmos DB |
| Alert dimensions | Bounded service and contract fields |

---

<!-- _class: implementation -->

## Working path

1. Complete telemetry, retention, and logging decisions.
2. Preview and deploy workbook, alerts, and budget.
3. Open the workbook and parse each query.
4. Run normal and handled-failure smoke paths.
5. Confirm the incident and cost owners.

---

## Safety gates

- Reject telemetry fields that can capture prompts, credentials, or tool payloads.
- Bound alert dimensions before deployment.
- Stop when a query cannot preserve the approved correlation path.

---

## Expected result

Operators can find where a synthetic request failed, who owns it, and which release produced it. The telemetry contains no prohibited payload fields.

---

## Operating state

Operations owns the workbook, alerts, budget, retention, and incident route. Product teams use the shared correlation ID when they troubleshoot their path.

---

<!-- _class: closing -->

# Thank you!
