---
name: "Practical Microsoft AI Governance"
description: "The service-led RVAS field guide for practical Microsoft AI governance."
colors:
  rvap-blue: "#1a77e3"
  microsoft-blue: "#0078d4"
  navy: "#032254"
  mid-navy: "#0f3a7a"
  hero-accent: "#bfdbfe"
  surface: "#f5f8fe"
  paper: "#fafbfd"
  white: "#ffffff"
  line: "#e3e6ed"
  line-soft: "#dde6f7"
  ink: "#111827"
  ink-secondary: "#47494e"
  ink-muted: "#6b7280"
  phase-foundation: "#1a77e3"
  phase-assurance: "#14868a"
  phase-operations: "#504092"
typography:
  display: "\"Aptos Display\", Outfit, \"Segoe UI\", system-ui, sans-serif"
  body: "Aptos, Inter, \"Segoe UI\", system-ui, sans-serif"
  mono: "\"Cascadia Code\", \"JetBrains Mono\", \"Fira Code\", ui-monospace, monospace"
rounded:
  sm: "7px"
  card: "12px"
  panel: "18px"
---

# Design system

## Direction

The site is an implementation field guide, not a product dashboard. It uses RVAS navy and blue,
quiet working surfaces, official Microsoft service icons, and compact records. `PRODUCT.md`,
`services.json`, and the session or module manifest own the content. The RVAS reference supplies
visual direction only.

The build resolves every `services_in_scope` ID through `services.json`. Labels, categories, and
icon filenames come from that registry, so the homepage, service map, and chapter pages use the
same service identity.

## Page order

The homepage follows this order:

1. Hero promise and one customer-owned result
2. Leader and practitioner audience lanes
3. Guided co-implementation method
4. Session catalog and discovery controls
5. Complete and focused route guidance
6. Pre-work
7. Optional modules

The program facts remain quiet inside the hero: 15 sessions, 62 facilitated working hours, and three phases.
The outcome panel covers the governed deployment, source-controlled implementation, observable
check, and named restore or removal ownership.

## Tokens and restraint

- Navy carries the opening field and strongest headings.
- RVAP blue marks primary actions and the foundation phase.
- Teal marks live-traffic assurance. Purple marks operations.
- White and pale blue separate reading areas.
- Corners use 7px, 12px, or 18px. Routine cards use a border and restrained depth.
- Mono type is reserved for IDs, phase ranges, dates, counts, status, and duration.
- Official icons keep their original geometry and color.

Normal content does not use glass effects, gradient text, decorative pills, or nested card stacks.
The existing navy-to-blue hero field remains the single strong gradient.

## Homepage components

### Hero and audience lanes

The hero pairs a direct program promise with one compact customer-owned result. The two audience
lanes then direct leaders to routes and ownership, while practitioners go to the session catalog.

### Method

The method explains standard and extended implementation modes in two working steps: build and
check. A separate note preserves the governance boundary between Microsoft Foundry, Foundry
Control Plane, and Microsoft Agent 365. It also keeps the LLMOps and AIOps distinction explicit.

### Session discovery

The catalog is grouped by phase. Each session record includes its number, title, control objective,
observable result, duration, and a build-generated strip of every service in scope.

Discovery combines focused-route, service, and free-text controls. The catalog remains grouped by
phase without adding a separate phase filter. Routes and services are mutually exclusive, so
choosing one clears the other instead of creating an unexplained empty result.

The route controls sit directly above the service row. Every service button uses its official icon
and keeps its all-program session count, while phase markers update to show counts for the current
visible set. Route and service choices use `?route=<id>#program` and `?tool=<id>#program`, so a
filtered view can be shared. The nearby **View service map** link opens the service-first index.
Optional modules never enter the session filter.

JavaScript hides nonmatching records and announces the result count. Without JavaScript, all phase
groups and session records remain visible.

### Focused routes

The complete route anchors the section. Six focused routes sit below it as selectable paths rather
than a comparison table. Each path states the control state it reaches, its ending session, session
count, and calculated working time. A 14-step track shows how far the route travels and uses the
existing foundation, live-traffic, and operations colors. Route definitions and durations come
from the homepage builder so the cards, URLs, and filter logic stay aligned.

### Optional modules

Optional-module records keep their own status and duration. Their service strips are generated from
the module manifest. Modules remain outside the numbered catalog, session discovery controls, and session count.

## Service map

`service-map.html` is a service-first table generated from the registry and manifests. Each row
shows:

- official icon, label, and category;
- separate numbered-session and optional-module counts;
- direct links to each matching item;
- a link back to the homepage with the matching service selected.

The complete table is readable without JavaScript. Search matches the service label, category,
content title, and session number. The result count is announced, and an explicit empty state
appears when no row matches.

## Session and module chapters

Every chapter page uses the entity title as its `h1` in a compact light header. The header also
contains the breadcrumb, current chapter, phase or module status, and duration.

Six horizontal chapter tabs sit below the header. They scroll on narrow screens, keep native links,
and expose the current page with `aria-current`.

The desktop reading grid has the article on the left. A full labeled service list appears first in
the right column, followed by facts for identity, phase or status, duration, implementation mode,
and last verification date. The direct DOM order is services, article, facts. Grid areas preserve
that order on mobile.

The implementation guide stays inside one reading card. Scope pages retain the generated audience
and preparation block. Chapter pager links, slide-deck dialog, shell tabs, diagrams, and source
links keep their existing behavior.

## Accessibility and fallback

- Keep the skip link, semantic headings, visible focus, and native links and buttons.
- Result counts use polite live regions; empty states are explicit text.
- Icon strips include accessible service names even though icon images are decorative.
- Reduced-motion settings disable transitions and smooth scrolling.
- Print removes filters, navigation, dialogs, and chapter tabs. It prints all session records,
  complete service-map rows, and the chapter service/article/facts order on white.
- No-JavaScript pages expose the full catalog, module list, service map, chapter tabs, and guide.

## Responsive behavior

- Below 1100px, catalog cards use two columns.
- Below 900px, navigation collapses and chapter pages switch to services, article, then facts.
- Below 760px, page gutters tighten and homepage grids use one column.
- Below 560px, catalog records compact without hiding service scope or facts.
