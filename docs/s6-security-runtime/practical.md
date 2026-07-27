# Practical workshop: runtime security control path

**Microsoft default:** Azure API Management AI Gateway, Azure AI Content Safety Prompt Shields, Defender for Cloud AI posture, Defender XDR, Sentinel, and Application Insights.

**Customer decision:** Approve, defer, reject, or route the runtime security control path.

## Work the decision

1. Select one bounded pilot or backlog item and name the customer decision owner.
2. Inspect the gateway policy route, Prompt Shields coverage, Defender for Cloud AI posture finding, Defender XDR/Sentinel routing, and Application Insights telemetry plan.
   - Evidence example: runtime traffic has a gateway policy, prompt-shield setting, posture finding owner, SOC route, and trace correlation field.
   - Defer blocker example: blocked prompts, anomalous tool calls, or security alerts cannot be traced to an incident queue.
   - Acceptance-test cue: prepared tests cover prompt injection blocking, alert routing, and trace lookup using customer-approved telemetry.
3. Fill this row in the customer-approved records system:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Pilot decision | Azure API Management AI Gateway, Azure AI Content Safety Prompt Shields, Defender for Cloud AI posture, Defender XDR, Sentinel, and Application Insights | Security operations owner | Customer-approved record | Decision, acceptance test, exception status, and handoff are complete | Customer date | SOC |

4. Use this decision tree: if the Microsoft path fits, approve it; if records are missing, defer with an acceptance test; if the path cannot meet the use case, reject or route to an exception owner.
5. For an exception, record: reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

**Boundary:** Keep customer data in customer-approved systems; production changes require customer change approval.
