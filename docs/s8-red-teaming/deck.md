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
- Raw prompts, outputs, run records, or payloads copied into the wrong place.
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
End with the package, owner, target event, and retest closure path.
