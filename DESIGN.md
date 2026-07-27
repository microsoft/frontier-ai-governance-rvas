---
name: AI Governance Platform
description: A calm, evidence-first RVAP documentation system for enterprise AI-agent governance.
colors:
  rvap-blue: "#1A77E3"
  rvap-blue-deep: "#0078D4"
  deep-navy: "#032254"
  navy-mid: "#0F3A7A"
  hero-accent: "#BFDBFE"
  surface-blue-wash: "#F5F8FE"
  surface-paper: "#FAFBFD"
  surface-white: "#FFFFFF"
  surface-muted: "#EEF1FA"
  line: "#E3E6ED"
  line-soft: "#DDE6F7"
  ink: "#111827"
  ink-muted: "#47494E"
  ink-faint: "#6B7280"
  govern-teal: "#14868A"
  assurance-red: "#DC2626"
  evaluation-purple: "#504092"
  operate-slate: "#475569"
  success-green: "#16A34A"
  caution-gold: "#CA8A04"
typography:
  display:
    fontFamily: "Aptos Display, Outfit, Segoe UI, system-ui, sans-serif"
    fontSize: "clamp(2.2rem, 5vw + 0.5rem, 4.2rem)"
    fontWeight: 700
    lineHeight: 1.06
    letterSpacing: "-0.01em"
  headline:
    fontFamily: "Aptos Display, Outfit, Segoe UI, system-ui, sans-serif"
    fontSize: "clamp(1.6rem, 3vw + 0.4rem, 2.6rem)"
    fontWeight: 700
    lineHeight: 1.06
    letterSpacing: "-0.01em"
  title:
    fontFamily: "Aptos Display, Outfit, Segoe UI, system-ui, sans-serif"
    fontSize: "1.1rem"
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "-0.01em"
  body:
    fontFamily: "Aptos, Inter, Segoe UI, system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.65
  label:
    fontFamily: "Cascadia Code, JetBrains Mono, Fira Code, ui-monospace, SF Mono, monospace"
    fontSize: "0.70rem"
    fontWeight: 600
    lineHeight: 1.4
    letterSpacing: "0.12em"
rounded:
  sm: "7px"
  md: "12px"
  lg: "18px"
  pill: "999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "16px"
  lg: "24px"
  xl: "40px"
  section-tight: "56px"
  section: "88px"
components:
  button-primary:
    backgroundColor: "{colors.rvap-blue}"
    textColor: "{colors.surface-white}"
    typography: "{typography.body}"
    rounded: "{rounded.sm}"
    padding: "11px 22px"
  button-ghost:
    backgroundColor: "transparent"
    textColor: "{colors.ink}"
    typography: "{typography.body}"
    rounded: "{rounded.sm}"
    padding: "11px 22px"
  card:
    backgroundColor: "{colors.surface-white}"
    textColor: "{colors.ink}"
    rounded: "{rounded.lg}"
    padding: "24px"
  badge:
    backgroundColor: "{colors.surface-muted}"
    textColor: "{colors.ink-faint}"
    typography: "{typography.label}"
    rounded: "{rounded.sm}"
    padding: "3px 7px"
  nav-link:
    backgroundColor: "transparent"
    textColor: "{colors.ink-muted}"
    typography: "{typography.body}"
    rounded: "{rounded.sm}"
    padding: "6px 11px"
---

# Design System: AI Governance Platform

## Overview

**Creative North Star: "The Evidence Briefing Room"**

The AI Governance Platform visual system should feel like a calm executive briefing room for decisions that need evidence, owners, and safe handoff. It is calm, executive, evidence-first, facilitator-friendly, and Microsoft-aligned: a structured workspace where cross-functional leaders can scan, trust, and act without mistaking templates for proof.

The system uses RVAP light surfaces, Deep Navy authority, RVAP Blue action, and compact mono labels to create the rhythm of a professional governance packet. It avoids playful consumer SaaS, dark cyber dashboards, decorative gradients that dilute the evidence hierarchy, and fabricated proof signals.

**Key Characteristics:**
- Light, breathable documentation canvas with restrained institutional color.
- Strong navy-to-blue hero moments reserved for orientation and confidence.
- Cards, chips, and session rails that clarify ownership, phase, evidence, and sequence.
- Mono labels used as coordinates, not as decoration.
- Motion and depth kept subtle so content remains the product.

## Colors

The palette is RVAP light institutional: Deep Navy creates authority, RVAP Blue signals action, and pale blue-white surfaces keep long-form governance content readable.

