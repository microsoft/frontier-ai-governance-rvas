# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Stack

Plain static HTML, CSS, and JavaScript, deployed with GitHub Pages.

## Users

The public site serves two audiences equally:

- Enterprise AI, cloud platform, security, and governance leaders evaluating a practical Microsoft AI governance engagement.
- Practitioners using the 15-session series as a technical implementation reference.

## Product Purpose

Present a modular Microsoft AI governance series that customer teams can execute. The full series produces a working deployment and reusable, version-controlled configuration. The site explains how the work runs, shows all 15 sessions, and helps readers choose the full build or a focused route.

## Positioning

This is guided co-implementation. Customer engineers implement each control in a sandbox or nonproduction tenant. The control owner listed in the session record confirms the check, while the appropriate service, security, data, or release owner approves consequential changes. Each runbook identifies the restore or removal owner and the approved change path.

Standard mode is the default. The team implements one explicit control, keeps production-shaped configuration and normal operational records, observes one defined result, and documents restore or removal steps.

Extended mode is used only when a control needs both an allowed and a blocked or failure check. The delivery lead records the reason before the session, and the delivery owner confirms the result at a checkpoint. Both modes keep only the records needed for normal operations and use the implementation resources required by the control.

The complete route contains 48.5 facilitated working hours across the 15 published session durations. Each duration uses 30-minute increments and includes briefing and alignment, customer decisions, guided implementation, observable checks, and the operating or restore handoff. It assumes agreed prerequisites, access, and nonproduction capacity are ready before the session; asynchronous approvals, procurement, provisioning waits, and optional deep dives sit outside the published time. Focused routes deliver the selected control area and include its prerequisite sessions; they omit unrelated controls and do not represent the complete deployment.

## Operating Context

The series spans Microsoft Foundry, Foundry Agent Service, Foundry Control Plane, Microsoft Agent 365, Azure Policy, Entra ID, API Management, API Center, Purview, Defender, Azure Monitor, GitHub or Azure DevOps, Bicep, evaluations, and customer-owned implementation outputs.

Readers need an executive overview and enough technical detail to understand session dependencies, practical outcomes, session outputs, and the check that confirms each control.

LLMOps runs through the series as a cross-session thread rather than a single numbered session.
Session 04 covers model selection, deployment versions, quota, and retirement. Session 11 adds
repeatable evaluation and release thresholds. Session 13 connects tracing, operational signals,
cost, and incident response. Session 14 controls promotion and previous-release restore, and
Session 15 extends ownership and operations across the agent fleet.

We use LLMOps here to mean operating models, prompts, agents, evaluations, telemetry, cost
controls, and releases as one managed lifecycle. That's different from AIOps, which keeps its
narrower industry meaning of using AI to operate IT systems, and sits outside this course's default
scope.

## Capabilities and Constraints

- The first public surface is a static, responsive reference site with no server-side runtime.
- The site must deploy from this repository through GitHub Pages.
- Source material is date-sensitive and must preserve its dated caveats, product distinctions, and citations.
- The 15 sessions should remain modular so readers can run the complete route or choose a focused route with its prerequisites.
- Optional implementation modules may address architecture-specific needs outside the default
  sequence. They remain separate from the 15 sessions and do not change session numbering, phases,
  or counts.
- The site must not invent customer claims, testimonials, benchmarks, licensing promises, or deployment guarantees.

## Content Foundation

- `PRODUCT.md` defines the program purpose, operating model, and product constraints.
- Each `sessions/*/session.yaml` file defines that session's scope, dependencies, outcomes, session outputs, and dated authoritative sources.
- Each `modules/*/module.yaml` file defines an optional module's scope, related sessions, outcomes,
  session outputs, and dated authoritative sources.
- No customer logos, testimonials, case studies, screenshots, or quantitative outcome data are currently available and must not be fabricated.

## Content Authority

- `session.yaml` is the source of truth for its implementation guide, implementation files, scripts, deck, and generated session pages.
- `module.yaml` is the source of truth for an optional module's implementation guide, implementation
  artifacts, scripts, deck, and generated module pages.
- Cross-session public copy must agree with `PRODUCT.md` and the session manifests.
- Optional-module copy must agree with `PRODUCT.md`, its module manifest, and the boundaries stated
  by related session manifests.
- The RVAS reference repository supplies visual identity only. Do not copy its curriculum structure, claims, or S0-S12 numbering into this program.
- Time-sensitive product claims must trace to the dated authoritative sources recorded in the relevant session manifest.

## Product Principles

1. Build controls, do not merely describe them.
2. Confirm each standard-mode control with one observable check.
3. Keep implementation modular and dependency-aware.
4. Prefer customer-native, version-controlled tooling over bespoke governance software.
5. Document restore or removal, and automate only when it removes repetition or risk.
6. State platform, licensing, regional, and lifecycle caveats precisely.

## Accessibility & Inclusion

The public reference must remain keyboard-accessible, responsive, and readable for cross-functional enterprise teams while preserving exact Microsoft product and governance terminology.

## Brand Commitments

- The RVAS repository at `C:\Users\marcoolivo\repos\frontier-ai-governance-rvas` is the binding visual reference for this site, not a content source.
- Use the supplied RVAP logo files and official Microsoft product icons from that reference. Keep the assets local to this repository for GitHub Pages.
- Match the RVAS navy and blue palette, typography, spacing, card geometry, navigation, hero treatment, and icon containers.
- Keep phase and status colors semantic. Do not turn every signal into the same blue.
- Follow the root `AGENTS.md` writing rule for every piece of prose added or changed.
