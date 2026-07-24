# S8 · Adversarial Testing & Remediation: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · AI Red Teaming Agent, PyRIT, Azure AI Content Safety, Prompt Shields, Defender, and related governance features vary by target, region, license, and service status. Verify official docs, authorization, and customer rules of engagement before any run.

## Microsoft default

Default to an authorized, customer-operated non-production Microsoft AI Red Teaming Agent path where supported, with PyRIT or manual expert testing for unsupported targets. Route findings to Azure AI Content Safety/Prompt Shields, gateway, in-process, permissions, or lifecycle backlog as appropriate.

## Decision tree

1. **If the target fits the Microsoft AI Red Teaming Agent support matrix**, use it for repeatable category coverage in authorized non-production scope.
2. **If the target or category is unsupported**, use PyRIT or manual expert testing with the same authorization record.
3. **If production testing is requested**, defer to the customer's legal, SOC, business, and change process.
4. **If rules of engagement, stop conditions, evidence handling, or SOC contact are missing**, block testing.
5. **If findings map to controls**, route to Prompt Shields/Content Safety, gateway, prompt, tool-permission, or lifecycle owner and require retest criteria.

| Decision | Microsoft default | Exception criteria |
|---|---|---|
| Test method | AI Red Teaming Agent where supported; PyRIT for repeatable custom testing | manual/third-party expertise is required |
| Scope | authorized non-production target with monitoring and reset path | production-like or production exception is formally approved by customer process |
| Remediation | Azure AI Content Safety/Prompt Shields, gateway controls, Defender/SOC route, lifecycle block | prompt/tool/code fix is the actual owner boundary |

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Tooling fit | AI Red Teaming Agent target support, PyRIT test plan, Foundry project/target reference |
| Authorization | rules of engagement, SOC notification, legal/change approval, stop conditions |
| Safety controls | Azure AI Content Safety, Prompt Shields, APIM/gateway policy, S10 in-process policy if applicable |
| Detection/response | Defender for Cloud, Defender XDR, Sentinel, SOC ticket/playbook |
| Remediation lifecycle | S9 catalog state, S4 material-change trigger, S7 retest/evaluation reference |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Test approach | method, operator, target, categories, support-status caveat, and cost/coverage limits are recorded | Red-team owner |
| Rules of engagement | target, timing, operators, data limits, stop conditions, SOC/legal contacts, and evidence handling are approved | Customer security/legal |
| Findings route | each finding has severity, control owner, remediation path, release impact, and retest criterion | Remediation owner |
| Portfolio impact | unresolved blockers and accepted risks are visible to S13 with owner and review date | Portfolio owner |

## Boundary note

S8 defines and records authorized testing and remediation; workshop activity never attacks production systems.

## Related references

- [S8 Concepts](concepts.md): authorization, Attack Success Rate, native scorecard boundaries, and remediation backlog.
- [S6 technical decisions](../s6-security-runtime/technical.md): runtime control placement.
- [S7 technical decisions](../s7-evaluation/technical.md): retest and release assurance.
- [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
