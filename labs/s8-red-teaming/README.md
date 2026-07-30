# S8 · Authorized Red Teaming lab kit

Use this lab to complete one customer-owned authorized test/run record for a
bounded non-production target. This repository keeps only blank templates and
safe field shapes.

## Inputs

- Written authorization and rules of engagement.
- Customer-owned non-production target alias, version, owner, reset/rollback
  path, monitoring window, and production-impact exclusion.
- Foundry project endpoint and operator role when using AI Red Teaming Agent.
- Target support status: Foundry deployment, connected Azure OpenAI/Foundry
  Tools deployment, Foundry Agent, approved PyRIT adapter, manual, third-party,
  unsupported, or production-test deferred.
- Approved categories and excluded categories.
- ASR threshold or qualitative tolerance, threshold owner, severity model, and
  accepted-risk authority.
- Customer evidence location for scorecards, prompts, outputs, run records, and
  findings.
- Remediation owner, finding route, retest method, comparison rule, and reopen
  trigger.

## Steps

1. Complete the hard gate: authorization, ROE, non-production target, support
   status, evidence handling, rate/cost boundary, and retest route.
2. If the target or category is unsupported, stop and route before any test.
3. If production testing is requested, defer to customer legal, SOC, business,
   risk, and change process. S8 does not approve or run it.
4. For AI Red Teaming Agent, configure project endpoint, target, category list,
   sample/objective count, strategy scope, taxonomy/source, monitoring, and stop
   conditions; run through Foundry SDK or approved automation.
5. For PyRIT, use the approved notebook or customer wrapper, target adapter,
   dataset/source reference, and customer output location.
6. For manual/third-party route, capture minimum handoff fields before work
   starts.
7. Review run status, ASR/qualitative result, category breakdown, support status,
   threshold verdict, and not-comparable conditions.
8. Route each finding to owner, severity, remediation path, release/lifecycle
   impact, stop condition, and retest trigger.
9. Retest after fix and record changed target version, retest run ID/result,
   comparison rule, remaining risk, and closure owner.

## Required technical fields

- Target alias/version and run ID
- Method: AI Red Teaming Agent / PyRIT / manual / third-party / unsupported /
  production-test deferred
- Categories and excluded categories
- Threshold or qualitative tolerance
- Support status
- ASR or qualitative result
- Finding route and remediation owner
- Retest result and comparison rule
- Remaining risk and accepted-risk owner, if any
- Evidence location and safe result reference

## Files

- `templates/decision-record.template.md`
- `../templates/decision-record.template.md` for the shared short wrapper when
  needed.

## Output

A customer-owned run record that shows what was authorized, supported, run,
blocked, routed, fixed, or retested. The lab does not test production, approve
production, grant access, export customer data, store prompts/outputs/payloads,
or ship red-team tooling.
