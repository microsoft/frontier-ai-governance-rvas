# S8 · Authorized Red Teaming & Retest

**Facilitator deck**

Microsoft default: **AI Red Teaming Agent where supported; PyRIT or manual approved alternate; Azure AI Content Safety, Prompt Shields, Defender, Sentinel, and SOC remediation routes**.

Concrete decision: **Approve, defer, reject, route, block, remediate, retest, or accept risk for one authorized non-production target and category.**

---

## Authorized adversarial testing, not "run attacks"

- S8 is a defensive, customer-authorized, non-production remediation workshop.
- The unit of work is one target, one version, one category set, and one evidence boundary.
- The output is a remediation and retest package, not offensive capability or production approval.

Note:
Open by taking the heat out of "red team." This is controlled safety evidence with a receiving owner.

---

## Target card

- Target: agent, app, endpoint, workflow, or model route.
- Version: prompt/model/tool/data/policy/build version in scope.
- Environment: non-production only.
- Owners: target, evidence, severity, remediation, retest.
- Safety: reset/rollback path, monitoring window, production-impact exclusion.

Note:
If the customer cannot name the target version and reset path, the workshop should create a blocker instead of pretending the test is scoped.

---

## Rules of engagement are the first control

- Authorization reference and approved time window.
- Operators, methods/tools, permitted categories, excluded categories.
- Data limits, prohibited activity, cost/rate limits.
- Stop conditions and escalation route.
- SOC contact and legal/risk contact where required.
- Evidence handling, retention owner, visibility limits.

Note:
ROE is not paperwork. It is the control that makes adversarial activity bounded and defensible.

---

## Category taxonomy

- Direct prompt injection.
- Indirect prompt injection.
- Sensitive-data disclosure.
- Tool abuse or unsafe action.
- Hallucination or grounding failure.
- Harmful or policy-violating content.
- Protected-material concern.
- Cost or availability abuse.
- Unauthorized access.

Note:
Ask "which category are we testing and what counts as success?" before anyone looks at scores.

---

## Method route

| Route | Use when |
|---|---|
| AI Red Teaming Agent | Target and category are supported and customer can operate the native path. |
| PyRIT | Approved custom repeatable testing is needed. |
| Manual expert | Human/domain judgment is required. |
| Third-party | Customer requires an independent or specialist engagement. |
| Unsupported route | No approved method safely covers the target/category. |
| Production request | Defer to customer legal, SOC, business, risk, and change process. |

Note:
Unsupported is an honest route. Never force a mock test to fill a governance cell.

---

## ASR, threshold, and sample limits

- ASR = attempts that meet the agreed success condition.
- ASR only makes sense with category, sample size, target version, method, and threshold.
- Below threshold supports the tested scope only.
- Above threshold creates remediation or risk decision work.
- Not-comparable results stay diagnostic until the customer accepts interpretation rules.

Note:
Make threshold ownership explicit. A tool score does not accept risk.

---

## Severity interpretation

Severity is not just ASR. Combine:

- impact;
- exploitability;
- exposure;
- detectability;
- response burden;
- release or backlog impact.

Note:
Severity should tell the receiving owner what they must do next, not just how bad the score looks.

---

## Native scorecard vs decision sidecar

- Native scorecards and run records stay unchanged in the customer records system.
- Prompts, outputs, payloads, datasets, endpoint details, and incident payloads stay out of this repository.
- A threshold-comparison sidecar can reference native evidence.
- The sidecar is a decision aid, not a replacement scorecard.

Note:
This slide protects the repository boundary and keeps evidence provenance clean.

---

## Finding record

Each finding needs:

- category and technique;
- affected route and target version;
- evidence reference;
- impact, exploitability, exposure, detectability;
- severity and limitation;
- owner and remediation route;
- stop condition if risk remains active;
- retest criterion and target date.

Note:
If it has no owner or retest criterion, it is an observation, not a governed finding.

---

## Finding-to-control remediation map

| Finding type | Likely receiving owner |
|---|---|
| Prompt injection | Prompt/design, runtime-control, in-process policy |
| Indirect injection | Data/retrieval, tool-response, runtime-control |
| Sensitive data | Data/privacy, output safety, investigation |
| Unsafe tool action | Tool/API, identity, approval gate, catalog |
| Unsafe content | Content Safety, Prompt Shields, safety owner |
| Unauthorized access | Identity, platform, data, SOC |
| Cost abuse | Gateway, platform, FinOps, operations |

Note:
Keep the discussion practical: who changes something, what evidence closes it, and when it gets retested.

---

## Stop conditions and release impact

- Stop if authorization scope is exceeded.
- Stop if production impact appears possible.
- Stop if SOC/legal/operational escalation triggers.
- Hold or block release/change activity when severity exceeds tolerance.
- Accepted risk needs authority, expiry, compensating action, and review trigger.

Note:
The stop condition is part of the package, not an emergency afterthought.

---

## Retest and closure

- Retest same category and success condition unless an alternate is justified.
- Record changed target version and comparison rule.
- Preserve retest evidence in customer systems.
- Closure requires severity/remediation owner acceptance.
- Reopen on material target, method, category, threshold, route, or control change.

Note:
A lower ASR closes only the scoped finding. It does not certify product safety.

---

## Failure modes and hard stops

- No written authorization or ROE.
- Production target requested.
- Missing SOC/legal contact where required.
- Unsupported target forced into mock coverage.
- Raw prompts, outputs, scorecards, or payloads copied into the wrong place.
- Finding has no remediation owner.
- Remediation has no retest criterion.
- Below-threshold ASR generalized beyond tested scope.

Note:
These are not facilitation preferences; they are blockers or route decisions.

---

## Workshop artifact and handoff

- Artifact: authorized red-team remediation package.
- Decision: approve, defer, reject, route, block, remediate, retest, or accept risk.
- Handoff: target owner, red-team lead, SOC, legal/risk, remediation owner, retest owner, release/lifecycle owner.
- Boundary: safe references only; no production testing; no tenant change; no production-approval claim.

Note:
End with the package, owner, target date, and retest closure path.
