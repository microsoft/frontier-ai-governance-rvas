# Optional implementation module contract

Optional modules are production-shaped implementation kits selected for a specific architecture
need. They sit outside the numbered 14-session sequence. A module is never Session 15, does not
belong to a program phase, and must not change session counts or dependencies.

## Required structure

```text
modules/kebab-case-slug/
  .gitignore
  module.yaml
  deck.md
  assets/
  implementation/
    README.md
    artifacts/
      README.md
    scripts/
      preflight.ps1
      preflight.sh
      remove.ps1         # optional
      remove.sh          # required when remove.ps1 exists
      verify.ps1         # optional, extended mode only
      verify.sh          # required when verify.ps1 exists
```

Modules use the same artifact, script, restore, sourcing, deck, and safety rules as sessions.
`module.yaml` is the content authority for the kit.
Use the shared facilitated-duration convention: 30-minute increments covering the briefing,
customer decisions, guided implementation, observable check, and operating or restore handoff.

### Live-only modules

Use `implementation.live_only: true` only when Microsoft service state is the complete durable
record and the module must not keep customer-specific definitions, records, or evidence. A
live-only module still has the participant guide, paired preflight scripts, sources, deck, and a
live observable check. It uses an empty `deliverables.leave_behind` list and `retained_files: []`.
Its `implementation/artifacts/README.md` can explain that boundary, but the directory has no
other files and the participant guide omits the **Implementation files** table.

Every other module keeps the normal artifact and retained-file requirements. Do not label a
module live-only merely to avoid documenting production configuration or an operational record
that has a real consumer.

## Manifest schema

```yaml
schema_version: 2
module:
  slug: "delegated-api-access"
  title: "Delegated API access with OAuth on-behalf-of"
  duration_minutes: 210
  status: "draft"
  last_verified: "2026-08-25"
  audience:
    - "Application and identity engineers"
  prerequisites:
    - "An approved nonproduction application chain"
  related_sessions:
    - "Session 03 - Entra identity, RBAC, PIM, and workload identities"
  control_objective: "Configure downstream APIs to authorize the signed-in user's delegated identity."
implementation:
  mode: "extended"
  extended_reason: "Authorization must be confirmed for both a permitted and denied user."
implementation_outcomes:
  - "Record the delegated trust chain and consent boundary."
  - "Configure a confidential middle tier for on-behalf-of exchange."
  - "Validate permitted and denied downstream authorization paths."
deliverables:
  implementation: "implementation/README.md"
  deck: "deck.md"
  leave_behind:
    - "implementation/artifacts/oauth-client-settings.json"
retained_files:
  - path: "implementation/artifacts/oauth-client-settings.json"
    consumer: "The confidential middle-tier deployment"
    operational_purpose: "Configure the OAuth client and downstream API scopes used for on-behalf-of exchange."
sources:
  - title: "Microsoft identity platform and OAuth 2.0 On-Behalf-Of flow"
    url: "https://learn.microsoft.com/entra/identity-platform/v2-oauth2-on-behalf-of-flow"
    accessed: "2026-08-25"
    supports: "Protocol behavior and token-exchange constraints."
```

Use three to five outcomes. `related_sessions` provides context and cross-links; it does not make
the module part of the numbered sequence. Follow the session contract's implementation-file value
test, `retained_files` schema, authoritative-state rule, and limits on platform-enforcement claims.

For a live-only module, add `live_only: true` under `implementation`, set
`deliverables.leave_behind: []`, and set `retained_files: []`. Do not list a fabricated
implementation artifact merely to satisfy the normal structure.

## Participant document

Use the shared chapter order, replacing only the first heading:

1. Module scope
2. Architecture
3. Before you start
4. Decisions and stop conditions
5. Implement
6. Confirm the result
7. After implementation

The generated site publishes the same six chapter pages as a session. Labels, page titles, deck
controls, and footer copy must say “module,” never “session.”

Under `## Module scope`, use the same three level-three headings required for numbered sessions:

1. `### What we will do`
2. `### Why it matters`
3. `### Boundaries`

The module objective belongs in `What we will do`. The reason for selecting the architecture
module belongs in `Why it matters`. `Boundaries` must keep the module outside the numbered sequence
and state its exact application, identity, data, and enforcement limits.

Use the session contract's three required Architecture subsections. Explain the module's
components, authoritative state, control boundary, flow, and handoffs. Include a useful decision
table and one to three official Microsoft links recorded in `module.yaml`. A diagram remains
optional; when referenced, its editable source, rendered SVG, alt text, and Microsoft icon use
follow the session contract.

Unless the module declares `implementation.live_only: true`, the `### Implementation files` table
uses `Type | File | Consumer` and lists every non-README file under `implementation/artifacts/`
exactly once. It excludes `implementation/scripts/`; show paired PowerShell and Bash commands
together beside the workflow step that uses them. Type must be `Deployment`, `Runtime`, or
`Record`, using the definitions in the session contract.

## Site boundary

Generate module pages under `site/modules/<slug>/`. The final chapter returns to the public
optional-modules section. Modules are not included in the session register, phase filters, session
search count, or previous/next session paging.
