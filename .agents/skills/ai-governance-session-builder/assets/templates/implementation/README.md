# Implementation - {{SESSION_TITLE}}

## Session scope

### What we will do

**Objective.** {{CONTROL_OBJECTIVE}}

{{IN_SESSION_CHANGE_AND_RESULT}}

### Why it matters

**Problem.** {{CONTROL_PROBLEM}}

**Solution.** {{CONTROL_SOLUTION}}

### Boundaries

{{CHANGED_SCOPE_AND_AUTHORITY}}

{{MAIN_EXCLUSION_AND_HANDOFF}}

## Architecture

### Architecture at a glance

{{ARCHITECTURE_OVERVIEW}}

{{AUTHORITATIVE_STATE_AND_CONTROL_BOUNDARY}}

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
|---|---|---|---|
| {{ARCHITECTURE_DECISION}} | {{CHOSEN_APPROACH}} | {{BENEFITS}} | {{COSTS_AND_LIMITATIONS}} |

### Architecture guidance

- [{{MICROSOFT_SOURCE_TITLE}}]({{MICROSOFT_SOURCE_URL}}) supports {{SUPPORTED_DESIGN_DECISION}}.

## Before you start

Run either preflight script. Resolve every reported prerequisite or customer decision before making
changes.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/deployment-inputs.json`](artifacts/deployment-inputs.json) | The preflight scripts and approved deployment process |

```powershell
.\scripts\preflight.ps1 -TargetScope "{{TARGET_SCOPE}}"
```

```bash
./scripts/preflight.sh --target-scope "{{TARGET_SCOPE}}"
```

Allow {{DURATION_MINUTES}} minutes for the session.

## Decisions and stop conditions

- Confirm the exact subscription, resource group, or service scope recorded in the deployment inputs,
  and name its owner.
- Stop if {{STOP_CONDITION}}.

## Implement

1. Complete the required values under `artifacts/`.
2. Run either preflight script and inspect the read-only deployment preview when the named platform supports one.
3. Run {{IMPLEMENTATION_COMMAND}} only after the preview shows no unintended change.

## Confirm the result

Inspect {{CHECK_TARGET}}.

Expected result: {{EXPECTED_RESULT}}.

## After implementation

Keep {{RETAINED_CONTROL}} under {{OWNER_ROLE}} ownership because {{OPERATIONAL_PURPOSE}}.

Live Microsoft service state remains authoritative unless {{DESIRED_STATE_OWNER}} intentionally
owns desired state in the repository and reconciles it through {{RECONCILIATION_PROCESS}}.

Restore or removal path: {{RESTORE_PATH}}.
