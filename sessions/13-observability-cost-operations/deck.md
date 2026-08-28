---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation - Session 13</p>

# Observability, cost, and operational controls

240 minutes - Trace an approved request, route alerts, and assign cost

<!-- Notes: Session 12 connected red-team behavior to detection. This session adds the operating views, routes, and cost controls for one service. -->

---

## Control objective

> Deploy privacy-safe operating controls for one governed service. Connect supported runtime spans, route alerts, notify owners at budget thresholds, and follow incident paths with named owners.

### Result check

- An approved synthetic request is traceable across supported gateway, agent, model, and tool spans.
- Tool failure stays separate from model failure.
- Standard logs leave out sensitive input.
- Operational and AI-quality alerts route to named owners.
- Usage, tags, and budget notifications support cost accountability without stopping spend.

<!-- Notes: The objective is decision-ready operations, not maximum logs. -->

---

## Why it matters

Operators need enough joined runtime context to tell whether the service, a tool, or the model is failing.

The workbook and alert routes support that decision without pooling records from every system.

Cost tags and budget notifications give the cost owner a delayed billing view. The incident runbook names the owner who contains each failure.

<!-- Notes: A budget notifies. It does not stop spend. -->

---

## Implementation outcomes

1. Keep privacy-safe OpenTelemetry settings for supported runtime spans.
2. Deploy a shared workbook and three alert rules that route to named owners.
3. Keep bounded token metrics and low-cardinality allocation tags.
4. Deploy budget notifications that do not stop resources.
5. Use the four incident paths in the runbook and run the release smoke check from the Session 14 GitHub promotion workflow.

<!-- Notes: Standard mode ends with one composite visible check. -->

---

## Required state when joining here

Teams joining here confirm this state before they begin the session.

| Existing control | What must already work | How the owner confirms it |
|---|---|---|
| Runtime | Project, fixed agent, identity, network, APIM policy, tool scopes, data policy | Owners confirm that one read-only request reaches only the backend and tool listed in the baseline |
| Tracing | OpenTelemetry and APIM propagation configuration | Observability owner joins gateway, agent, model, and tool spans with separate results |
| Evaluation | Definition, threshold policy, approved aggregate result | AI quality owner gets the recorded pass or block for the deployed version |
| Security | Payload-free red-team summary, Defender onboarding, event route | Security owner finds blocked actions and one expected runtime signal |

<!-- Notes: Each row names the existing control, the state needed for this session, and the owner who checks it. -->

---

<!-- _class: section-divider -->

# Operate one service without pooling its records

Runtime spans share approved context. Cost, evaluation, and security records stay in their source systems.

<!-- Notes: Correlation is the join key; governed systems remain the sources of truth. -->

---

## Architecture overview

<!-- _class: diagram -->

![An approved synthetic request carries trace context through API Management, agent, model, and tool spans. Application Insights feeds workbooks and alerts. Evaluation, security, and cost records stay in their source systems.](assets/diagrams/operational-correlation-flow.svg)

<!-- Notes: Treat the request as the spine of the operating view. W3C trace context links the gateway, agent, model, and tool spans, and each span keeps its own result. This lets an operator locate the failing hop. Application Insights stores runtime telemetry. Cost, evaluation, and security records remain in their source systems. The Session 14 GitHub workflow uses its temporary smoke output. -->

---

## What this means

One request keeps the same W3C trace identifier through API Management, the agent, the model, and
the tool. Application Insights joins those runtime spans. Cost, evaluation, and security records
stay in their source systems. The Session 14 GitHub workflow consumes its temporary smoke result.

---

## Where records stay and how operators use them

| System | Record stored there | How operators use it |
|---|---|---|
| Application Insights | Runtime telemetry | Follow one request, keep tool failure separate from model failure, and use the workbook |
| Azure Monitor | Alert state and notification route | Send the selected failure path to its owner |
| Cost Management | Billed cost | Confirm cost after the usual 8-24 hour reporting delay |
| Source-controlled gateway configuration | API Management policy | Govern trace propagation and low-cardinality token estimates |
| Defender and SOC | Security and incident records | Investigate and contain security failures |

<!-- Notes: The boundary covers correlation, monitoring, notification, and incident paths with named owners. Token metrics estimate usage; Cost Management stores the billing records. The design links records without pooling them. -->

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Chosen approach | Why | Limit |
|---|---|---|---|
| Runtime content | Exclude prompts, responses, and tool payloads | Trace service behavior without creating a content archive | Content diagnosis needs separate, time-limited approval |
| Trace volume | Sample where traces begin; keep selected traces complete and metrics unsampled | Keep joined traces while bounding ingestion | Rare failures may need approved sampling exceptions |
| Cost signal | Use APIM token metrics for estimates and Cost Management for billing | Give operators a fast estimate while keeping the authoritative bill | Counts can be incomplete; billing normally lags 8-24 hours |

<!-- Notes: These choices protect privacy and cost without pretending that one signal can answer every operating question. -->