### Primary
- **RVAP Blue**: The primary action and emphasis color. Use it for primary buttons, focus rings, selected states, NIST/persona badges, inline proof links, and the final stop in the hero gradient.
- **RVAP Blue Deep**: The supporting blue for hover, link emphasis, and denser interface states that need more contrast than the primary brand blue.
- **Deep Navy**: The authority color for headings, hero starts, brand anchoring, modal overlays, and high-confidence structural moments.

### Secondary
- **Govern Teal**: A supporting phase and session accent for platform and governance material.
- **Assurance Red**: A warning and assurance accent for runtime security, adversarial testing, and material risk cues.
- **Evaluation Purple**: A supporting accent for quality, evaluation, and evidence review.
- **Operate Slate**: A neutral-slate accent for portfolio, lifecycle, and operating review material.

### Neutral
- **Blue-Wash Canvas**: The page background and large-area resting surface.
- **Paper Surface**: Secondary page and card gradient surface.
- **White Surface**: Cards, nav, modals, diagrams, and document containers.
- **Muted Blue Surface**: Hover states, selected nav backgrounds, and low-emphasis panels.
- **Line** and **Soft Line**: Structural borders and dividers.
- **Ink**, **Muted Ink**, and **Faint Ink**: Body, secondary, and metadata text.

### Named Rules
**The Evidence First Rule.** Color must clarify status, phase, ownership, or action; it must not imply proof that the customer has not provided.

**The Blue Scarcity Rule.** RVAP Blue is strongest when it is rare. Use it for decisive affordances and evidence links, not for washing every module.

**The Semantic Exception Rule.** Green, caution gold, red, purple, teal, and slate are allowed when they encode real status, phase, or assurance meaning.

## Typography

**Display Font:** Aptos Display with Outfit, Segoe UI, system-ui, sans-serif fallback.
**Body Font:** Aptos with Inter, Segoe UI, system-ui, sans-serif fallback.
**Label/Mono Font:** Cascadia Code with JetBrains Mono, Fira Code, ui-monospace, SF Mono, monospace fallback.

**Character:** The type system pairs executive headline authority with practical facilitator readability. Display typography carries confident decisions; body copy stays plain, measured, and long-form friendly; mono labels act like coordinates in a governance packet.

### Hierarchy
- **Display** (700, `clamp(2.2rem, 5vw + 0.5rem, 4.2rem)`, 1.06): Hero headlines and major page statements.
- **Headline** (700, `clamp(1.6rem, 3vw + 0.4rem, 2.6rem)`, 1.06): Section titles and document hero titles.
- **Title** (700, `1.1rem`, 1.2): Session card titles, step titles, and compact module headers.
- **Body** (400, `16px`, 1.65): Documentation prose, session explanations, and helper copy. Reading columns should stay around 52-74ch depending on the surface.
- **Label** (600, `0.70rem`, uppercase or compact metadata, tracked): Eyebrows, session chips, badges, statistics labels, and search/result metadata.

### Named Rules
**The Briefing Hierarchy Rule.** Every screen should make the next decision obvious through one strong headline, short explanatory prose, and compact metadata.

**The Mono Coordinates Rule.** Mono type labels navigation, state, and evidence coordinates; do not use it for body paragraphs or decorative texture.

## Layout

The spatial model is a centered documentation shell with a 1200px default max width, 24px mobile gutters, and 40px desktop gutters. Sections use generous vertical rhythm (`56px` tight, `88px` standard) so long-form governance content remains scannable and workshop-ready.

Home and campaign-style surfaces use two-column hero grids above 900px, card grids with `auto-fit`/`auto-fill`, and compact phase modules. Reading surfaces use a narrower document body around 74ch with optional sticky asides above 900px. Mobile layouts collapse early and prefer horizontal scroll only for chip-like session chapter navigation.

**The Scannable Handoff Rule.** Dense governance material must be chunked into cards, steps, chips, and facts before it becomes a wall of prose.

## Elevation & Depth

Tonal layering comes first, with restrained shadows for state and focus. The system mostly communicates depth through white cards on blue-wash surfaces, thin borders, subtle gradients, and top accent bars; shadows appear on cards, hover states, search modals, diagrams, and hero glass modules.

### Shadow Vocabulary
- **Ambient Low** (`0 4px 20px -8px rgba(3, 34, 84, 0.12), 0 1px 3px rgba(3, 34, 84, 0.06)`): Soft resting elevation for low-emphasis surfaces.
- **Card Lift** (`0 1px 3px rgba(3, 34, 84, 0.08), 0 4px 12px rgba(3, 34, 84, 0.06)`): Default cards, diagrams, dropdowns, and structured containers.
- **Hero Glass Lift** (`0 24px 60px rgba(3, 34, 84, 0.28)`): Dark-hero statistics and glass panels only.
- **Modal Lift** (`0 18px 48px -12px rgba(3, 34, 84, 0.35), var(--shadow-card)`): Search and temporary overlays.

