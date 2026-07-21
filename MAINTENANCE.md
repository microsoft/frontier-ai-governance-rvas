# Maintenance Guide

This curriculum covers a **fast‑moving, preview‑heavy** area of Microsoft technology. Product names, GA/preview status, pricing, and capabilities change frequently (e.g. *Azure AI Foundry → Microsoft Foundry*). This guide keeps the content trustworthy over time.

## Review cadence

- **Quarterly** full review of every session and the `docs/reference/` source‑of‑truth.
- **Ad‑hoc** review whenever a major Microsoft announcement lands (Ignite, Build, monthly Message Center posts).

## "Last reviewed" convention

Every session `index.md` and every reference page carries a front‑of‑page stamp:

```markdown
!!! info "Freshness"
    **Last reviewed:** 2026-07-06 · Capabilities marked **Preview** may change.
```

Update the date whenever you re‑verify the page against current Microsoft Learn docs.

## Preview / GA badges

Use consistent inline badges next to capability names:

- `**GA**`: generally available.
- `**Preview**`: public/private preview; not for production SLAs.
- Pricing: always annotate as `(publicly announced; verify current)`.

## Refreshing the research reference

`docs/reference/` is derived from a structured research pass over official Microsoft sources. To refresh it, re‑run the research workflow that produced the original report (multiple focused searches across Microsoft Learn, the Microsoft 365 / Security blogs, and product GitHub repos), then update:

1. `docs/reference/index.md`: landscape narrative.
2. `docs/reference/governance-capability-guide.md`: capabilities, availability notes, and framework alignment.
3. `docs/reference/platform-technical-guide.md`: platform model and implementation boundaries.

## No screenshots

We deliberately **do not use screenshots**: portal UIs change fastest and screenshots rot. Prefer **click‑paths** (e.g. *Entra admin center → Protection → Conditional Access*), **Mermaid diagrams**, and **code**.

## Lab asset validation

CI (`.github/workflows/lab-lint.yml`) statically validates lab assets. Keep the `Verified: static-only` badge honest: only change it to `Verified: live-tenant` for an asset that has actually been run end‑to‑end in a real tenant and had its steps confirmed.