---

## Logging rules

![Application Insights](assets/icons/microsoft/application-insights.svg)

Foundry tracing is generally available for prompt and hosted agents.

Workflow and external agents remain preview and need an approved nonproduction preview-use decision.

### Required signals

`gateway.request` · `agent.invoke` · `model.invoke` · `tool.invoke` · `evaluation.result` · `security.signal`

### Required context

service · environment · operation type · model deployment · agent version · tool name · result

**One W3C trace across supported runtime spans** with one non-sensitive correlation ID and separate success states.

<!-- Notes: A tool error must not be relabeled as model failure. -->

---

<!-- _class: decision -->

## Decision gate 1 - What may logs contain?

### Standard logs include

- stable service and deployment aliases
- operation type and result
- duration, error, token, and evaluation metrics
- non-sensitive correlation and trace identifiers

### Standard logs leave out

- prompts, responses, and tool payloads
- authorization, cookies, and URL queries
- user IDs, email, customer data, and free text

Stop if filtering happens after export or content capture cannot be disabled.

<!-- Notes: OpenTelemetry does not discover the customer's sensitive-data policy for us. -->

---

## Sampling protects signal and spend

![Azure Monitor](assets/icons/microsoft/azure-monitor.svg)

| Signal | Operating rule |
|---|---|
| Metrics | Do not sample |
| Traces | Fixed-rate or rate-limited source sampling |
| Logs | Error-first; actionable warnings only |
| Errors and security | Observability owner configures them to bypass normal trace sampling and tests with existing safe records |
| Daily cap | Last resort; it creates a logging gap |

Preserve complete traces. Validate the selected language and distro behavior.

<!-- Notes: Sampling is both a diagnostic and a cost decision. -->

---

<!-- _class: decision -->

## Decision gate 2 - Is content logging justified?

When the exception is `Disabled`, set its detail fields to `N/A`.

Default: **Disabled**

An exception needs:

1. a limited operational purpose;
2. an isolated approved scope;
3. an access owner listed in the runbook;
4. explicit retention and deletion;
5. an expiry date; and
6. data-protection approval.

Keep exception content in the approved logging store. Remove access at expiry.

<!-- Notes: A content exception is a separate data-processing decision, not a tracing toggle. -->

---

## Workbook: operating view

The deployed workbook shows:

- Are requests succeeding within latency SLOs?
- Which model, agent version, or tool is failing?
- Are quality or safety evaluation signals degrading?
- How many tokens pass through the gateway?
- Can one correlation ID reconstruct the operation?

It is not a prompt browser or billing ledger.

<!-- Notes: Keep the workbook useful under the privacy boundary. -->

---

## Alert families

Review baseline logs before setting alert thresholds.

| Alert | Signal | Owner question |
|---|---|---|
| Request error rate | Failed request percentage | Is the service unhealthy? |
| Tool failures | Failed `tool` dependencies | Is authorization, backend, or tool behavior failing? |
| Quality or safety | Failed `ai.evaluation` events | Is behavior degrading despite service availability? |

Use baseline-derived thresholds, evaluation windows, and an approved action group.

<!-- Notes: Availability, tool process, and AI quality are independent dimensions. -->

---

## Token metrics need a cardinality budget

![Azure API Management](assets/icons/microsoft/azure-api-management.svg)

`llm-emit-token-metric` supports at most five custom dimensions.

API Management tracks at most 100 unique values per dimension and 1,000 active time series
per metric namespace. New values or series beyond either limit are silently discarded.

### Approved

environment · service · model deployment · agent version · tool name

### Not allowed

user · email · request ID · correlation ID · prompt · response · free text

Interrupted streams and model behavior can also make token counts incomplete.

<!-- Notes: High-cardinality labels silently destroy both reliability and cost control. -->

---

## Cost timing

### Operational clock

APIM token metrics provide near-real-time usage signals for routing, anomaly detection, and cost estimates.

### Billing clock

Cost Management data typically arrives 8-24 hours later. Its billed cost is authoritative.

### Budget behavior

Actual and forecast thresholds notify owners. **They do not stop resources.**

<!-- Notes: Never describe the budget as a kill switch. -->

---

## Incident paths

| Trigger | First containment |
|---|---|
| Unsafe output | Incident commander directs containment; service owner routes away from the affected version |
| Runaway tokens or cost | Incident commander directs the gateway owner to apply existing limits |
| Tool compromise | Tool owner disables the binding; credential owner revokes or rotates the credential |
| Model degradation | Service owner returns to the last approved deployment and evaluates |

Keep logs, Defender, and SOC routing active unless they are the confirmed fault.

<!-- Notes: Detailed data stays in its governed source system. -->

---

<!-- _class: implementation -->

## Deploy linked logs, alerts, and budget

Timebox: 95 minutes

1. Resolve log, retention, alert, and cost settings. Name the owner for each.
2. Confirm the approved OpenTelemetry instrumentation was deployed during pre-work.
3. Confirm the reviewed APIM correlation and token-metric fragment was merged during pre-work.
4. Inspect both Bicep what-if previews.
5. Deploy the workbook, alerts, and budget.

