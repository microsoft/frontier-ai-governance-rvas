---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Session 11</p>

# Foundry evaluations and release quality gates

240 minutes · Compare fixed versions, then prove the gate can pass and block

<!-- Notes: The gate decides release eligibility. It never promotes the agent. -->

---

## Why it matters

> Create and run `release-gate.py` for fixed agent versions with repeatable evaluation results.

By the end of the session:

- The approved and candidate versions have used the same synthetic golden set.
- Active thresholds fit the approved owner floors and baseline.
- Foundry holds row detail; the release platform holds payload-free aggregates.
- The approved aggregate returns `PASS`.
- The tool-process regression returns `BLOCK`.

<!-- Notes: Session 14 later runs the same command before promotion. -->

---

<!-- _class: two-column -->

## Architecture and control boundary

<div class="columns">
<div>

The repository owns the data, evaluation definition, thresholds, policy, and scripts.

Foundry stores queries, responses, tool calls, evaluator reasons, and row results.

The approved release platform stores aggregates, gate state, and promotion decisions.

The stable endpoint stays pinned to the approved version.

</div>
<div>

![Approved and candidate versions use the same data and evaluators before release thresholds return PASS or BLOCK.](assets/diagrams/evaluation-release-gate-flow.svg)

</div>
</div>

<!-- Notes: Point out the promotion boundary after PASS or BLOCK. -->

---

<!-- _class: decision -->

## Decisions that can stop the run

| Decision | Continue when |
|---|---|
| Versions and scope | Two immutable versions in the approved nonproduction project; stable endpoint on approved |
| Identity | Operator and project managed identity have Foundry User on the exact project |
| Region | The same-day support check allows the complete blocking set in East US 2 |
| Tool path | The tool owner approves the Function Tool path |
| Cost | The cost owner approves judge-model and evaluation consumption |

Keep the gate disabled if the path adds Azure AI Search, Bing Grounding, Bing Custom Search,
SharePoint Grounding, Code Interpreter, Fabric Data Agent, or Web Search.

<!-- Notes: A mutable target or unsupported evaluator set makes the result unusable. -->

---

<!-- _class: decision -->

## Implementation tradeoffs

- Quality and tool thresholds cannot fall below owner-approved floors.
- They cannot exceed the approved baseline result.
- Safety thresholds stay at `1.00`.
- Every blocking metric allows `0` evaluator errors.
- Task adherence, prohibited actions, and sensitive data leakage stay advisory.

An exception can cover an eligible final-answer quality failure. It needs a named metric, reason,
compensating control, owner, authority, and expiry. It cannot override safety or tool-process
failures or enable automatic promotion.

<!-- Notes: Fix a weak approved version. Do not tune the floor down to fit it. -->

---

<!-- _class: implementation -->

## Implementation path

**Total session: 240 minutes. Guided implementation: about 180 minutes.**

1. Confirm fixed versions, exact scope, regional support, tool compatibility, and budget.
2. Run baseline preflight and evaluate the approved version.
3. Set active thresholds within the approved bounds.
4. Run candidate preflight and evaluation.
5. Apply `release-gate.py`.
6. Run the approved-path and blocked tool-process checks.

The remaining time covers the briefing, customer decisions, and operating handoff.

<!-- Notes: The guide contains paired PowerShell and Bash commands. The Evals API has no dry run. -->

---

## Safety gates

Stop when:

- a version is implicit, mutable, or outside the approved project;
- protected-material evaluation cannot run on the approved East US 2 path;
- a limited-support tool enters the evaluated path;
- a preview evaluator becomes blocking;
- any blocking metric is missing or has an evaluator error;
- a safety or tool-process failure is treated as overridable; or
- detailed interaction data would be written to the repository.

<!-- Notes: Separate final-answer, tool-process, and safety layers. Never blend them into one score. -->

---

<!-- _class: two-column -->

## Confirm both paths

<div class="columns">
<div>

### Intended path

Run the approved aggregate as both gate inputs.

Expected:

- `PASS`
- all blocking metrics present
- zero evaluator errors
- separate layer summaries

</div>
<div>

### Blocked path

Run:

`test_release_gate.py --mode blocked-tool-process`

Expected:

- tool-call accuracy: blocked
- tool-call success: blocked
- answer quality and safety: passing
- candidate remains unpinned

</div>
</div>

<!-- Notes: The blocked test creates aggregate data in memory and retains no case file. -->

---

## Operate, disable, and hand off

| Owner | Keeps in operation |
|---|---|
| Quality owner | Golden set, evaluator selection, threshold history |
| Safety owner | Safety coverage, East US 2 protected-material boundary |
| Tool owner | Function Tool compatibility and remediation |
| Cost owner | Evaluation consumption |
| Release owner | Gate state, release records, and stable selector |

To disable, mark the gate disabled and keep or restore the approved version at 100%. Remove delivery
integration only after dependency review. Cancel unnecessary evaluations, but keep the production
artifacts and current records. Session 14 consumes `PASS` or `BLOCK`; it does not change metric
meaning.

<!-- Notes: Do not delete the project, agent, model, tool path, logs, or customer data as a shortcut. -->

---

<!-- _class: closing -->

# Thank you!
