# Facilitate the decision

**Decision question:** For this workload and period, which **signal source,
attribution method, alert route, and closure route** should the operating review
use? Record **approve, defer, reject, or route**.

| Phase | Time | Safe output |
|---|---:|---|
| Set scope | 10 min | Workload, period, owner, evidence reference, and coverage limit. |
| Map signal and attribution | 25 min | Source, correlation/attribution limit, alert owner, and route. |
| Test closure design | 25 min | Finding owner, validation, recurrence check, exception/closure route. |
| Decide and hand off | 30 min | Decision, acceptance evidence, target date, and S7/S12/S13 handoffs. |

**Azure/Microsoft default:** use Azure Monitor/Application Insights with
OpenTelemetry for customer application paths; add Microsoft Foundry
observability where it is available and covers the Foundry workload. Use an
exception only when a customer-approved source provides the needed signal with
documented coverage, retention, attribution, and owner. Verify availability and
configuration; do not claim an alert or telemetry configuration exists.
