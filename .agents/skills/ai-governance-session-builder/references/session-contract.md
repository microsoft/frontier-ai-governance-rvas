# Guided co-implementation session contract

Schema version 2 defines one production-shaped implementation tree. The customer implementation
team makes the decisions, applies changes in an approved scope, confirms the result, and owns the
operational control.

## Required structure

```text
sessions/NN-kebab-case-slug/
  .gitignore
  session.yaml
  deck.md
  assets/
  implementation/
    README.md
    artifacts/
      README.md
      deployment-inputs.json  # example downstream machine contract
    scripts/
      preflight.ps1
      preflight.sh
      remove.ps1         # optional
      remove.sh          # required when remove.ps1 exists
      verify.ps1         # optional, extended mode only
      verify.sh          # required when verify.ps1 exists
```

`delivery-guide.md` is optional. Do not add `implementation-guide.md`, `lab/`, `starter/`,
`solution/`, `material.md`, or an evidence tree. Do not add a test-fixture cleanup script.

Keep one syntactically valid artifacts tree with at least one implementation file beyond its README.
Put unresolved customer decisions in artifacts as `__REQUIRED_NAME__`; preflight must reject each
sentinel before any deployment.

## Manifest schema

```yaml
schema_version: 2
session:
  id: "01"
  slug: "platform-baseline"
  title: "Microsoft Foundry platform baseline and inventory"
  duration_minutes: 180
  status: "draft"
  last_verified: "2026-08-24"
  audience:
    - "Platform engineers"
  prerequisites:
    - "The approved subscription and exact implementation scope are recorded in the deployment inputs."
  dependencies:
    - "Engagement pre-work complete"
  control_objective: "Deploy an owned, tagged Microsoft Foundry project in the approved scope."
implementation:
  mode: "standard"
implementation_outcomes:
  - "Deploy a tagged Microsoft Foundry resource and project through Bicep."
  - "Configure the recorded owner and operating boundary."
  - "Validate the live resource tags and project scope after deployment."
deliverables:
  implementation: "implementation/README.md"
  deck: "deck.md"
  leave_behind:
    - "implementation/artifacts/infra/foundry/main.bicep"
retained_files:
  - path: "implementation/artifacts/infra/foundry/main.bicep"
    consumer: "The platform deployment pipeline"
    operational_purpose: "Deploy and reconcile the repository-owned Microsoft Foundry baseline."
sources:
  - title: "What is Microsoft Foundry?"
    url: "https://learn.microsoft.com/..."
    accessed: "2026-08-24"
    supports: "Current resource and project model."
```

Use 3-5 plain-language outcomes. They do not have IDs and do not need to be repeated verbatim in
the implementation document or deck.

`implementation.mode` is `standard` or `extended`. Extended sessions add a non-empty
`implementation.extended_reason` that names the delivery need. Standard sessions omit that field.

`duration_minutes` is facilitated customer working time in 30-minute increments. It includes the
briefing, required customer decisions, guided implementation, observable check, and operating or
restore handoff. It assumes prerequisites, access, and nonproduction capacity are ready before the
session. Do not include procurement, asynchronous approval or provisioning waits, or optional deep
dives in the published duration.

Control objectives and outcomes must distinguish deployment, configuration, and validation from
enforcement. Claim platform enforcement only when the Microsoft service sits on every in-scope
change path and blocks noncompliant changes. If an operator can change the service out of path,
describe what the kit configures or checks and name any detection or remediation path.

`retained_files` covers every path in `deliverables.leave_behind`. Each entry names a concrete
consumer and operational purpose. “Operational control,” “session output,” and the repository itself
are not consumers or operational purposes.

Do not add structured acceptance criteria, completion fields, evidence references, fixture paths,
or disposition fields.

## Participant instruction clarity

Write every prerequisite, decision, and stop condition so a participant can identify what to
inspect and who must act.

- Replace unresolved references such as “the target” with the exact resource, identity,
  environment, or scope.
- Separate resource-state checks from operator-access checks when they have different owners or
  validation paths.
- Name the built-in role and assignment scope when the implementation requires one. Permit a custom
  role only when an authoritative source supports it and the guide states the required actions or
  names the named preflight check that verifies them.
- Explain an internal platform property in plain language before asking the participant to inspect
  its literal value.
- Do not use “appropriate,” “sufficient,” “least-privilege,” or “equivalent permission” as a
  substitute for the required role, action, scope, and access duration.
- Keep prerequisite-session alternatives only when the substitute is explicit. Name the required
  control state, exact configuration or record, owner, and observable result.
