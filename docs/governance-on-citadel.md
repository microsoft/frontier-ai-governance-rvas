# Governance Built on Citadel

## The simple framing

Citadel builds the governed road. RVAS writes the traffic rules, assigns owners, checks whether drivers obey them, and keeps the audit log.

For a full production path, do not treat RVAS as a second platform. The straight line is:

1. **Deploy or connect AI Hub Gateway / Citadel Governance Hub.**
2. Use RVAS to build the governance operating model around it.
3. Leave the customer with evidence, owners, scorecards, and remediation backlog.

Citadel answers: "Where do AI calls flow, and which runtime controls are enforced?"

RVAS answers: "Who owns those agents, what data may they use, how are risks tested, and what evidence proves the controls work?"

## What Citadel provides

AI Hub Gateway / Citadel Governance Hub is the Azure-plane platform foundation. It provides the runtime control point and platform evidence that governance can rely on.

| Citadel provides | Simple meaning |
|---|---|
| **APIM AI gateway** | All approved AI traffic has a central front door. |
| **Access Contracts** | Teams/apps get an approved way to consume models and tools. |
| **Backend Contracts** | Platform teams define which backends/models are exposed and under what policies. |
| **API Center registry** | AI APIs, products, routes, and platform exposure are cataloged. |
| **Gateway auth** | Entra/JWT/app-role checks protect the runtime gateway. |
| **Prompt Shields / Content Safety** | Runtime safety checks happen before requests reach model backends. |
| **PII masking** | Sensitive values can be masked at the gateway. |
| **Telemetry and FinOps** | Usage, cost, routing, and safety signals are captured centrally. |

## What RVAS provides

RVAS turns that platform into an enterprise governance system.

| RVAS provides | Simple meaning |
|---|---|
| Human ownership | Every important agent/use case has a sponsor and accountable owner. |
| Identity governance | Agent identity, Conditional Access posture, and lifecycle state are reviewed. |
| Data governance | Purview, DLP, audit, and information protection evidence show what data can be used. |
| Security governance | Defender posture, threat protection, and runtime safety evidence are reviewed by SOC/security owners. |
| Evaluation governance | Quality and safety tests become release gates, not informal checks. |
| Red-team governance | Adversarial findings become tracked risks and remediation actions. |
| Control-plane reconciliation | Citadel/API Center, Agent 365, Entra Agent ID, and owner records are compared so shadow or unowned agents surface. |
| Maturity evidence | The customer can show what improved from baseline to exit score. |

## Practical examples

### Example 1 - A team wants to use GPT-4.1

Citadel provides

- A gateway route through APIM.
- A backend contract for the model.
- An access contract for the consuming app/team.
- Token limits, auth, routing, and telemetry.

RVAS builds governance

- Who owns the use case?
- Which human sponsor approved it?
- Which agent or app identity is allowed?
- What data classification is permitted?
- What DLP and security evidence must be reviewed?
- What evaluation score must pass before production?
- What residual risks are accepted or assigned?

### Example 2 - An agent sends sensitive data

Citadel provides

- Gateway PII masking.
- Gateway telemetry showing the call path.
- Runtime policy evidence.

RVAS builds governance

- Purview/DLP review of the data classes involved.
- Evidence that sensitive-data policy is configured and tested.
- A compliance owner for violations.
- An audit trail showing what happened and who reviewed it.

### Example 3 - A jailbreak attempt hits the gateway

Citadel provides

- Prompt Shields / Content Safety controls.
- Gateway logs and safety events.
- The runtime enforcement point.

RVAS builds governance

- SOC triage runbook.
- Severity and escalation path.
- Evidence capture for the safety hit.
- Remediation item for the app/agent owner.
- Follow-up evaluation or red-team test if needed.

### Example 4 - Leadership asks "are we governed?"

Citadel provides

- Platform catalog.
- Access contracts.
- Gateway logs.
- Usage and cost telemetry.

RVAS builds governance

- Baseline and exit maturity scores.
- Sponsor and owner register.
- Agent registry reconciliation.
- Evaluation and red-team scorecards.
- DLP, Defender, and runtime-safety evidence.
- A prioritized backlog of gaps and accepted risks.

## What we do not build here

RVAS does not rebuild Citadel:

- no duplicate APIM gateway path;
- no duplicate Content Safety deployment;
- no substitute API Center;
- no alternate access-contract system;
- no second telemetry platform.

If the needed platform capability belongs to Citadel, the action is to deploy, connect, or fix Citadel first. RVAS then governs and evidences the environment built around it.

## The takeaway

Use Citadel to establish the governed AI runtime platform.

Use RVAS to make that platform operationally governable: owned, data-aware, security-reviewed, evaluated, red-teamed, reconciled, and evidenced.

For deeper architecture details, see the [Citadel + RVAS Playbook](reference/citadel-rvas-playbook.md).
