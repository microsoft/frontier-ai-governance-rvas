# S8 · Authorized Red Teaming & Retest Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-27 · Validate AI Red Teaming Agent availability in the [Governance capability guide](../reference/governance-capability-guide.md) and current Microsoft Learn pages before delivery.

This page explains the safety-testing model behind S8. [S8 Prepare](index.md), [technical decisions](technical.md), and the lab runbook contain the field-level route and customer-operated sequence.

## Red teaming tests a defined safety objective

AI red teaming is an authorized defensive misuse test. The customer defines the target, category, success condition, limits, contacts, stop conditions, evidence handling, and response path before testing starts.

The goal is to find weaknesses while the customer can observe, contain, fix, and retest them. The workshop does not provide attack datasets, live endpoint clients, credentials, production tests, or bypass instructions.

S8 is limited to an authorized, customer-owned, non-production target with written rules of engagement and a notified SOC where required. The customer chooses and keeps the test data, prompts, outputs, scorecards, thresholds, success criteria, and retest evidence.

## Authorization is an operational control

Authorization prevents a useful safety test from becoming unbounded activity. A complete rules-of-engagement record names:

- target, version, environment, owner, dependency notes, and reset or rollback path;
- permitted operators, tools, categories, excluded categories, timing, and monitoring window;
- prohibited activity, data boundaries, cost or rate limits, stop condition, and escalation contact;
- SOC contact and legal/risk contact where required;
- evidence location, retention owner, and who may see prompts, outputs, scorecards, and findings;
- severity owner, remediation owner, accepted-risk authority, and retest criterion.

If any hard-gate item is missing, S8 records `defer`, `route`, or `blocked` instead of starting or accepting the test.

## The category is the unit of evidence

The adversarial category is what makes the evidence meaningful. "Red team passed" is not a useful claim. A useful package says which category was tested, what counted as success, what method was used, what target version was in scope, what sample or run record was reviewed, what threshold applied, and what limitation remains.

| Category | Typical question | Receiving owner if a finding appears |
|---|---|---|
| Direct prompt injection | Can direct user instructions override the intended policy or task boundary? | Prompt/design, runtime-control, or in-process policy owner |
| Indirect prompt injection | Can retrieved or tool-returned content manipulate the agent? | Data/retrieval, tool-response, runtime-control, or evaluation owner |
| Sensitive-data disclosure | Can the target expose data outside the approved purpose or audience? | Data, privacy, output-safety, or investigation owner |
| Tool abuse or unsafe action | Can the target invoke an unsafe action, parameter, or workflow? | Tool/API, identity, in-process policy, or catalog owner |
| Hallucination or grounding failure | Can the target produce unsupported claims in high-risk context? | Evaluation, retrieval, source-owner, or product owner |
| Harmful or policy-violating content | Can the target generate or enable prohibited content? | Content Safety, Prompt Shields, runtime-control, or safety owner |
| Protected material concern | Can the target produce protected material or unsupported reuse? | Legal/risk, evaluation rubric, or model owner |
| Cost or availability abuse | Can repeated or crafted requests exhaust quota, budget, or capacity? | Gateway, platform, FinOps, or operating owner |
| Unauthorized access | Can the target cross identity, tenant, data, or network boundaries? | Identity, platform, data, or SOC owner |

## Attack Success Rate is interpreted, not worshipped

![Authorized red-team evidence flows from rules of engagement to method, scorecard or run reference, threshold interpretation, remediation ownership, and retest closure.](../assets/diagrams/s8-red-teaming-asr-decision.svg)

Attack Success Rate (ASR) is the share of attempts that meet the agreed adversarial success condition. Lower is better, but the number only makes sense with its category, sample size, target version, run method, approved threshold, and reviewer.

A result above tolerance becomes a remediation item with severity owner and retest criterion. A result below tolerance supports only the tested scope and does not approve production release. Empty, synthetic, or not-comparable results are not safety proof unless the scope, sample, method, reviewer, and limitations are recorded.

For each category, ask five plain questions: what behavior did we test, what counted as success, why would that response be unacceptable, who owns the severity/remediation decision, and what would prove the fix worked?

## A finding is incomplete until it has a receiving owner

S8 should recommend a remediation, accepted-risk, blocked, rejected, routed, or retest path with confidence and assumptions. A finding is useful only when a receiving owner can act on it.

Each finding should name:

- category, technique, tested scope, target version, and affected route;
- evidence reference in the customer-approved records system;
- severity, impact, exploitability, exposure, detectability, and limitation;
- remediation owner and candidate control surface;
- release/backlog impact and stop condition if risk remains active;
- retest method, success criterion, target date, and acceptance owner.

Typical receiving surfaces include Prompt Shields, Azure AI Content Safety, gateway policy, app or prompt design, tool/API permission, data/retrieval boundary, identity/access path, SOC detection/response, evaluation scenario set, lifecycle/catalog state, accepted-risk route, or release/change hold.

## Native scorecard and decision sidecar are different records

The Foundry AI Red Teaming Agent produces the native scorecard for the run. S8 preserves that output unchanged in the customer's approved records system.

If a customer reviews native ASR values against approved thresholds, the kit may write a comparison sidecar that references the native scorecard. The sidecar helps the decision owner. It is not an alternate scorecard and it does not transform Foundry evidence.

PyRIT, manual, or third-party paths should keep the same boundary: preserve the customer-owned run record, then create a separate decision note that maps findings to threshold, severity owner, remediation route, and retest criterion.

## Retest closes a scoped finding, not product safety

Retest should use the same target, category, and success criterion unless the customer records why an alternate method is more reliable. A lower ASR after a change supports only the retested finding, method, target version, and sample. It does not certify the product, approve production, or close unrelated categories.

Retest closure needs owner acceptance, closure evidence reference, remaining-risk note, and reopen trigger. If the target, model, prompt, tool, data source, identity route, gateway route, threshold, or category set changes materially, the customer reopens the applicable package.

## Unsupported target is an honest route

AI Red Teaming Agent is subject to target, region, license, preview, and service-status constraints. If it is unavailable or unsupported, S8 provides no mock substitute. An authorized PyRIT, manual, or third-party path uses the same written scope, safe target, SOC awareness, retained evidence, severity owner, and owned remediation.[^airt][^pyrit]

Unsupported targets should be routed, deferred, rejected, or blocked rather than forced into a prepared demonstration. Production-test requests should be deferred to the customer's legal, SOC, business, risk, and change process.

## Failure modes to prevent

- Running or reviewing without approved rules of engagement.
- Treating a production target request as a workshop exercise.
- Forcing an unsupported target or category into a mock score.
- Reading a small or synthetic sample as a general safety certificate.
- Treating below-threshold ASR as production approval.
- Recording a finding without severity owner, remediation owner, or retest criterion.
- Copying prompts, outputs, scorecards, payloads, or incident details into the wrong system.
- Closing remediation without a retest record and acceptance owner.

[^airt]: Microsoft Learn - [AI Red Teaming Agent](https://learn.microsoft.com/en-us/azure/foundry/concepts/ai-red-teaming-agent).
[^pyrit]: Microsoft - [PyRIT](https://github.com/microsoft/PyRIT).

## Related official references

See the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md) for Prompt Shields, Defender, and ASSERT context that can inform a customer-authorized testing and remediation path.
