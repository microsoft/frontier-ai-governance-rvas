---
target: homepage
total_score: 29
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 2
timestamp: 2026-08-25T16-27-28Z
slug: site-index-html
---
# Homepage design critique

## Design Health Score

| # | Heuristic | Score | Key issue |
|---|---|---:|---|
| 1 | Visibility of system status | 3/4 | Search and filters announce results, but the navigation does not track the current section. |
| 2 | Match between system and real world | 3/4 | The language fits governance practitioners, though abbreviations such as APIM, MCP, OIDC, PIM, and IaC assume prior knowledge. |
| 3 | User control and freedom | 2/4 | Filters are reversible. Search has no one-click reset, including in the empty state. |
| 4 | Consistency and standards | 4/4 | Phase colors, type, card patterns, and controls behave consistently. |
| 5 | Error prevention | 3/4 | Prerequisites and gates are explicit. Dependency guidance appears after the full session register. |
| 6 | Recognition rather than recall | 3/4 | Session cards expose useful detail. Route links use session numbers alone, so readers must remember what each number means. |
| 7 | Flexibility and efficiency | 3/4 | Search, phase filters, anchors, route presets, and keyboard focus help experienced readers. There is no compact comparison view. |
| 8 | Aesthetic and minimalist design | 2/4 | The page is controlled, but repeated panels and large collections flatten the hierarchy. |
| 9 | Error recovery | 3/4 | The zero-result message is clear, though recovery is manual. |
| 10 | Help and documentation | 3/4 | Guidance is substantial. A first-time reader still lacks a short route-selection aid. |
| **Total** |  | **29/40** | **Good foundation. Prioritization needs work.** |

All ten heuristics apply because this page is both a reading surface and a decision surface.

## Design Specificity Verdict

**Content-specific, compositionally familiar.**

The page belongs to this program. Product icons, phase semantics, retained outputs, dependency-aware routes, and customer ownership make that clear. The structure is more generic: gradient hero, metric tray, glass panel, card grids, registers, and a dark caveat band. It could carry another Microsoft consulting offer with modest changes.

The strongest product character lives in the session register and implementation contract. The page should bring that character into the main decision path.

The deterministic scan returned zero findings for `site/index.html`. That clean result has limits. Missing parser packages forced the detector into its regex fallback, which cannot calculate selector matching, custom properties, or computed contrast. No browser executable or mutable browser canvas was available, so no visual overlay was produced.

## Overall Impression

The homepage feels credible and carefully built. It explains what customers keep and gives technical readers enough detail to trust the material. Then it asks them to scan 15 equal-weight sessions before showing the routes that could make the program feel manageable.

Move route selection earlier. That one change would turn the page from a thorough index into a guided entry point.

## What's Working

1. **The hero sells an operating result.** The headline and outcome panel connect deployment work to retained files, checks, and rehearsal (`site/index.html:84-170`).
2. **Phase semantics help readers scan dense material.** Foundation, assurance, and operations keep stable color and marker cues across the register (`site/styles.css:631-639`, `site/styles.css:1020-1048`).
3. **The page respects real reading conditions.** It includes a skip link, visible focus, an `aria-live` result count, reduced-motion handling, keyboard controls, print styles, and no-JavaScript navigation (`site/index.html:42`, `site/index.html:314`, `site/script.js:68-151`).

## Cognitive Load

The page has **moderate cognitive load**, with three checklist failures:

- **Chunking:** six readiness cards, 15 session cards, six routes, six responsibility rows, and three caveat groups create several long collections.
- **Minimal choices:** the register presents 15 equally prominent destinations. Six route choices arrive later.
- **Progressive disclosure:** nearly the whole program, including readiness and ownership detail, sits on one page. Only caveat bodies collapse.

Grouping and basic hierarchy work. The overload starts at the session register, where visitors face the full curriculum before they see a smaller recommended path.

## Emotional Journey

The opening feels capable and reassuring. The customer-owned outcome panel answers an important trust question: what remains after the engagement?

The mood changes during pre-work and the 15-card register. The offer starts to feel like a 53.5-hour obligation rather than a guided program. “Pick a route” restores some agency, but it arrives late.

Ownership and caveats build trust. The footer then ends on a production warning, with no next action for someone assessing fit.

## Priority Issues

### [P1] Put route selection before the full session register

