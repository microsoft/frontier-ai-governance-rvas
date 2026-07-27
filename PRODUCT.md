# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Facilitators and customer governance, platform, security, identity, data, and AI engineering leaders preparing and running enterprise AI-agent governance working sessions.

## Product Purpose

AI Governance Platform is a practical S0-S13 curriculum for governing AI agents in enterprise environments. It helps customers turn bounded AI-agent governance questions into clear decisions, named owners, evidence references, and improvement backlog items. Success means the customer leaves each selected session with a durable, customer-owned decision or reference that can be reviewed, implemented, and improved through existing customer processes.

## Positioning

The product is a co-delivered curriculum that converts AI-agent governance ambiguity into customer-owned decisions, evidence references, owners, and improvement backlog items without claiming production deployment or storing customer evidence. The facilitator runs the method and protects the boundary; customer administrators operate privileged controls, and customer decision owners approve changes and accept risk.

## Operating Context

The curriculum is delivered through a static documentation site, per-session runbooks, offline lab kits, safe templates, and workspace-generation tools. It is used around customer working sessions that cover ownership, identity and authority, data governance, platform boundaries, engineering standards, tool/API governance, runtime assurance, evaluation, adversarial testing, control-plane records, in-process governance, operations, LLMOps, and portfolio improvement. Customer implementation, evidence retention, change approval, security operations, architecture, funding, and release decisions remain in the customer's existing processes and records systems.

## Capabilities and Constraints

The repository publishes session guidance, reference material, delivery planning, readiness assessment content, lab templates, shared schemas, source diagrams, and safe offline tooling. Generated customer workspaces store templates and references only. The product must preserve the report-only and customer-owned boundary: do not store customer identifiers, credentials, tenant configuration, exports, logs, screenshots, or evidence payloads in this repository. Templates, samples, mock results, and offline tool output are preparation aids and never prove that a customer control is deployed or operating. Product claims must be backed by official Microsoft sources, and fast-moving preview/GA details require freshness review.

## Brand Commitments

The product uses the AI Governance Platform name in repo content and RVAP/RVAS visual branding in the web experience. Existing brand assets, the RVAP light visual system, deep navy and RVAP blue palette, and the static `docs/` plus `labs/` structure are binding product constraints for future work.

## Evidence on Hand

The repository contains public curriculum content in `docs/`, per-session lab kits in `labs/`, shared schemas in `contracts/`, source diagrams in `diagrams/`, workspace generation tools in `tools/`, and a safe intake example in `examples/engagement-intake.example.json`. It intentionally does not contain customer evidence payloads, tenant-specific data, credentials, production logs, or screenshots.

## Product Principles

1. Keep decision authority with the customer.
2. Separate preparation artifacts from operating evidence.
3. Prefer bounded working sessions that end in owners, evidence references, and next decisions.
4. Treat official Microsoft documentation and explicit freshness review as the source for capability claims.
5. Preserve safe defaults: report-only, non-production, or documentation-only work until customer approval and evidence paths are present.

## Accessibility & Inclusion

The public web documentation should remain accessible, searchable, responsive, and readable for cross-functional enterprise teams. Future work should support plain-language facilitation while preserving exact terminology when it names a Microsoft product, control, or governance process.
