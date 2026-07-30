# S7 · Foundry Evaluation lab kit

Use this lab to complete one customer-owned evaluation run record for a bounded
Foundry candidate change. This repository keeps only blank templates and safe
field shapes.

## Inputs

- Foundry project endpoint copied from `ai.azure.com` -> project **Overview**.
- Candidate change: model/deployment, agent ID/version, prompt, retrieval,
  tool/API, policy, or release package.
- Dataset or scenario version: Foundry dataset, JSONL/CSV, response/trace IDs,
  or approved manual scenario set.
- Evaluator/rubric selection from Foundry **Build** -> **Evaluations** ->
  **Evaluator catalog**.
- Baseline reference or baseline-missing route.
- Threshold owner and threshold file/version when CI/CD is used.
- Pipeline identity and `AIAgentEvaluation@2` task inputs when automated.
- Azure Load Testing or approved tool configuration when performance is in
  scope.
- Customer records location for run IDs, summaries, and safe links.

## Steps

1. Complete preflight: project, role, candidate, dataset/scenario, evaluator
   support, baseline, threshold owner, runtime prerequisite, and evidence
   handling.
2. In Foundry, open **Build** -> **Evaluations** -> **Datasets** and upload or
   select the versioned source.
3. In **Evaluator catalog**, confirm evaluator names, versions, required fields,
   mappings, and support notes.
4. Create and run the evaluation against the candidate and baseline where
   supported.
5. Record run ID, evaluator/rubric, dataset/scenario version, baseline result,
   candidate result, threshold verdict, and safe result link.
6. If CI/CD is in scope, verify pipeline identity, `AIAgentEvaluation@2` inputs,
   threshold file, failure behavior, artifact storage, and override route.
7. If load/performance is in scope, run Azure Load Testing or approved tool,
   record request mix, concurrency, quota/cost boundary, telemetry correlation,
   and failed thresholds.
8. Select outcome: continue, hold, defer, reject, route, block,
   diagnostic-only, retest, or exception.
9. Record retest trigger and receiving owner.

## Required technical fields

- Foundry project endpoint / project alias
- Candidate change and version
- Run ID / evaluation ID
- Evaluator or rubric name/version
- Dataset or scenario version
- Baseline result and candidate result
- Threshold owner and threshold file/version
- Threshold verdict and failed slices
- CI/CD pipeline identity, task inputs, failure behavior, artifact storage, and
  override owner where used
- Load/performance tool, request mix, concurrency, quota/cost boundary, telemetry
  correlation, and result where used
- Hold/exception state
- Retest trigger and owner

## Files

- `templates/decision-record.template.md`
- `../templates/decision-record.template.md` for the shared short wrapper when
  needed.

## Output

A customer-owned run record that shows what was opened, run, checked, compared,
held, routed, or retested for the exact Foundry candidate. The lab does not
approve production, set thresholds for the customer, export customer data, store
prompts or outputs, or prove runtime control operation.