- Split a sentence when it combines independent checks or decisions.

## Implementation document

`implementation/README.md` is the canonical participant document. Use these sections:

1. Session scope
2. Architecture
3. Before you start
4. Decisions and stop conditions
5. Implement
6. Confirm the result
7. After implementation

Keep these as the only level-two headings and in this order. Use level-three headings for
session-specific detail. When a session needs a substantial artifact field guide, add
`## Field reference` directly after `## Decisions and stop conditions`.

Under `## Session scope`, use these level-three headings exactly once and in this order:

1. `### What we will do`
2. `### Why it matters`
3. `### Boundaries`

`What we will do` states the manifest control objective, the concrete in-session state changes, and
the observable result owned by this session. `Why it matters` names the operational or governance
decision enabled by that result. `Boundaries` names the exact environment, resources, change path,
authoritative systems, exclusions, enforcement limits, and downstream handoffs that prevent the
reader from overreading the control.

Do not use a later session's check as the current session objective. Do not turn the objective into
a list of commands, files, or workflow steps. Avoid `each`, `only`, `prevents`, `depends`, or similar
exclusive claims unless the implemented platform control covers every stated in-scope path.

Under `## Architecture`, use these level-three headings exactly once and in this order:

1. `### Architecture at a glance`
2. `### Design choices and tradeoffs`
3. `### Architecture guidance`

`Architecture at a glance` explains the components and flow in plain language. Name the
authoritative state, the control boundary, and the handoffs that matter to this implementation.
Add a diagram when it makes that explanation easier to follow. A diagram is optional.

`Design choices and tradeoffs` contains at least one useful Markdown table. Prefer
`Decision | Chosen approach | Benefits | Costs and limitations | Revisit when`. A focused table is
fine when those columns do not fit the decision. Record choices that change the implementation;
do not build a catalogue of unrelated alternatives.

`Architecture guidance` links to one to three official Microsoft sources that support the design
choices. Every link must correspond to a source in `session.yaml`. Keep access dates in the
manifest, not in participant-facing text.

When the architecture uses a diagram, commit its editable `.excalidraw` source and rendered `.svg`
under `assets/diagrams/`. Reference the SVG from the implementation guide with alt text that
describes the flow or relationship shown. Use official Microsoft product icons without redrawing,
recoloring, cropping, rotating, or distorting them.

Within `## Before you start`, place `### Implementation files` after the prerequisites
and before commands or detailed preparation. Follow it with a `Type | File | Consumer` table.
List every file under `implementation/artifacts/` except `README.md` exactly once. Do not list files
under `implementation/scripts/`; paired shell commands appear together beside the workflow step
that uses them.

Use only these Type values:

- `Deployment`: deployment definitions, parameters, workflows, or configuration that changes
  service state;
- `Runtime`: machine contracts, runtime code, queries, or generated machine output consumed
  downstream; and
- `Record`: human-owned Markdown decisions and runbooks, or machine-consumed operational records
  and approvals.

The table consumer must agree with `retained_files` for each retained artifact.

The generated site publishes the canonical document as six chapter pages:

| Chapter | Included sections |
| --- | --- |
| Scope and outcomes | Session scope; generated audience and prerequisite blocks |
| Architecture | Architecture |
| Before you start | Before you start; commands and detailed preparation |
| Decisions and boundaries | Decisions and stop conditions; optional Field reference |
| Implementation | Implement |
| Validation and operations | Confirm the result; After implementation |

The first page focuses on scope, outcomes, and the control objective stated under
`What we will do`. Place the
generated **Who should join** and **What you need** blocks inside the chapter content, immediately
after all three scope subsections. The chapter names and boundaries stay the same across sessions.
Do not split a workflow across new level-two headings; use level-three headings within the
appropriate chapter.

Keep the path readable. Decision checkpoints belong immediately before consequential state
changes. Routine steps do not need a checkpoint.

A standard session has one concise observable check. State what to inspect and the expected result.
Do not require a screenshot, exported log, saved command output, or separate sign-off.

An extended session explains the intended-path check, the blocked or failure-path check, and the
delivery-owner checkpoint. The owner observes the result during delivery. No evidence package is
created.

The `After implementation` section states what remains, who owns it, and how to restore or remove
the implemented scope. Add a short scope limitation when work occurs outside the intended production
boundary.

## Artifacts and scripts

`implementation/artifacts/` contains production definitions, parameters, decision records, or
operational templates that still have a job after delivery. Keep a implementation file only when it:

