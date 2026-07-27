# S8 · Adversarial Testing & Remediation: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-27 · AI Red Teaming Agent, PyRIT, Azure AI Content Safety, Prompt Shields, Defender, and related governance features vary by target, region, license, and service status. Verify official docs, authorization, and customer rules of engagement before any run.

## Microsoft default

Default to an authorized, customer-operated non-production Microsoft AI Red Teaming Agent path where the target is supported, with PyRIT or manual expert testing for unsupported targets or categories. Route findings to Azure AI Content Safety/Prompt Shields, gateway, in-process, permissions, data, evaluation, lifecycle, or SOC backlog as appropriate.

## Decision tree

1. **If authorization and rules of engagement are incomplete**, block testing. Required fields include target, environment, categories, timing, operators, data limits, stop conditions, SOC contact, legal/risk contact where required, evidence handling, severity owner, and retest criterion.
2. **If the target fits the Microsoft AI Red Teaming Agent support matrix**, use it for repeatable category coverage in authorized non-production scope and preserve the native scorecard in the customer-approved records system.
3. **If the target or category is unsupported**, use PyRIT or manual expert testing only when the same authorization, evidence-handling, SOC, severity, and retest records are complete.
4. **If production testing is requested**, defer to the customer's legal, SOC, business, risk, and change process. Do not run or imply production approval from S8.
5. **If a result exceeds threshold or severity tolerance**, route to remediation owner with target date, release impact, stop condition if needed, and retest criterion.
6. **If a result is below threshold**, record tested scope, limitations, owner acceptance, and next review trigger. Do not generalize beyond the authorized target version and categories.
7. **If findings map to controls**, route to Prompt Shields/Content Safety, gateway, prompt/design, tool-permission, data, SOC, or lifecycle owner and require retest criteria.

| Decision | Microsoft default | Exception criteria |
|---|---|---|
| Test method | AI Red Teaming Agent where supported; PyRIT for repeatable custom testing | Manual or third-party expertise is required, or supported Microsoft path cannot cover the target/category |
| Scope | Authorized non-production target with monitoring, reset path, SOC/legal contact, and stop condition | Production-like or production exception is formally handled by customer process |
| Threshold | Customer-approved ASR/category threshold or qualitative tolerance | Threshold absent, disputed, category-specific, or requires legal/risk decision |
| Finding severity | Severity owner maps category, impact, exploitability, exposure, and release impact | Severity model missing, owner absent, or finding spans multiple owners |
| Remediation | Azure AI Content Safety/Prompt Shields, gateway controls, Defender/SOC route, prompt/tool/code fix, lifecycle block | Actual owner boundary sits in app design, tool permission, data path, model choice, or accepted-risk route |
| Retest | Same method or approved alternate verifies the fix against the agreed criterion | Fix cannot be safely retested, target changed, or evidence cannot be retained |

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Tooling fit | AI Red Teaming Agent target support, PyRIT test plan, manual-test approval, Foundry project/target reference |
| Authorization | rules of engagement, SOC notification, legal/risk contact, permitted operators, stop conditions, evidence handling |
| Target safety | non-production target, owner, version, reset/rollback path, dependencies, monitoring window, no production-user impact |
| Category threshold | customer-approved ASR/category threshold, qualitative tolerance, sample-size note, threshold owner |
| Safety controls | Azure AI Content Safety, Prompt Shields, APIM/gateway policy, S10 in-process policy, tool-permission boundary if applicable |
| Detection/response | Defender for Cloud, Defender XDR, Sentinel, SOC ticket/playbook, severity owner, escalation contact |
| Remediation lifecycle | S9 catalog state, S4 material-change trigger, S7 retest/evaluation reference, S13 portfolio blocker |
| Evidence handling | native scorecard or run record retained by customer; sidecar references only; retention/export/deletion owner named |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Rules of engagement | target, timing, operators, categories, data limits, stop conditions, SOC/legal contacts, evidence handling, and prohibited activity are approved | Customer security/legal |
| Test approach | method, operator, target, categories, support-status caveat, cost/coverage limits, and safe evidence location are recorded | Red-team owner |
| Unsupported target route | unsupported target/category, reason, alternate method, exception owner, approval path, and retest plan are recorded | Security / risk owner |
| Production-test request | request is deferred or routed to customer legal, SOC, business, risk, and change process without S8 testing or approval claims | Customer change owner |
| Threshold interpretation | category threshold, sample size, ASR or qualitative result, limitation, decision owner, and accepted-risk authority are recorded | Threshold owner |
| Findings route | each finding has severity, control owner, remediation path, release impact, stop condition if needed, and retest criterion | Remediation owner |
| Retest closure | fix evidence and retest result are retained in customer systems and accepted by severity/remediation owner | Evaluation / release owner |
| Portfolio impact | unresolved blockers and accepted risks are visible to S13 with owner and review date | Portfolio owner |

## Boundary note

S8 defines and records authorized testing and remediation. Workshop activity never attacks production systems, changes tenant policy, ships attack datasets, stores customer prompts/outputs in this repository, or claims production control operation from synthetic/prepared tests.

## Related references

- [S8 Concepts](concepts.md): authorization, Attack Success Rate, native scorecard boundaries, and remediation backlog.
- [S8 Practical workshop](practical.md): scenario-driven authorization, finding, remediation, and retest flow.
- [S6 technical decisions](../s6-security-runtime/technical.md): runtime control placement.
- [S7 technical decisions](../s7-evaluation/technical.md): retest and release assurance.
- [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
