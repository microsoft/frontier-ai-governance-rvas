# AI Governance Platform diagrams (Excalidraw)

Hand-crafted Excalidraw diagrams used in the docs. They are the editable source
of truth for the published SVG assets.

## What's here

| Source (`.excalidraw`)   | Rendered SVG (in docs)                 | Used in                     |
|--------------------------|----------------------------------------|-----------------------------|
| `journey.excalidraw`     | `docs/assets/diagrams/journey.svg`     | `docs/start/understand-rvas.md` |
| `landscape.excalidraw`   | `docs/assets/diagrams/landscape.svg`   | `docs/reference/governance-capability-guide.md` |
| `assessment.excalidraw`  | `docs/assets/diagrams/assessment.svg`  | `docs/assessment/index.md`  |
| `azure-agent-platform-reference.excalidraw` | `docs/assets/diagrams/azure-agent-platform-reference.svg` | `docs/reference/platform-technical-guide.md` |
| `s0-operating-model-handoff.excalidraw` | `docs/assets/diagrams/s0-operating-model-handoff.svg` | `docs/s0-foundations/concepts.md` |
| `s1-autonomous-agent-backend-auth-flow.excalidraw` | `docs/assets/diagrams/s1-autonomous-agent-backend-auth-flow.svg` | `docs/s1-identity/technical.md` |
| `s1-agent-identity-model.excalidraw` | `docs/assets/diagrams/s1-agent-identity-model.svg` | `docs/s1-identity/concepts.md` |
| `s1-user-agent-backend-auth-flow.excalidraw` | `docs/assets/diagrams/s1-user-agent-backend-auth-flow.svg` | `docs/s1-identity/technical.md` |
| `s2-compliance-flow.excalidraw` | `docs/assets/diagrams/s2-compliance-flow.svg` | `docs/s2-data-compliance/concepts.md` |
| `s3-gateway-trust-boundary.excalidraw` | `docs/assets/diagrams/s3-gateway-trust-boundary.svg` | `docs/s3-platform-foundation/concepts.md` |
| `s3-private-dns-resolution-flow.excalidraw` | `docs/assets/diagrams/s3-private-dns-resolution-flow.svg` | `docs/s3-platform-foundation/technical.md` |
| `s4-authority-admission-tree.excalidraw` | `docs/assets/diagrams/s4-authority-admission-tree.svg` | `docs/s4-agent-engineering/concepts.md` |
| `s5-tool-api-governance-record-model.excalidraw` | `docs/assets/diagrams/s5-tool-api-governance-record-model.svg` | `docs/s5-tool-api-governance/technical.md` |
| `s6-security-runtime-correlation-flow.excalidraw` | `docs/assets/diagrams/s6-security-runtime-correlation-flow.svg` | `docs/s6-security-runtime/concepts.md` |
| `s7-evaluation-release-handoff.excalidraw` | `docs/assets/diagrams/s7-evaluation-release-handoff.svg` | `docs/s7-evaluation/concepts.md` |
| `s8-red-teaming-asr-decision.excalidraw` | `docs/assets/diagrams/s8-red-teaming-asr-decision.svg` | `docs/s8-red-teaming/concepts.md` |
| `s9-reconciliation-gap-flow.excalidraw` | `docs/assets/diagrams/s9-reconciliation-gap-flow.svg` | `docs/s9-control-plane/concepts.md` |
| `s10-policy-boundary-and-evidence.excalidraw` | `docs/assets/diagrams/s10-policy-boundary-and-evidence.svg` | `docs/s10-in-process-governance/concepts.md` |
| `s11-end-to-end-traceability-flow.excalidraw` | `docs/assets/diagrams/s11-end-to-end-traceability-flow.svg` | `docs/s11-operate-measure/technical.md` |
| `s11-operating-review-flow.excalidraw` | `docs/assets/diagrams/s11-operating-review-flow.svg` | `docs/s11-operate-measure/concepts.md` |
| `s13-portfolio-to-s0-feedback-loop.excalidraw` | `docs/assets/diagrams/s13-portfolio-to-s0-feedback-loop.svg` | `docs/s13-portfolio-governance/concepts.md` |

The `.excalidraw` files are the editable source of truth: open them directly at
<https://excalidraw.com> (File → Open) to tweak by hand. The `build-*.mjs`
scripts are how they were generated programmatically; `lib.mjs` holds the shared
builder + the indigo palette aligned to `docs/assets/extra.css`.

## Editing workflow

Two ways to change a diagram:

1. **By hand**: open the `.excalidraw` in the Excalidraw app, edit, export/replace
   the SVG (or re-run the render step below on the saved file).
2. **Programmatically**: edit the matching `build-*.mjs`, then rebuild + render.

## Regenerate everything

```bash
cd diagrams
npm install
npx playwright install chromium   # one-time: headless browser for SVG export
npm run all                       # build .excalidraw -> render SVG -> copy into docs
```

`npm run build` (`build-all.mjs`) auto-discovers every `build-*.mjs`, `npm run
render` (`render-all.mjs`) renders every `*.excalidraw`, and `publish-svg` copies
every `*.svg` into `docs/assets/diagrams/`. New session diagrams follow the
`s<N>-<slug>` naming convention and are picked up automatically.

Rendering loads `@excalidraw/excalidraw` from a CDN in a headless Chromium and
exports each scene to SVG (and a 2× PNG next to it for visual review). It needs
network access the first time.

> `node_modules/` is gitignored; the committed artifacts are the `.excalidraw`
> sources, the build scripts, and the SVGs under `docs/assets/diagrams/`.