**Why it matters:** Sponsors need the smallest credible path first. Practitioners also benefit from a frame before choosing among 15 records.

**Evidence:** Fifteen fixed-height cards appear at `site/index.html:318-646`; recommended routes begin at `site/index.html:653`. Cards are fixed at `300px` in `site/styles.css:1050-1058`.

**Fix:** Place a compact route chooser above the register. Show the full 15-session build as the default, then the dependency-sound shorter routes. Keep the detailed register below it.

**Suggested command:** `$impeccable distill`

### [P1] Explain the engagement method alongside the product boundary

**Why it matters:** The current “Method” link answers which Microsoft systems are in scope. Buyers also need to know how the work runs, what each session produces, and when extended mode applies.

**Evidence:** The navigation’s “Method” link leads to the Foundry and Agent 365 boundary cards (`site/index.html:50`, `site/index.html:177-202`). The implementation contract does not receive the same homepage treatment.

**Fix:** Make “Method” a short explanation of the delivery contract: one control, retained output, observable check, rollback, and the trigger for extended mode. Keep the product boundary as supporting context.

**Suggested command:** `$impeccable clarify`

### [P2] Reduce the number of hero-level proof objects

**Why it matters:** The headline should lead. The four statistics, four outcome rows, and three phase cards all compete in the first viewport.

**Evidence:** These elements sit together at `site/index.html:83-190`. The metric tray and outcome panel use similarly heavy shadows at `site/styles.css:454-509`.

**Fix:** Keep the customer-owned outcome panel as the main proof object. Cut the metrics to the two facts that change a decision, or move the metric tray below the hero. Let the phase cards introduce the program section.

**Suggested command:** `$impeccable layout`

### [P2] Give search recovery a visible control

**Why it matters:** The empty state tells people what to do, then makes them do it manually. This is a small but needless trap, especially for keyboard and screen-reader users.

**Evidence:** The empty state appears at `site/index.html:648-650`; filter behavior is handled at `site/script.js:68-110`.

**Fix:** Add a “Clear search and filters” button inside the empty state. Return focus to the search field and announce the restored result count.

**Suggested command:** `$impeccable harden`

### [P2] Remove fixed card height on narrow screens

**Why it matters:** Long titles and outcomes wrap more at 320-375px and at 200% zoom. A fixed height with hidden overflow can clip useful content.

**Evidence:** Session cards use `height: 300px` and `overflow: hidden` at `site/styles.css:1050-1061`. The single-column breakpoint reduces spacing without restoring automatic height (`site/styles.css:2617-2621`).

**Fix:** Use `min-height` on wide screens and `height: auto` below the single-column breakpoint. Check the longest card at 320px and 200% zoom.

**Suggested command:** `$impeccable adapt`

## Persona Red Flags

**Enterprise governance sponsor:** The retained-output promise is strong. The sponsor still reaches “53.5 working hours” before seeing a short route or the engagement-mode decision. The footer offers no way to move from evaluation to fit.

**Alex, experienced platform practitioner:** Search and filters are useful. Route links show session numbers without names (`site/index.html:672-711`), which forces Alex to remember the mapping. There is no compact comparison view.

**Sam, keyboard or screen-reader user:** The skip link, labels, focus styling, and result announcements are solid. “Home” stays marked `aria-current="page"` during in-page navigation (`site/index.html:49`), and the empty state has no clear action. Escape closes the mobile menu correctly (`site/script.js:146-151`).

## Minor Observations

- The header search shortcut disappears below 560px (`site/styles.css:2538-2540`). The register search still exists, but users must scroll to find it.
- “53.5 working hours” reads like a commitment. Add a nearby scope or delivery-mode qualifier.
- “Session details are safe to print” (`site/index.html:315`) is imprecise because the cards link to the detailed pages.
- Print CSS removes routes and caveats (`site/styles.css:2784-2797`), even though both may belong in a decision packet.
- The surface brief has drifted from the current page. Treat it as stale context, not evidence about the live homepage.

## Questions to Consider

- Should a sponsor see all 15 sessions before seeing the shortest sound route?
- Is this page mainly selling the program or indexing it? The index currently wins.
- Which retained artifact gives a cautious sponsor the most confidence that the control will survive after delivery?
- What should a qualified evaluator do after reaching the footer?
