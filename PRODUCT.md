# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Stack

Plain static HTML, CSS, and JavaScript, deployed with GitHub Pages.

## Users

The public site serves two audiences equally:

- Enterprise AI, cloud platform, security, and governance leaders evaluating a practical Microsoft AI governance engagement.
- Practitioners using the seven-session program to adopt Citadel inside an existing enterprise platform.

## Product Purpose

Present an enterprise adoption program around Citadel. Upstream repositories remain authoritative
for reference architecture, deployable accelerators, supported parameters, and product mechanics.
The program helps customer teams select a bounded implementation path, apply local controls, and
establish the ownership needed to operate and upgrade it.

The site explains how the work runs, shows all seven sessions, and helps readers choose the complete
adoption route or a focused route.

## Positioning

This repository is the customer adoption layer around Citadel. It stays outside the upstream source
trees. Sessions use tested upstream implementations, then add the customer decisions that product
documentation cannot make: platform fit, permitted scope, identity boundaries, privacy choices,
operating ownership, and release controls.

Upstream Citadel documentation explains how its architecture and components work. This program
starts with the customer's environment and asks a different set of questions: which path fits, what
should remain disabled, who approves each consequential choice, and how the deployed control will
be checked and restored.

Customer-owned overlays are the interface between those two layers. They hold local configuration
and policy choices that must survive an upstream upgrade without copying the complete
infrastructure-as-code implementation.

Customer engineers make bounded changes in a sandbox or nonproduction tenant. The control owner
listed in the session record confirms the check. The appropriate service, security, data, or release
owner approves consequential changes. Each runbook names the restore or removal owner and the
approved change path.

Standard mode is the default. The team implements one explicit control, keeps production-shaped
customer overlays and normal operational records, observes one defined result, and documents the
restore or removal path.

Extended mode is used only when a control needs both an allowed and a blocked or failure check. The delivery lead records the reason before the session, and the delivery owner confirms the result at a checkpoint. Both modes keep only the records needed for normal operations and use the implementation resources required by the control.

The complete route contains seven published sessions. The site calculates working time from the
session manifests. Each duration uses 30-minute increments and includes briefing, customer
decisions, guided implementation, observable checks, and the operating or restore handoff. Agreed
prerequisites, access, and nonproduction capacity must be ready before each session. Approval waits,
procurement, provisioning delays, and optional deep dives sit outside the published time.

The program has three phases:

1. **Foundation, Sessions 01-03:** Citadel platform foundation, Citadel Governance Hub, and Citadel
   Agent Spoke.
2. **Runtime governance, Sessions 04-05:** Citadel contract governance, then evaluation and threat
   gates.
3. **Operations, Sessions 06-07:** Citadel observability and operations, then controlled promotion
   and lifecycle.

Focused routes include only the sessions needed for a useful outcome:

- **Citadel foundation:** Sessions 01, 02, and 03.
- **Govern an existing workload:** Sessions 01, 02, and 04.
- **Quality and security:** Sessions 01 through 05.
- **Operations and release:** Sessions 01, 02, 04, 06, and 07.

The complete Citadel adoption route runs all seven sessions. Focused routes omit unrelated controls
and do not represent the complete operating model.

## Operating Context

The series centers on Citadel and the Microsoft services used by its tested upstream
implementations. Customer-owned overlays connect those implementations to the customer's platform,
control owners, and approved operating paths.

Readers need enough architecture detail to make customer decisions without repeating the complete
upstream product reference. Each session must distinguish the upstream capability, the customer
decision, the retained overlay, and the operating handoff.

LLMOps runs through the sequence. Sessions 03 and 04 establish the governed workload and its
contracts. Session 05 applies evaluation and threat gates. Sessions 06 and 07 connect telemetry,
operations, promotion, restore, and lifecycle management.

Optional modules cover needs outside the seven-session count, including Agent 365 with Purview
controls, multi-region recovery, and delegated access.

## Capabilities and Constraints

- The first public surface is a static, responsive reference site with no server-side runtime.
- The site must deploy from this repository through GitHub Pages.
- Source material is date-sensitive and must preserve its dated caveats, product distinctions, and citations.
- The seven sessions remain modular so readers can run the complete route or choose a focused route with its prerequisites.
- Optional implementation modules may address architecture-specific needs outside the default
  sequence. They remain separate from the seven sessions and do not change session numbering, phases,
  or counts.
- Upstream Citadel implementation commits must be pinned and tested before use.
- Customer overlays and operational records remain customer-owned and version-controlled.
- Do not copy a full upstream infrastructure-as-code implementation when the session can consume the
  pinned upstream implementation directly.
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
- The RVAS reference repository supplies visual identity only. Do not copy its curriculum structure, claims, or S0-S11 numbering into this program.
- Time-sensitive product claims must trace to the dated authoritative sources recorded in the relevant session manifest.

## Product Principles

1. Build controls, do not merely describe them.
2. Confirm each standard-mode control with one observable check.
3. Keep every change bounded to an approved nonproduction scope.
4. Pin tested upstream Citadel implementations and keep customer changes in overlays.
5. Keep controls and normal operational records in customer-owned source control.
6. Name the restore or removal owner and the approved change path.
7. Keep focused routes short. Add a route only when it gives customers a distinct, useful outcome.
8. State platform, licensing, regional, and lifecycle caveats precisely.
9. Link to upstream product mechanics instead of rewriting them; explain the customer decision and control added here.

## Accessibility & Inclusion

The public reference must remain keyboard-accessible, responsive, and readable for cross-functional enterprise teams while preserving exact Microsoft product and governance terminology.

## Brand Commitments

- The RVAS repository at `C:\Users\marcoolivo\repos\frontier-ai-governance-rvas` is the binding visual reference for this site, not a content source.
- Use the supplied RVAP logo files and official Microsoft product icons from that reference. Keep the assets local to this repository for GitHub Pages.
- Match the RVAS navy and blue palette, typography, spacing, card geometry, navigation, hero treatment, and icon containers.
- Keep phase and status colors semantic. Do not turn every signal into the same blue.
- Follow the root `AGENTS.md` writing rule for every piece of prose added or changed.