<!-- Notes: Stop before state change if scope, content, or owner decisions remain unresolved. -->

---

## Safe preflight

Preflight checks:

- every decision sentinel and machine-artifact syntax;
- approved nonproduction scope and Application Insights target;
- W3C propagation and required span kinds;
- logs content that is not allowed and dimensions;
- the approved sampling settings;
- action group and budget amount;
- both Bicep templates; and
- resource-group and subscription what-if previews.

The deployment operator uses Monitoring Contributor on the deployment resource group, Log Analytics Reader on the workspace, Monitoring Reader on monitored resources outside the group, and Cost Management Contributor on the subscription.

Human access expires after the confirmation check.

<!-- Notes: Preflight creates no request, alert, or test resource. -->

---

## Deployment path

Complete instrumentation and the customer-owned APIM policy merge before the session.

The gateway repository contains the deployed APIM policy and preserves the Session 07 authentication, token-limit, rate-limit, routing, content-safety, and backend controls.

```powershell
.\scripts\preflight.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -ApprovedResourceGroupName $approvedResourceGroupName `
  -ApprovedApplicationInsightsResourceId $approvedApplicationInsightsResourceId `
  -DeploymentLocation $deploymentLocation
```

Then deploy the following:

1. workbook and three alerts at resource-group scope;
2. budget at subscription scope; and
3. application and APIM changes through their existing delivery paths.

<!-- Notes: Preflight reads the gateway owner's policy source instead of a Session 13 copy. -->

---

## Confirm the result

Run the paired `smoke.ps1` or `smoke.sh` interface against the normal and handled-failure routes.

Use `pipeline`, `nonproduction`, the release commit SHA, and a runner-temporary result path.

Confirm that the check shows:

- successful model and tool dependencies for the normal operation;
- a failed tool dependency and independent successful model result for the failure operation;
- expected operational, token, and quality fields; and
- no run-specific probe marker in request, dependency, event, trace, exception, or custom-property data.

The JSON result is payload-free, stays in the GitHub runner's temporary workspace, and is consumed
unchanged by Session 14.

Stop on a missing hop, collapsed failure boundary, commit mismatch, or sensitive content.

Application Insights can receive linked records at different times.

Poll both correlation IDs for the 180-second default wait window before treating a missing record as a failed check.

Resolve the live component workspace before querying.

Both request records must carry the CLI commit SHA in `release.commit.sha`. The result copies that SHA only after both values match.

Keep the normal and failure IDs distinct. After readiness, require three consecutive query results
with the same counts and latest `TimeGenerated` value. The final query must not contain any
prohibited telemetry property.

<!-- Notes: Do not weaken redaction to make a trace complete. -->

---

## Stop conditions

Stop immediately if you find:

- production or the wrong Application Insights scope;
- missing or inconsistent trace context;
- content, credentials, query strings, user data, or free text in logs;
- high-cardinality token dimensions;
- thresholds without baseline or owner;
- an APIM policy change that removes or replaces Session 07 authentication, token-limit, rate-limit, routing, content-safety, or backend controls;
- a what-if with unrelated changes; or
- a budget presented as real-time enforcement.

<!-- Notes: An incomplete safe trace is better than a complete unsafe trace. -->

---

## Responsibilities after deployment

| Owner | Operational responsibility |
|---|---|
| Service owner | SLO and service operating decision |
| Observability owner | Instrumentation, sampling, retention, workbook, alerts |
| Gateway owner | Customer-owned APIM policy source, correlation, and token metrics |
| Tool owner | Tool span accuracy and independent authorization |
| AI quality owner | Evaluation signals and thresholds |
| Security operations | Security correlation and incident route |
| Cost owner | Tags, budget, and billing reconciliation |

<!-- Notes: Session 14 later controls promotion of these definitions. -->

---

## Manual restore

1. Route to the last approved application version.
2. Restore the previous APIM policy through the [Session 07](../07-apim-ai-gateway/) path.
3. Disable only noisy Session 13 alerts while correcting them.
4. Remove only approved resources tagged `implementationSession=12`.
5. Delete the Session 13 budget only with cost-owner approval.
6. Preserve records required by an active incident or retention decision.

Do not disable monitoring or defense to silence a real signal.

<!-- Notes: Shared application and gateway paths make automated restore unsafe here. -->

---

## Recap

- A distributed trace with separate service records
- Privacy-safe logs by default
- Baseline-derived operational and AI-quality alerts
- Low-cardinality token allocation
- Budget notification, not automatic shutdown
- Four incident paths with named owners
- One paired release smoke check with no retained Session 13 output

<!-- Notes: The implementation definitions cover logs, alert routing, cost allocation, and incident response. -->

---

<!-- _class: closing -->

# Thank you!

<!-- Notes: Next, Session 14 moves the definitions through controlled CI/CD and promotion. -->
