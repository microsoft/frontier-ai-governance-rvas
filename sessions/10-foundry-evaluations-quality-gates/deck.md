---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![Program logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation - Session 10</p>

# Foundry evaluations and release quality gates

**270 minutes - Compare two versions with one data set and separate gate layers**

<!-- Notes: Sessions 05 and 08 created the governed agent and tool boundary. Today release eligibility becomes measurable. -->

---

## Control objective

> Create and run `release-gate.py` for fixed agent versions using repeatable evaluation results.

### Result check

- Run the same golden set against the approved and candidate versions.
- Base thresholds on the approved baseline.
- Keep final-answer, tool-process, and safety failures separate.
- Confirm that the approved record passes and the blocking regression record blocks.
- The release owner enables the gate in the approved release platform and hands the command to Session 13.

<!-- Notes: The gate decides eligibility. It never changes the live version selector. -->

---

## Why it matters

Release owners need a clear answer: can this fixed agent version move forward?

Separate final-answer, tool-process, and safety checks stop a strong average from hiding a failed tool path or safety issue.

Session 10 makes that decision executable. Session 13 runs the command in the promotion path.

<!-- Notes: Eligibility is this session's owned result. Promotion enforcement comes later. -->

---

## Implementation outcomes

1. Keep the versioned golden set and evaluation definition for approved and candidate agent versions.
2. Set release thresholds from the approved baseline.
3. Keep detailed results in Foundry and payload-free aggregates in the approved release store.
4. Enable the release gate in the approved release platform.
5. Confirm that the approved record passes and the generated tool-process regression blocks.

<!-- Notes: Extended mode is required because release protection depends on both behaviors. -->

---

<!-- _class: section-divider -->

# Evaluate the answer, tool process, and safety

A fluent answer can still use the wrong tool, wrong input, or unsafe path.

<!-- Notes: Do not average away process failures. -->

---

## Control boundaries

| Layer | Question | Blocking metrics |
|---|---|---|
| Final-answer quality | Did the response address the request? | Relevance |
| Tool process | Did the agent select, call, and complete the right tool behavior? | Tool call accuracy, tool call success |
| Safety | Did every row avoid the selected risks? | Violence, hate/unfairness, protected material |

Preview task-adherence, prohibited-action, and sensitive-data-leakage evaluators remain
**advisory**. The last two stay in the safety layer.

<!-- Notes: Session 08 remains the hard authorization boundary for blocked writes. -->

---

## Architecture overview

<!-- _class: diagram -->

![A versioned golden data set evaluates approved and candidate fixed agent versions; separate final-answer, tool-process, and safety evaluator layers produce aggregate records, then baseline thresholds and release policy return PASS for Session 13 or BLOCK with the candidate unpinned](assets/diagrams/evaluation-release-gate-flow.svg)

<!-- Notes: Follow data left to right, then point out the promotion boundary after the gate result. -->

---

## What this means

Run the same fixed test cases against the approved version and the candidate. Foundry evaluates
answer quality, tool process, and safety separately.

Foundry stores row detail. The approved release platform stores payload-free aggregates and records
gate state and promotions. The repository stores the version-controlled threshold and policy
definitions.

The gate returns `PASS` or `BLOCK`. It cannot promote. Session 13 controls the stable selector.

---

## Current Foundry evaluation path

![Microsoft Foundry](assets/icons/microsoft/azure-ai-foundry.svg)

```text
versioned JSONL dataset
        ↓
azure_ai_target_completions
        ↓
approved azure_ai_agent name + version
        ↓
built-in evaluators
        ↓
run + output items in Foundry
```

---

<!-- _class: decision -->

## Implementation tradeoffs

Save the owner-approved metric floors in `thresholds.yaml` before the baseline run. After the run,
set quality and tool thresholds no higher than the baseline and no lower than those floors.
Conflicting bounds stop the gate.

| Choice | Benefit | Cost or limit |
|---|---|---|
| Baseline-derived thresholds | Ties the gate to observed approved behavior | A weak baseline must be fixed, not fitted |
| Separate metric floors | Stops averages from hiding a failed layer | Owners maintain several explicit decisions |

Record approval, baseline run IDs, and gate state in the approved release platform. Safety stays at
`1.00`, every maximum error count stays at `0`, and preview evaluators stay nonblocking.

<!-- Notes: If the approved version is poor, remediate it. Do not lower the gate to fit. -->

---

<!-- _class: decision -->

## Decision gate 1 - Are both agent versions fixed?

Required:

- one policy-assistant agent listed in the evaluation spec;
- approved version;
- different candidate version;
- stable endpoint pinned to the approved version; and
- the approved nonproduction Foundry project.

Stop for `latest`, an edited version, a changed endpoint selector, or a project outside scope.

<!-- Notes: A result without the version cannot govern promotion. -->

---

## Keep the golden data set with the release gate

The approved set covers:

1. normal behavior
2. edge behavior
3. refusal
4. multilingual output
5. sensitive-data minimization
6. tool-input boundaries
7. indirect instruction
8. tool failure

Every row uses synthetic content and remains versioned for reuse.

<!-- Notes: The golden set stays with the control as an operating asset. -->

---

## Evaluation row format

```json
{
  "case_id": "tool-input-boundary",
  "category": "tool-use",
  "query": "...",
  "expected_behavior": "...",
  "tool_definitions": [
    {
      "type": "function",
      "function": {
        "name": "get_policy",
        "parameters": {"type": "object", "properties": {"policyId": {"type": "string"}}}
      }
    }
  ]
}
```

- One JSON object per line
- Stable case IDs
- Maximum 2 MB per row
- Maximum 100,000 rows per batch
- SHA-256-derived Foundry dataset version

<!-- Notes: Detailed generated responses remain in Foundry, not source control. -->

---

<!-- _class: decision -->

## Decision gate 2 - Does the region support the set today?

Before each run, the quality owner checks the selected region against the current Microsoft support matrix for:

- batch evaluation;
- required risk and safety evaluation; and
- protected-material evaluation.

Protected material is currently available only in **East US 2**. Keep that blocking metric and run
the complete gate there, or stop and revise the policy with the safety and release owners. Never
drop it during a run.

Record the same-day manual support gate in the approved release platform.

For isolated projects:

- evaluation subnet delegation is confirmed; and
- the project managed identity has **Foundry User** on the approved Foundry project.

<!-- Notes: Evaluation region support is narrower than general model deployment support. -->

---

<!-- _class: decision -->

## Decision gate 3 - Are tool evaluators compatible?

The tool owner approves blocking `tool_call_accuracy` and `tool_call_success` only for supported
tool types.

This kit uses one user-defined **Function Tool**. Keep the gate disabled if the trace adds Azure AI
Search, Bing Grounding, Bing Custom Search, SharePoint Grounding, Code Interpreter, Fabric Data
Agent, or Web Search.

<!-- Notes: Limited tool support can make a blocking process metric misleading. -->

---

## Identity and cost boundary

![Microsoft Entra ID](assets/icons/microsoft/microsoft-entra-id.svg)

The operator supplies through the shell:

```text
FOUNDRY_RESOURCE_ID
FOUNDRY_PROJECT_ENDPOINT
FOUNDRY_MODEL_NAME
```

No key, token, endpoint, tenant ID, or subscription ID is committed.

The evaluation operator has **Foundry User** on the approved Foundry project. The cost owner
approves judge-model and evaluation consumption before the run.

<!-- Notes: DefaultAzureCredential uses the customer's approved secretless path. -->

---

## Files kept in source control

### Keep

- versioned synthetic data
- evaluation definition
- threshold policy
- release policy

### Keep in Foundry and the release platform

- queries and responses
- tool arguments and results
- evaluator reasons
- row-level details
- run aggregates, the gate's enabled state, and promotion decisions

<!-- Notes: Aggregate records support release automation without copying customer interaction data. -->

---

<!-- _class: section-divider -->

# Set thresholds from the approved version

Run the approved version before you set quality and tool thresholds.

<!-- Notes: Safety remains zero-tolerance for this supplied set. -->

---

<!-- _class: implementation -->

## Run the approved-version evaluation

**Timebox: 65 minutes**

1. Resolve the Foundry project, agent, owner, evaluator, region, and fixed-version decisions.
2. Run baseline preflight with the approved runtime inputs.
3. Execute the approved-version evaluation.

The stable endpoint does not move.

<!-- Notes: Stop before a billable run if the printed subscription ID, Foundry project resource ID, or fixed agent version differs from the approved scope record. -->

---

## Preflight boundary

Preflight stops the run unless the approved scope, identities, evaluation row format, tool
compatibility, regional support, and budget checks pass.

The Evals API has no dry run. Before billing starts, preflight prints the project alias, region,
approved agent version, dataset SHA-256, case count, evaluator names, and the aggregate-only output
rule. The runner targets that version without calling the stable selector. The approved endpoint does not
change.

<!-- Notes: The release owner checks every printed value before authorizing consumption. -->

---

## Baseline run

```powershell
python .\scripts\run-evaluation.py `
  --spec .\artifacts\eval\evaluation-spec.json `
  --target approved `
  --output $env:APPROVED_RELEASE_STORE\approved-baseline.json
```

The hash-derived dataset version makes unchanged input reusable and changed input explicit.

Stop on a failed run, missing evaluator, errored row, unexpected tool, or unsafe behavior.

<!-- Notes: Inspect row-level detail in Foundry; do not export it to the repository. -->

---

## Candidate run

```powershell
python .\scripts\run-evaluation.py `
  --spec .\artifacts\eval\evaluation-spec.json `
  --target candidate `
  --output $env:APPROVED_RELEASE_STORE\candidate.json
```

Then apply the active policy:

```text
same data hash + candidate version
          ↓
independent metric rules
          ↓
PASS or BLOCK
```

Send final-answer failures to the quality owner. Send tool-selection or execution failures to the
tool owner. Send safety failures to the safety owner.

The release owner keeps the approved version live.

<!-- Notes: A blocked candidate stays unpinned and is replaced by a new fixed version after remediation. -->

---

## Exception boundary

An exception:

- applies only to an eligible non-safety quality condition;
- names the failed metric and business reason;
- defines a compensating control;
- has an owner, authority, and expiry; and
- never enables automatic promotion.

It cannot override a safety failure or a tool-process failure.

<!-- Notes: The consolidated release policy records this boundary; there is no unused exception template. -->

---

<!-- _class: section-divider -->

# Confirm the gate can pass and block

A pass, a block, and a release-owner decision.

<!-- Notes: These checks validate the control, not production readiness. -->

---

## Intended path - approved version

Apply the active policy to the approved baseline record.

Expected:

- `PASS`
- baseline run ID
- current data hash
- all blocking metrics present
- zero evaluator errors
- separate layer summaries
- no payloads in the decision record

Stop if the gate reduces the result to one blended score.

<!-- Notes: The approved path proves a known-good record can traverse the gate. -->

---

## Blocked path - tool-process regression

Run `test_release_gate.py --mode blocked-tool-process`.

Expected:

- final-answer relevance: **passing**
- tool-call accuracy: **blocked**
- tool-call success: **blocked**
- selected safety metrics: **passing**
- advisory prohibited-action and sensitive-data-leakage signals: **nonblocking**
- candidate: **still unpinned**

The answer cannot hide the failed tool path.

<!-- Notes: The command generates payload-free aggregate test data in memory. No case file is retained. -->

---

## Delivery-owner checkpoint

| Decision | Required action |
|---|---|
| Enable gate | Confirm every blocking candidate metric is complete, target IDs match the approved specification and release policy, and each failure has its quality, tool, or safety owner; then hand the `release-gate.py` command to [Session 13](../13-cicd-promotion-controls/) |
| Disable gate | Keep stable endpoint on the approved version and route gate defects to the quality owner |

Session 10 produces the gate command and policy files. Session 13 runs the command before
promotion. The gate never promotes by itself.

---

## Immediate disable and restore

1. Keep or restore the approved [Session 05](../05-governed-agent-baseline/) version at 100%.
2. Mark the gate disabled.
3. Remove delivery integration only after dependency review.
4. Cancel unnecessary running evaluations.
5. Keep the golden data set, thresholds, release policy, and blocked self-test command in operation.
   Foundry and the release platform retain current results and decisions.

Do not delete the project, agent, model, tool path, logs, or customer data as a shortcut.

<!-- Notes: Version selection is the immediate safety switch. -->

---

## Live state and ownership

| Owner | Operational responsibility |
|---|---|
| Quality owner | Golden set, evaluator selection, threshold history |
| Safety owner | Safety coverage, protected-material region, and preview boundary |
| Tool owner | Tool-process compatibility and remediation |
| Cost owner | Evaluation consumption |
| Release owner | Gate state and stable version selector |

[Session 13](../13-cicd-promotion-controls/) calls this gate with the approved evaluation specification, threshold policy, and release records. It consumes `PASS` or `BLOCK` without changing metric meanings.

<!-- Notes: Keep the ownership model small and operational. -->

---

## Recap

- Fixed versions tie results to the right release.
- The data hash makes runs comparable.
- Baseline-derived thresholds make the gate explainable.
- Separate layers prevent quality averages from masking unsafe process.
- Protected material stays blocking only on its supported East US 2 path.
- Preview prohibited-action and sensitive-data-leakage signals stay advisory.
- Aggregate records support delivery without copying interaction data.
- The release owner, not the script, changes promotion state.

<!-- Notes: Ask the team to state the disable switch before closing. -->

---

<!-- _class: closing -->

# Thank you!

<!-- Notes: Session 11 attacks the implementation; Session 13 later integrates this gate into delivery. -->
