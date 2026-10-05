# Govern responsible AI impact, transparency, and oversight

## Module scope

### What we will do

**Objective.** Put one governed Foundry agent under a responsible-AI decision file and a human approval gate.

This module records the AI system inventory entry, use-case intake result, Article 5 screen, EU AI Act risk class, Article 50 transparency obligations, impact assessment, and transparency note for the agent from Session 04. It then adds a pause-and-resume approval gate to one consequential tool and checks that approval executes the tool while rejection does not.

### Why it matters

**Problem.** A governed agent can pass technical deployment checks and still lack a clear record of why it is acceptable, what users must be told, and which human can stop a consequential action.

**Solution.** This module puts those decisions in durable records and binds the highest-risk tool to human approval before execution.

**[EU AI Act](https://eur-lex.europa.eu/eli/reg/2024/1689/oj/eng).** This module supports Article 5 (prohibited practices) with the screen, Article 6 and Annex III (high-risk classification) with the risk class, Articles 9 and 27 (risk management and fundamental rights impact assessment) with the impact assessment, Articles 13 and 50 (transparency) with the transparency note and disclosures, and Articles 14 and 26(2) (human oversight) with the approval gate.

### Boundaries

This module sits outside the numbered session sequence.

It changes the responsible-AI records and one runtime approval path for one approved Foundry agent. Microsoft Foundry and the agent runtime remain authoritative for live agent state. The repository stores the decision contract and approval-gate code.

Session 09 owns evaluation release gates. Session 10 owns red-team and Defender checks. Session 14 owns estate-wide lifecycle operations. This module records decisions for one system and tests one approval gate. **It is not legal advice.** Legal or compliance counsel owns final classification and disclosure wording.

## Architecture

### Architecture at a glance

The flow starts with the Foundry agent already created by the governed agent baseline. The product owner completes the system record and the responsible-AI records. The runtime owner deploys the approval gate beside the agent application and binds one write or irreversible tool to it.

The gate has two phases. First, the agent proposes a tool call and the gate returns an `awaiting_approval` state with a correlation ID and an argument hash. The HTTP endpoint stores the pending call in memory for this nonproduction module. Then a different authenticated approver resumes the same task with `approved` or `rejected`. The gate reads the requester and approver from App Service authentication headers, decodes `X-MS-CLIENT-PRINCIPAL`, and requires the configured role or group claim before approval. Approval executes the original pending arguments against the configured tool route. Rejection returns without tool execution.

`ai-system-inventory-entry.json` is the machine record. `impact-assessment.md` and `transparency-note.md` are the human records. `oversight-decision.json` ties the approver role, action class, retention, and stop mechanism to the runtime code.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefit | Cost or limit |
|---|---|---|---|
| System record | One schema-checked JSON inventory entry | The responsible-AI owner can enforce enum values before handoff | Legal still reviews the classification |
| Impact and transparency records | Markdown records with required decisions | Product, risk, and communications reviewers can read them without tooling | They are pointers to the approved customer record system, not a full archive |
| Oversight pattern | Foundry hosted-agent pause and resume | The agent can wait for a human decision without keeping one request open | The Learn page marks long-running agents as preview |
| Tool boundary | One write or irreversible tool uses `always_require` approval | The consequential action never runs on a rejected path | The runtime owner must bind every future consequential tool separately |
| Approver identity | App Service authentication headers identify the requester and approver | The app does not trust self-asserted approver values and blocks self-approval | The gate must run behind Microsoft Entra authentication with an approver role or group claim |
| Pending state | In-memory task store for nonproduction delivery | Keeps the module small and easy to inspect | Production use needs the approved durable store in `oversight-decision.json` |
| Preview | No platform what-if for the approval code | Preflight catches unresolved decisions before deployment | The deployed approved and rejected checks are still required |

### Architecture guidance

Use [Transparency Note for Foundry Agent Service](https://learn.microsoft.com/en-us/azure/foundry/responsible-ai/agents/transparency-note) to frame agent capabilities, limits, and human-oversight cautions for the system note.

Use [Add a human-in-the-loop approval step](https://learn.microsoft.com/en-us/azure/foundry/agents/how-to/add-human-in-the-loop) for the Foundry hosted-agent pause-and-resume pattern. The page marks long-running agents as preview, so keep this in a nonproduction path until the customer approves preview use.

Use [Work with user identities in Azure App Service authentication](https://learn.microsoft.com/azure/app-service/configure-authentication-user-identities) for the platform-injected identity headers. The approval gate requires `X-MS-CLIENT-PRINCIPAL`, `X-MS-CLIENT-PRINCIPAL-ID`, and `X-MS-CLIENT-PRINCIPAL-NAME` on start and resume.

## Before you start

Confirm these prerequisites:

- The agent exists in the approved nonproduction Foundry project from the governed agent baseline.
- The agent owner can name the exact agent version, tool list, runtime owner, and approved release path.
- The product owner, responsible-AI lead, and legal or compliance reviewer can resolve the inventory, impact, and transparency decisions.
- The runtime owner can deploy the approval gate through the approved application pipeline and can protect any tool execution endpoint outside this repository.
- The approval gate runs behind App Service authentication with Microsoft Entra ID, so App Service injects `X-MS-CLIENT-PRINCIPAL`, `X-MS-CLIENT-PRINCIPAL-ID`, and `X-MS-CLIENT-PRINCIPAL-NAME` for the authenticated requester and approver.
- The Entra app role or group claim in `oversight-decision.json` is assigned to the approver identity and not to the requester identity used in the delivery check.
- The delivery owner has two synthetic payload files outside this repository, one for the approved path and one for the rejected path.
- The approver role is trained on this system, has authority to reject the action, and can trigger the recorded stop mechanism.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Runtime | [`artifacts/records/ai-system-inventory-entry.schema.json`](artifacts/records/ai-system-inventory-entry.schema.json) | The responsible-AI inventory workflow and preflight scripts |
| Record | [`artifacts/records/ai-system-inventory-entry.json`](artifacts/records/ai-system-inventory-entry.json) | The responsible-AI inventory owner and preflight scripts |
| Record | [`artifacts/records/impact-assessment.md`](artifacts/records/impact-assessment.md) | The product owner, responsible-AI lead, and legal or privacy reviewers |
| Record | [`artifacts/records/transparency-note.md`](artifacts/records/transparency-note.md) | The product owner, communications reviewer, and transparency owner |
| Record | [`artifacts/oversight/oversight-decision.json`](artifacts/oversight/oversight-decision.json) | The runtime owner, approver role, delivery owner, and preflight scripts |
| Runtime | [`artifacts/runtime/foundry_human_approval_gate.py`](artifacts/runtime/foundry_human_approval_gate.py) | The approved Foundry agent runtime |
| Runtime | [`artifacts/runtime/requirements.txt`](artifacts/runtime/requirements.txt) | The agent runtime build process |

Resolve artifact values in the approved private configuration path. Keep customer data, tenant IDs, endpoints, prompts, traces, access tokens, and raw approval payloads out of this repository.

## Decisions and stop conditions

### Responsible-AI record

Record one AI system. The record must point to the selected Foundry project, agent, and version. The target scope is `one-approved-foundry-agent`.

Stop if the Foundry reference is missing, if more than one agent is in scope, or if the record names a production system without a separate approval.

### Article 5 and risk class

The Article 5 screen must be `passed` or `flagged-resolved`. A `blocked` result stops the module.

The risk class must use one of the schema values. If the class is `prohibited`, stop. If legal or compliance cannot review the class, stop. Do not use this module to work around a legal decision.

### Transparency

The transparency note must include first-interaction disclosure text, upstream Microsoft documentation, known limits, evaluation summary, user notice channel, monitoring route, and review cadence.

Stop if the disclosure text is missing, if the system generates synthetic media and the Article 50 marking decision is unresolved, or if the product owner cannot name who approves the published wording.

### Human oversight

The gated tool must be `write` or `irreversible`. The approval mode must stay `always_require`, and rejection must mean `do-not-execute-tool`.

The start endpoint stores the requester principal. The resume endpoint must use App Service authentication headers for the approver identity. It rejects a resume call without `X-MS-CLIENT-PRINCIPAL`, `X-MS-CLIENT-PRINCIPAL-ID`, and `X-MS-CLIENT-PRINCIPAL-NAME`. It also rejects self-approval and any approver missing the configured role or group claim.

Stop if the proposed tool is read-only, if the action has no trained approver role, if the approver cannot reject it, if there is no decision store, if the approval gate is not behind App Service authentication, or if the stop mechanism is outside the runtime owner's control.

### Pending request store

The HTTP endpoint in this module stores pending task state in process memory. That is acceptable for a nonproduction module check. It is not a production store. The runtime owner must replace it with the approved durable store before production use or before any scenario where a restart, scale-out, or multi-instance deployment can lose pending approvals.

Stop if the runtime host uses more than one approval-gate instance and does not have a shared pending-task store.

## Field reference

| Field | Required value |
|---|---|
| `implementationSession` | `optional-module-responsible-ai-impact-oversight` in both JSON records |
| `targetScope` | `one-approved-foundry-agent` |
| `system.systemType` | `agent` for this module |
| `system.autonomyLevel` | `approval-required` when the selected tool is consequential |
| `euAiAct.article5Screening.outcome` | `passed` or `flagged-resolved` |
| `euAiAct.article50Obligations` | One or more allowed values, or `none` by itself |
| `gatedTool.actionClass` | `write` or `irreversible` |
| `gatedTool.approvalMode` | `always_require` |
| `gatedTool.rejectionBehavior` | `do-not-execute-tool` |
| `authentication.principalSource` | `app-service-authentication-headers` |
| `authentication.requiredHeaders` | `X-MS-CLIENT-PRINCIPAL`, `X-MS-CLIENT-PRINCIPAL-ID`, `X-MS-CLIENT-PRINCIPAL-NAME` |
| `authentication.approverClaim.claimType` | `roles` or `groups` |
| `authentication.approverClaim.claimValue` | Approved app role or group claim value |
| `records.pendingRequestStore` | `in-memory-nonproduction` |
| `verification.approvedDecision` | `approved-executed` |
| `verification.rejectedDecision` | `rejected-not-executed` |

## Implement

### 1. Complete the responsible-AI records

Fill every `__REQUIRED_*__` value in the artifacts. Use role names and approved system references, not personal data.

Run preflight:

```powershell
.\scripts\preflight.ps1 -TargetScope "one-approved-foundry-agent"
```

```bash
./scripts/preflight.sh --target-scope "one-approved-foundry-agent"
```

Preflight rejects unresolved decisions, invalid enum values, a blocked Article 5 screen, a prohibited risk class, and an oversight design that would allow rejected tool execution. There is no read-only deployment preview for the approval code.

### 2. Review the records with the owners

The product owner reviews the inventory entry, intended use, affected groups, and residual risk. Legal or compliance reviews the Article 5 screen, risk class, FRIA flag, and Article 50 obligations. The transparency owner reviews the disclosure and notice path.

Do not continue until the reviewers can explain the system's intended use, classification, user notice, and stop path.

### 3. Deploy the approval gate

The runtime owner copies `artifacts/runtime/` into the approved agent application repository or package, resolves `OVERSIGHT_DECISION_PATH` to the approved customer copy of `oversight-decision.json`, sets `OVERSIGHT_TOOL_EXECUTION_URL` to the approved tool execution route, sets `OVERSIGHT_DECISION_LOG_PATH` to the approved decision-log file or mounted store path, and deploys through the normal pipeline.

If the application uses the HTTP contract, expose `/approval/start` and `/approval/resume` over HTTPS behind App Service authentication. If it uses hosted-agent tasks directly, front the hosted task with the same authenticated HTTP gate. The hosted entry point must receive authenticated transport metadata from the gate; it must not accept requester or approver identity from task input. Keep the task checkpoint outside this repository.

If `OVERSIGHT_TOOL_EXECUTION_URL` or `OVERSIGHT_DECISION_LOG_PATH` is unset, the gate fails closed with HTTP 503 and `toolExecuted: false`.

### 4. Prepare the verification payloads

Create two synthetic payload files outside this repository. Each file contains a `taskId`, `toolName`, `arguments`, and `reason`. Use safe synthetic arguments.

Set `OVERSIGHT_VERIFY_REQUESTER_BEARER_TOKEN` for the requester and `OVERSIGHT_VERIFY_APPROVER_BEARER_TOKEN` for the approver. They must be distinct. The verify scripts read them from the environment and never accept them as arguments. The scripts do not send an approver value; App Service authentication must inject the caller identity headers and claims.

### 5. Run the delivery check

```powershell
.\scripts\verify.ps1 `
  -ApprovalGateEndpoint "https://<approved oversight gate host>" `
  -ApprovedPayloadFile $approvedPayloadFile `
  -RejectedPayloadFile $rejectedPayloadFile
```

```bash
./scripts/verify.sh \
  --approval-gate-endpoint "https://<approved oversight gate host>" \
  --approved-payload-file "$approved_payload_file" \
  --rejected-payload-file "$rejected_payload_file"
```

The scripts call the gate once for approval and once for rejection. They do not print payloads or tokens.

## Confirm the result

### Intended path

The approved synthetic call returns `approved-executed`, `toolExecuted: true`, and a correlation ID. The approver sees the tool name, reason, and argument hash before approval.

### Blocked path

The rejected synthetic call returns `rejected-not-executed`, `toolExecuted: false`, and a correlation ID. The tool endpoint receives no execution request for that rejected task.

### Delivery-owner checkpoint

The delivery owner observes both results, confirms that the approver role can reject the action, and confirms that the stop mechanism in `oversight-decision.json` is reachable. Keep the tool disabled if either path fails.

## After implementation

| What remains | Owner |
|---|---|
| AI system inventory entry and risk class | Responsible-AI inventory owner |
| Impact assessment and sign-off path | Product owner and responsible-AI lead |
| Transparency note and disclosure copy | Transparency owner and legal or communications reviewer |
| Approval-gate runtime and deployment | Runtime owner |
| Approval decision store and retention | Operations owner |
| Stop mechanism and tool disablement path | Runtime owner and delivery owner |

Restore through the approved application and governance change paths:

1. Disable the consequential tool or remove it from the agent's tool list if approval checks fail.
2. Restore the last approved runtime package if the approval gate causes a fault.
3. Revert the transparency note or disclosure text only through the product owner's review path.
4. Retire the approval gate only after the responsible-AI lead accepts that the tool no longer needs approval, or after the tool is removed.

Do not delete the decision records while the agent remains in use. Update them when the intended use, model, tool set, approver role, risk class, or Article 50 obligation changes.
