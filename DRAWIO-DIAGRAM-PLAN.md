# Draw.io architecture diagram plan

## Purpose

Add architecture diagrams where the current session guide describes several services, identities,
regions, or operating handoffs that a simple flow cannot show clearly.

Keep existing diagrams when they already explain the control well. Do not convert diagrams just to
standardize on a new tool.

## Format policy

Use one editable source for each diagram:

- Use **Excalidraw** for decision flows, approval gates, lifecycle loops, and restore sequences.
- Use **Draw.io** for Azure architecture, network topology, identity boundaries, cross-service
  flows, and regional layouts.
- Publish the rendered **SVG** in the site and reference it from the implementation guide and deck
  with meaningful alt text.
- Keep the editable source in `assets/diagrams/`. Do not publish the source file with the static
  site.
- Do not maintain the same diagram in both formats.

## First implementation batch

### 1. Session 12: CI/CD promotion controls

Add a Draw.io release-promotion diagram.

Show the protected default branch, the full commit SHA, validation gates, preview and apply
environments, environment-scoped OIDC, approval checkpoints, Azure Resource Manager deployment,
API Management selector move, release record, and manual restore path.

The diagram should make one point: every consequential release action traces to the same immutable
commit.

### 2. Session 14: Foundry estate and lifecycle operations

Add a Draw.io estate-operations diagram.

Show the management-group scope, Azure Resource Graph, per-account model deployment reads, the
regional Models API, Service Health, Advisor, Cost Management, the shared Azure Workbook, the
command-line report, and the lifecycle owner.

Separate authoritative live-state sources from repository-owned query and scope definitions.

### 3. Session 06: APIM AI gateway

Replace or supplement the current high-level flow with a Draw.io request-path architecture.

Show the approved client, Microsoft Entra validation, Azure API Management policies, rate or token
limits, Azure AI Content Safety, backend routing, the Foundry agent, telemetry, and the owners of
the gateway and backend controls.

The diagram must distinguish the caller identity from service identities. It must also show that
requests are rejected before the backend when an earlier gateway control fails.

### 4. Foundry tool catalog integration module

Add a Draw.io architecture diagram.

Show the Azure API Center MCP server record, Foundry private tool catalog discovery, project
connection, versioned Toolbox, allowed tool list, approval requirement, version-specific check,
and agent consumers.

Make the preview boundary visible. API Center inventory access and runtime tool authorization are
different controls.

## Follow-up batch

Add diagrams after the first batch establishes the source and publishing workflow:

| Item | Diagram focus | Keep or add |
| --- | --- | --- |
| Session 02: Private networking | Approved hosts, private DNS zones, private endpoints, service dependencies, denied public path | Add Draw.io topology; keep Excalidraw cutover flow |
| Session 04: Governed agent baseline | Agent version, Entra Agent Identity, Foundry project, read-only OpenAPI tool, trace path | Add Draw.io architecture |
| Session 10: Red teaming and Defender | Adversarial run, remediation, fixed version, Defender alert, SOC handoff | Add a compact Excalidraw operations flow |
| Session 11: Observability and cost | Agent and tool spans, APIM metrics, Application Insights, alerts, budget thresholds, owner notification | Add Draw.io operations architecture |
| Session 13: Multiregion rehearsal | Primary and secondary paths, routing selector, health checks, restore move | Add Draw.io topology; keep Excalidraw rehearsal sequence |
| API Center registry discovery module | API Center record, lifecycle visibility filter, Entra sign-in, developer client | Add Draw.io architecture |
| External agent inventory module | Built-in, Registry sync, and SDK onboarding paths into Agent Registry | Replace the ASCII flow with a diagram |
| OBO delegated access module | Signed-in user, middle tier, Entra OBO, Key Vault certificate dependency, protected API | Keep Excalidraw; add Key Vault only if certificate custody needs emphasis |

## Keep as Excalidraw

These existing diagrams fit their sessions and do not need a Draw.io replacement:

- Session 01: baseline deployment and policy promotion
- Session 03: model governance lifecycle
- Session 05: Purview DLP lifecycle
- Session 07: API Center design-time versus runtime boundary
- Session 08: MCP two-hop identity boundary
- Session 09: evaluation release gate

The Session 05 product-coverage split diagram is currently not referenced from the implementation
guide or deck. Publish it where participants need that distinction, or remove it.

## Repository changes before adding Draw.io sources

The current session contract and validator require `.excalidraw` plus `.svg` for a referenced
diagram. Update that policy before adding the first Draw.io diagram.

1. Update the session and module contracts to accept either:
   - `.excalidraw` and `.svg`; or
   - `.drawio` and `.svg`.
2. Update `validate_session.py` so it checks the selected source format and matching SVG.
3. Update `scripts/build-session-pages.mjs` so it excludes `.drawio` source files from published
   assets, as it already excludes `.excalidraw`.
4. Update diagram README templates to document the two approved source formats and the
   single-source rule.
5. Add a short local workflow for Draw.io generation and validation. Keep temporary YAML specs,
   sidecars, previews, and review records outside published session folders.

## Diagram quality gate

Before adding a diagram:

- Start from the session's control objective and architecture section.
- Show the authoritative state, control boundary, identity boundary when relevant, and handoff.
- Use official Microsoft icons without changing them. Keep product names next to the icons.
- Avoid duplicating detail already explained well in the guide.
- Use readable labels and clear directional connectors.
- Use the RVAP visual system rather than the Draw.io skill's default dark theme.
- Render SVG and verify that labels, arrows, boundaries, and icons remain readable.
- Update the implementation guide and deck together. The diagram must say the same thing in both.

## Completion criteria

For each adopted diagram:

- One editable source and one matching SVG live under `assets/diagrams/`.
- The guide and deck use the SVG with descriptive alt text.
- The source, SVG, guide, deck, and manifest describe the same control boundary.
- The session validator passes and the static site builds successfully.
