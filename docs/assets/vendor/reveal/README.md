# Vendored reveal.js

Minimal, self-hosted subset of [reveal.js](https://revealjs.com/) v6.0.1
(MIT, see LICENSE), used to render the per-session facilitator decks
(`docs/deck.html`).

Included: `reset.css`, `reveal.css` (bundles the print/PDF stylesheet),
`reveal.js`, `theme/white.css` (base theme, brand-overridden in
`assets/css/deck.css`), and the `markdown`, `notes`, and `highlight` plugins.

Vendored (not npm-installed) because the GitHub Pages deploy only runs
`node docs/build.js` and uploads `docs/` — there is no `npm ci` step, so the
framework must be committed to be served.

To update: `npm pack reveal.js`, extract the tarball, and re-copy these files
from `package/dist/`.
