# RVAS docs diagrams (Excalidraw)

Hand-crafted Excalidraw diagrams used in the docs, where a bespoke visual reads
better than an auto-laid-out Mermaid graph. The remaining Mermaid diagram
(the co-delivery **sequence** diagram in `how-to-deliver.md`) is intentionally
left as Mermaid — lifelines and message ordering are what Mermaid does best.

## What's here

| Source (`.excalidraw`)   | Rendered SVG (in docs)                 | Used in                     |
|--------------------------|----------------------------------------|-----------------------------|
| `journey.excalidraw`     | `docs/assets/diagrams/journey.svg`     | `docs/index.md`             |
| `landscape.excalidraw`   | `docs/assets/diagrams/landscape.svg`   | `docs/reference/index.md`   |
| `assessment.excalidraw`  | `docs/assets/diagrams/assessment.svg`  | `docs/assessment/index.md`  |

The `.excalidraw` files are the editable source of truth — open them directly at
<https://excalidraw.com> (File → Open) to tweak by hand. The `build-*.mjs`
scripts are how they were generated programmatically; `lib.mjs` holds the shared
builder + the indigo palette aligned to `docs/assets/extra.css`.

## Editing workflow

Two ways to change a diagram:

1. **By hand** — open the `.excalidraw` in the Excalidraw app, edit, export/replace
   the SVG (or re-run the render step below on the saved file).
2. **Programmatically** — edit the matching `build-*.mjs`, then rebuild + render.

## Regenerate everything

```bash
cd diagrams
npm install
npx playwright install chromium   # one-time: headless browser for SVG export
npm run all                       # build .excalidraw -> render SVG -> copy into docs
```

Rendering loads `@excalidraw/excalidraw` from a CDN in a headless Chromium and
exports each scene to SVG (and a 2× PNG next to it for visual review). It needs
network access the first time.

> `node_modules/` is gitignored; the committed artifacts are the `.excalidraw`
> sources, the build scripts, and the SVGs under `docs/assets/diagrams/`.