### Named Rules
**The Tonal Before Shadow Rule.** Prefer surface color, border, and accent bars first; add shadow only when interaction or modal priority needs it.

## Shapes

The form language is gently rounded, precise, and conservative. Small controls use 7px corners, standard cards use 12px corners, and larger containers or modals use 18px corners. Pills are reserved for session chapter navigation and compact filter-like controls.

Borders are thin and visible. Cards and modules often use a 3px top accent bar to indicate phase or session identity without overwhelming the page.

**The No Novel Silhouette Rule.** New components should use the existing 7/12/18px radius scale and thin border language unless a user explicitly asks for a new visual world.

## Components

Components are precise, quiet, and decision-oriented; they should feel like facilitation instruments rather than promotional widgets.

### Buttons
- **Shape:** Compact rounded rectangle (7px radius), inline-flex alignment, 7px icon gap.
- **Primary:** RVAP Blue background with white text, 11px 22px padding, 600 weight, and a soft accent glow. In dark heroes, primary buttons invert to white with Deep Navy text.
- **Ghost:** Transparent background with a thin border; hover uses Muted Blue Surface and darker border.
- **Hover / Focus:** Hover changes opacity or surface quietly. Focus uses a 2px RVAP Blue outline offset by 2-3px. Active state scales to 0.97.

### Navigation
- **Style:** Sticky white nav with blur, 58px height, RVAP logo, compact links, and dropdown panels.
- **States:** Active and hover links use Muted Blue Surface and stronger ink. Desktop labels should not wrap; mobile navigation becomes a full-width stacked panel below the header.
- **Search:** Command palette uses a centered white modal, 18px radius, blue-navy overlay, and compact result rows with highlighted terms.

### Chips and Badges
- **Style:** Mono, uppercase, compact, and semantically colored. Standard badges use 3px 7px padding and 4px corners.
- **Session chips:** Larger mono blocks use phase accent color, white text, and 7px corners.
- **Status badges:** GA, Preview, static-only, persona, and tier badges use semantic sub-palettes; these hues encode meaning and should not be collapsed into the single blue brand palette.

### Cards and Containers
- **Corner Style:** Standard cards use 12px or 18px radius with a 1px border.
- **Background:** White or a subtle white-to-paper gradient on the blue-wash canvas.
- **Shadow Strategy:** Card Lift at rest; hover may translate up 2-3px and deepen the shadow.
- **Border:** Always retain a visible line unless the card sits on a dark hero glass surface.
- **Internal Padding:** 18-24px for compact cards, up to 32px for figure cards and major containers.

### Reading Surfaces
- **Style:** Documentation bodies prioritize measure and hierarchy. Use 74ch max width for article copy, clear breadcrumbs, and optional sticky asides.
- **Inline artifacts:** Lab artifact links use mono styling, pale blue surface, RVAP Blue text, and an external-link glyph.
- **Diagrams:** Diagram figures sit in white cards with borders, padding, and Card Lift; lightbox overlays use dark navy scrims.

### Hero Modules and Statistics
- **Style:** On dark heroes, module cards and stats use translucent white glass, thin white borders, and restrained backdrop blur.
- **Role:** These elements orient the facilitator quickly; they should summarize journey, phase, and evidence flow rather than becoming decorative tiles.

## Do's and Don'ts

### Do:
- **Do** preserve the RVAP light canvas, Deep Navy authority, and RVAP Blue action hierarchy.
- **Do** use cards, chips, and fact rows to make owners, evidence, session phase, and next decisions scannable.
- **Do** keep focus rings visible and use the existing 2px RVAP Blue outline treatment.
- **Do** use semantic accent colors when they encode real phase, status, risk, or assurance meaning.
- **Do** keep long-form documentation readable with narrow measures, plain language, and generous section rhythm.

### Don't:
- **Don't** use dark cyber dashboard styling, neon security tropes, or decorative gradients that compete with evidence hierarchy.
- **Don't** use color, badges, charts, or testimonials to imply customer proof that the product does not have.
- **Don't** turn mono labels into body copy or decorative noise.
- **Don't** introduce new corner-radius scales, heavy shadows, or ornamental component silhouettes without an explicit redesign request.
- **Don't** collapse status and phase colors into RVAP Blue when the distinction carries meaning.