- supplies automation or policy;
- checks live state;
- supports an operational action;
- acts as a downstream machine contract; or
- records a customer decision that the platform cannot reconstruct.

Files that only mirror live service state, restate another file, or prove that repository files
agree must be merged, removed, or explicitly justified in `retained_files` and classified in the
implementation-file table. Live Microsoft service state remains authoritative unless the repository intentionally owns
desired state. When the repository owns desired state, name the deployment or reconciliation
process that consumes it.

Every PowerShell script has a Bash counterpart with the same behavior and safety checks. PowerShell
scripts enable strict mode and stop on errors. Bash scripts use `#!/usr/bin/env bash` and
`set -euo pipefail`. Scripts never accept secrets as command arguments or write customer data into
the repository.

`preflight.ps1` and `preflight.sh` are required. Both check tools, files, the exact approved
implementation scope, and every decision sentinel. Add the same deployment preview to both when the
platform provides a stable one.

In `implementation/README.md`, place the Bash form immediately after each PowerShell command block:

````markdown
```powershell
.\scripts\preflight.ps1 -TargetScope $targetScope
```

```bash
./scripts/preflight.sh --target-scope "$target_scope"
```
````

The generated site turns adjacent PowerShell and Bash fences into synchronized shell tabs.

Removal automation is optional. Use it only when automation is safer than a documented manual
restore or removal path. When a PowerShell removal script is present, it:

- enables `SupportsShouldProcess`;
- sets `ConfirmImpact = "High"`;
- prints the exact scope;
- checks an `implementationSession` marker; and
- removes only the documented implementation scope.

`verify.ps1` is absent from standard sessions. An extended session may include it when one script
makes the two checks easier to run. It must not create test resources or write an evidence package.

Never create lab resources solely to test a result. There is no fixture-cleanup phase.

## Author sources

Time-sensitive product claims stay in `session.yaml` with an authoritative URL, access date, and
the claim supported by that source. This is author quality control. The participant workflow does
not collect or validate these references.

Use the one to three official links required under `Architecture guidance`. Elsewhere in the guide,
link official documentation when it helps a participant check current product behavior or follow a
supported task. Prefer one relevant link at the point of use. Do not copy the manifest source list
into the guide or link routine product mentions.

Keep verification and access dates in `last_verified` and source `accessed` fields. Do not repeat
them in participant-facing prose, deck content, or presenter notes.

Describe what the participant uses and who owns it. Do not mention discarded files, absent
starter or solution trees, evidence packages, or prior repository structure. Negative statements
belong only where they block unsafe behavior, define a meaningful scope limit, or prevent an
incorrect enforcement claim.

Never commit credentials, tenant or subscription IDs, endpoints, prompts, telemetry, screenshots,
or customer data.

Link meaningful prerequisites and handoffs to the relevant numbered sibling session. Keep
self-references, implementation markers, filenames, and repeated nearby mentions as plain text.

## Deck

Use Marp, the bundled theme, RVAP logos, and official Microsoft icons. Keep the existing briefing
depth. Include a concise architecture overview and the few tradeoffs that change implementation.
Cover the control, outcomes, implementation path, safety gates, expected result, operating state,
recap, and close. Combine material when a separate architecture or tradeoff slide would repeat
another slide. Do not add proof, evidence, formal acceptance, fixture cleanup, or routine review
slides. Use the `implementation` slide class. Presenter notes should be short delivery cues. The
final slide uses the `closing` class and contains only the visible heading `Thank you!`. The theme
renders it as centered white text on the navy-to-blue gradient.

## Validator boundary

The validator checks structure and implementation safety:

- schema version, session identity, mode, outcomes, deliverables, and source metadata;
- required core paths and local links;
- absence of obsolete evidence, guide, verification, and fixture-cleanup paths where prohibited;
- the shared level-two heading order used to generate the six participant chapters;
- the architecture subsections, decision table, official Microsoft links, manifest source
  correspondence, and referenced diagram pairs;
- at least one implementation file and its leave-behind mapping;
- extended-mode intended, blocked or failure, and delivery-owner checkpoint language;
- preflight coverage for unresolved decision sentinels, the exact approved implementation scope,
  and preview handling;
  and
- restore or removal safety patterns when a removal script exists.

It does not compare prose across files or enforce outcome wording, acceptance mappings, evidence
graphs, implementation-file consumer quality, artifact value, enforcement claims, or structured
acceptance records. Authors and reviewers must apply those contract checks directly.
