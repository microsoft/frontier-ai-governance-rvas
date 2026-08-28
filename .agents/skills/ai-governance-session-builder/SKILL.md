---
name: ai-governance-session-builder
description: >
  Create, update, and audit guided AI governance co-implementation session kits in this
  repository. Use for a session, implementation module, implementation runbook, delivery-lead
  content, or Marp briefing. It keeps schema-version 2 manifests, implementation artifacts,
  safety checks, sources, and decks aligned.
compatibility: Python 3 is required for scaffolding and validation; Node.js/npm is required only for Marp rendering.
---

# AI Governance Session Builder

Build one coherent implementation kit. `session.yaml` is the source of truth for numbered sessions;
`module.yaml` is the source of truth for optional modules. The implementation document, implementation
artifacts, scripts, and deck must agree with the applicable manifest.

## Read first

1. Read `PRODUCT.md` for the program model and constraints.
2. Read the target and adjacent `session.yaml` files for sequence, scope, dependencies, customer
   work, cautions, and dated sources.
3. Read `references/session-contract.md`.
   For an optional module, also read `references/module-contract.md`.
4. Read `references/brand-system.md` before changing a deck.
5. Inspect adjacent sessions for useful patterns, then verify time-sensitive product facts.

## Operating modes

- **Create:** Scaffold a complete kit and replace every scaffold placeholder.
- **Update:** Change the manifest first, then reconcile every surface.
- **Audit:** Run the validator, inspect sourcing and implementation safety, repair requested
  problems, and rerun validation. Do not edit when the request is review-only.

Do not renumber sessions. Keep the existing ID, slug, title, duration, and control scope unless
the request explicitly changes one of them.

Optional modules live under `modules/`, have no numeric ID or program phase, and never alter the
15-session count. Follow `references/module-contract.md` and validate them with the same validator.

## Implementation modes

Every session declares one mode in `session.yaml`:

- **Standard:** The default. Implement the control and run one concise, observable check. Keep only
  the decision points and stop conditions that protect the implementation.
- **Extended:** Use only when the session records a specific reason. Confirm the intended path and
  the blocked or failure path, then pause for a delivery-owner checkpoint. `verify.ps1` is optional
  when automation helps.

Neither mode creates an evidence package or temporary resources solely to prove a result. Do not
add test fixtures or fixture-cleanup scripts.

## Scaffold

```powershell
python .agents\skills\ai-governance-session-builder\scripts\scaffold_session.py `
  --repo-root . `
  --id 01 `
  --slug platform-baseline `
  --title "Microsoft Foundry platform baseline and inventory" `
  --duration-minutes 180
