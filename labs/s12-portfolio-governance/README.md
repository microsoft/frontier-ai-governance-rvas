# S12 · Portfolio Evidence & Roadmap lab kit

Use this lab to roll up source-system evidence for three candidate workloads and
choose the next technical action for each. Work in the customer's approved
records system; this repository keeps only blank templates and safe field shapes.

## Inputs

- Three candidate workloads, agents, initiatives, or backlog items.
- Safe references from S0 intake, S2 compliance, S5 API/tool admission, S7
  evaluation, S8 findings, S9 inventory/control-plane, S10 operating/cost
  signals, and the customer backlog/change system.
- Named portfolio owner, workload owners, risk/compliance owner, platform owner,
  operating owner, FinOps/capacity owner, backlog/change owner, and evidence
  owner.
- Review period, included/excluded scope, and stop condition for stale source
  systems, missing owner, unsupported service, or unsafe evidence handling.

## Steps

1. Open the S0 intake record for each candidate. Check sponsor, owner, intended
   use, user population, platform path, target event, and acceptance criteria.
2. Open S2 compliance/Purview references. Check compliance state, unsupported
   data-path limits, retention/eDiscovery route, and open gaps.
3. Open S5 API/tool admission references. Check API/tool owner, schema/route,
   gateway state, permission boundary, and unapproved tool gaps.
4. Open S7 evaluation references. Check baseline/candidate result, unsupported
   slices, threshold owner, and retest state.
5. Open S8 findings. Check severity, exploitability or impact, remediation
   owner, exception expiry, retest plan, and open blocker.
6. Open S9 inventory/control-plane references. Check owner, identity, API/tool,
   Foundry, telemetry, lifecycle, duplicate records, and stale state.
7. Open S10 operating/cost references. Check alert/correlation coverage,
   latency/error/capacity/cost signal, incident route, budget/export, and owner.
8. Open the customer backlog/change system. Check current status, dependency,
   target event, funding/capacity assumption, and next accepted action.
9. Rank the three candidates by technical blocker, risk, value, dependency, and
   next action. Do not hide unsupported or stale sources in a score.
10. Classify expected signals: promotable workload, blocked workload,
    unsupported workload, duplicate initiative, missing owner, missing operating
    signal, stale exception, or route-to-owner.

## Required technical fields

- Portfolio slice and three candidate workload references
- Source-system references from S0, S2, S5, S7, S8, S9, S10, and backlog/change
- Technical blocker, risk, value, dependency, next action, and confidence for
  each candidate
- Promotable/blocked/unsupported/duplicate/missing-owner/missing-signal/stale
  exception classification
- Owner, acceptance check, target event, and recheck condition for each next
  action
- Support limit or source coverage limit for every unusable signal

## Files

- `templates/decision-record.template.md`
- `../templates/decision-record.template.md` for the shared short decision wrapper when needed.

## Output

A customer-owned rollup that ranks three candidate workloads, names the next
technical action for each, and preserves source freshness, exclusions, owners,
and support limits. The lab does not query live systems, approve funding, change
policy, certify compliance, approve production, or change a baseline.
