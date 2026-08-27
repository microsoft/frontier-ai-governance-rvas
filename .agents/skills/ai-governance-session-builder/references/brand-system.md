# RVAP brand system for AI governance sessions

This skill carries forward the visual language used by the reference RVAP AI governance
repository. The creative direction is **the implementation briefing room**: calm, executive,
implementation-first, delivery-lead-friendly, and Microsoft-aligned.

## Core tokens

| Role | Token | Value |
|---|---|---|
| Primary action | RVAP Blue | `#1A77E3` |
| Microsoft platform accent | Microsoft Blue | `#0078D4` |
| Authority and headings | Deep Navy | `#032254` |
| Supporting navy | Navy Mid | `#0F3A7A` |
| Body copy | Charcoal | `#47494E` |
| Primary ink | Ink | `#111827` |
| Muted copy | Muted | `#6B7280` |
| Governance accent | Teal | `#14868A` |
| Evaluation accent | Purple | `#504092` |
| Assurance/risk | Red | `#DC2626` |
| Caution | Gold | `#CA8A04` |
| Success | Green | `#16A34A` |
| Main surface | White | `#FFFFFF` |
| Soft surface | Blue Wash | `#F5F8FE` |
| Alternate surface | Paper | `#FAFBFD` |
| Divider | Light Neutral | `#E3E6ED` |
| Soft divider | Navy Light | `#DDE6F7` |

Use blue sparingly for actions and source links. Use semantic colors only when they encode a real
phase, risk, status, or evaluation meaning. Color must not imply approval or production readiness.

## Typography

- Display: `"Aptos Display", "Outfit", "Segoe UI", system-ui, sans-serif`
- Body: `"Aptos", "Inter", "Segoe UI", system-ui, sans-serif`
- Mono labels/code: `"Cascadia Code", "JetBrains Mono", "Fira Code", ui-monospace, monospace`

Use display type for titles and section openers, body type for explanations, and mono type for
coordinates such as session IDs, control IDs, commands, and resource IDs.

## Layout principles

- Use a light, breathable canvas with strong navy hierarchy.
- Reserve the navy-to-blue gradient for covers, dividers, and closing slides.
- Prefer thin borders and tonal layering before shadows.
- Use 7px, 12px, and 18px corner radii; do not invent a new radius scale.
- Keep reading widths narrow and slide messages singular.
- Structure dense governance content as steps, cards, decision tables, and result blocks.
- Make ownership, the expected result, and the next decision easy to scan.

## Marp classes

The bundled theme supports:

- `cover`: navy-to-blue branded opening;
- `section-divider`: strong transition between teaching phases;
- `two-column`: balanced explanatory/visual layout;
- `cards`: two or three concise cards;
- `implementation`: implementation steps and timebox;
- `decision`: trade-offs or customer decisions;
- `closing`: centered white `Thank you!` text on the navy-to-blue gradient.

Apply one class with a Marp local directive:

```markdown
<!-- _class: implementation -->
```

Use simple HTML only for layouts supported by the theme. Keep the Markdown readable without
the renderer.

## Logos

Bundled logos live in `assets/logos/`:

- `logo-full.png`: transparent full logo;
- `logo-full-white.png`: full logo on white;
- `logo-mark.png`: transparent mark;
- `logo-mark-white.png`: mark on white.

Scale logos uniformly, keep clear space, and do not recolor or distort them. On dark cover
slides use the transparent full logo with the theme's white filter treatment. Do not place
the blue chevron directly on saturated blue without a contrast treatment.

## Microsoft service icons

Official service icons live in `assets/icons/microsoft/` in generated sessions.

- Do not crop, flip, rotate, distort, recolor, or combine icons into a new logo.
- Keep the product name visible near each icon.
- Use icons to clarify architecture or responsibility, not as decoration.
- Include only products actually discussed in the session.
- Preserve the copied `README.md`, which records the official source and usage constraints.

## Deck visual rhythm

Use a purposeful visual on architecture, process, or comparison slides. Prefer an editable
SVG or Mermaid-derived diagram stored under `assets/diagrams/`. Use cards for at most three
parallel ideas. Use a table only when row/column comparison is the message.

Avoid:

- dark cyber-dashboard styling and neon security tropes;
- decorative gradients on normal content slides;
- wall-of-text slides or paragraphs pasted from `implementation/README.md`;
- random stock imagery;
- icon grids without explanatory labels;
- status badges that imply customer approval or production readiness.

## Accessibility

- Maintain WCAG AA contrast for normal text.
- Do not rely on color alone; pair status color with text or a symbol.
- Use descriptive alt text for diagrams and meaningful images.
- Keep body text at least 24px in rendered slides.
- Avoid more than six short bullets on a standard slide.
- Preserve source order so the deck remains understandable as Markdown.