```

The command refuses to overwrite an existing session.

## Build sequence

### 1. Verify current facts

Recheck product names, availability, licensing, stable role IDs, resource types, API versions,
commands, policy aliases, quota, and networking requirements against authoritative Microsoft
sources. Record the URL, access date, and supported claim in `session.yaml`. Turn uncertainty into
an actionable preflight decision rather than guessing. This is author quality control, not
participant work.

### 2. Complete `session.yaml`

Use `schema_version: 2`. Define identity and scope, the implementation mode, 3-5 plain-language
outcomes, deliverables, and authoritative sources. An extended session must state why the extra
checks are needed. Do not add outcome IDs, acceptance criteria, evidence references, fixture paths,
or a structured disposition block.

Write control objectives and outcomes to match what the implementation does: deploy, configure,
or validate. Say that the platform enforces a control only when the platform blocks every in-scope
change path. If an operator can make an out-of-path change, describe the configuration, check, or
remediation instead.

For every `deliverables.leave_behind` path, add a matching `retained_files` entry with the file's
consumer and operational purpose. A repository location or a description such as “operational
control” is not an operational purpose.

### 3. Write the implementation document

`implementation/README.md` is the one participant-facing implementation document. Explain the
control, required decisions, stop conditions, implementation path, expected result, and what
happens after implementation. Keep stable principles separate from time-sensitive details.

Use the contract's participant-instruction clarity rules. Name the resource, identity, environment,
scope, role, and observable state that each instruction refers to. Define substitute controls
through inspectable state rather than calling them “equivalent.”

Use the one to three official sources required under `Architecture guidance`. Add another
participant-facing link only when it is needed for current product behavior or a supported task
path. Use sources already recorded in the manifest. Do not reproduce the full source list or link
every product mention.

Keep source-check and access dates in manifest metadata. Do not repeat those dates in the
implementation guide, deck, presenter notes, or generated participant pages.

Describe the current design and operating boundary directly. Do not explain discarded artifacts,
absent starter or solution trees, evidence packages, or repository simplification history in
participant content. Keep negative wording only when it prevents an unsafe action, narrows a real
scope claim, or distinguishes configuration from enforcement.

Use the shared level-two headings in the contract without adding or renaming any. The site
generator groups them into six chapter pages: scope and outcomes, architecture, before you start,
decisions and boundaries, implementation, and validation and operations. Under the scope heading, write
`What we will do`, `Why it matters`, and `Boundaries` as ordered level-three subsections. The first
subsection carries the manifest objective and owned result; the second explains the concrete
operational or governance reason; the third states the exact exclusions, enforcement limits, and
handoffs. Then write `Architecture at a glance`, `Design choices and tradeoffs`, and `Architecture
guidance` under the Architecture heading. Explain the flow, authoritative state, control boundary,
and relevant handoffs. Include a useful decision table and one to three official Microsoft links
already recorded in the manifest. Diagrams are optional. A referenced diagram needs editable
`.excalidraw` source, rendered `.svg`, and meaningful alt text; keep official Microsoft icons
unchanged. The generated **Who should join** and **What you need** blocks follow the complete scope
content. Detailed preparation stays on the Before you start page. A substantial field reference may
appear directly after `Decisions and stop conditions`; it remains part of that chapter.

Standard sessions contain one short `Confirm the result` step. Extended sessions add an intended
path check, a blocked or failure path check, and a delivery-owner checkpoint. Do not ask
participants to collect screenshots, export logs, assemble proof, or save a separate validation
record.

The implementation-file table classifies each artifact as `Deployment`, `Runtime`, or `Record` and
names its consumer. Operational purpose remains in manifest `retained_files` metadata. Keep live
Microsoft service state authoritative unless the repository intentionally owns desired state. In that case,
state which deployment or reconciliation process consumes the repository definition.

### 4. Build one implementation tree

Use `implementation/artifacts/` for production-shaped implementation definitions. Do not create parallel
incomplete and completed trees. Artifacts must parse or compile while unresolved customer
decisions use explicit `__REQUIRED_NAME__` values. `preflight.ps1` and `preflight.sh` must name and
reject each one before a state change. Every shipped PowerShell script must have a Bash counterpart
with the same behavior and safety checks.

Keep an artifact only when it does at least one real job: supplies automation or policy, checks live
state, supports an operational action, acts as a downstream machine contract, or records a customer
decision the platform cannot reconstruct. Merge, remove, or explicitly justify files that only
mirror live service state, restate another file, or prove that repository files agree.

Use transparent Bicep, PowerShell, JSON/YAML, policy, or KQL. Scripts stop on error and never accept
secrets as command arguments. Do not create disposable resources for a lab check.

### 5. Plan safe operation and restore

Keep both preflight scripts focused on prerequisites, unresolved decisions, the exact approved
implementation scope, and deployment preview where the platform supports one.

Every implementation document states what remains in operation and how to restore or remove the
implemented scope through the approved change path. Pair each PowerShell command block with its Bash
form immediately afterward so the generated site can present shell tabs. Add removal automation only
when it is safe and useful. The PowerShell version uses `SupportsShouldProcess` and
`ConfirmImpact = "High"`; both versions check an `implementationSession` marker and remove only the
documented implementation scope.

### 6. Author the briefing deck

Use `deck.md`, the bundled theme, RVAP logos, and unmodified Microsoft icons. Cover the control,
outcomes, a concise architecture overview, implementation tradeoffs, the implementation path,
safety gates, expected result, and operating state. Keep the established briefing depth. Merge
slides that would repeat the same point, and do not add proof, evidence, formal acceptance, or
routine review sections. Use the `implementation` slide class. End with a `closing` slide whose only
visible content is `Thank you!`; the theme supplies the white text and navy-to-blue gradient.
Presenter notes contain short delivery cues.

## Reconcile and validate

Check identity, mode, outcomes, implementation-file consumers, artifact value, authoritative state,
scope, safety gates, restore guidance, and source dates across the kit. Then run:

```powershell
python .agents\skills\ai-governance-session-builder\scripts\validate_session.py `
  sessions\01-platform-baseline

python .agents\skills\ai-governance-session-builder\scripts\validate_session.py `
  sessions\01-platform-baseline --render

python .agents\skills\ai-governance-session-builder\scripts\validate_session.py `
  modules\delegated-api-access --render
```

Do not keep generated HTML or PDF. A kit is complete when preflight gates unresolved decisions, the
implementation check is clear, links resolve, validation passes, and the deck renders when the
renderer is available.
