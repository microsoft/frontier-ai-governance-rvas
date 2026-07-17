// S6 — a completed request plus correlation becomes a reviewable runtime artifact.
import { C, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S6 · Correlation makes a request reviewable", C.security, { size: 26, align: "left" }));
els.push(text(40, 60, 1500, "A completed adapter request is not proof a policy was enforced. Owners use correlation_id to review approved gateway telemetry, then decide acceptance in their records system.", C.neutral, { size: 14, align: "left" }));

const req = node(els, 40, 260, 200, 100, C.security, "Gateway adapter request", { titleSize: 14, sub: "safe references only", subSize: 12 });
const manifest = node(els, 300, 250, 210, 120, C.indigo, "gateway-proof manifest", { titleSize: 14, sub: "safe refs +\ncorrelation_id", subSize: 12 });
connect(els, req, manifest, { stroke: C.security.st });

const transport = node(els, 580, 170, 230, 84, C.neutral, "Transport result", { titleSize: 14, sub: "pass / fail — not a\nsecurity decision", subSize: 12 });
const telemetry = node(els, 580, 300, 230, 84, C.data, "Approved gateway telemetry", { titleSize: 13.5, sub: "correlation_id appears", subSize: 12 });
connect(els, manifest, transport, { stroke: C.indigo.st });
connect(els, manifest, telemetry, { stroke: C.indigo.st });

const owners = node(els, 880, 240, 230, 120, C.hero, "Platform & security owners", { titleSize: 14, sub: "acceptance decision in\napproved records system", subSize: 12 });
connect(els, transport, owners, { stroke: C.neutral.st });
connect(els, telemetry, owners, { stroke: C.data.st });

const artifact = node(els, 1180, 250, 220, 100, C.start, "Reviewable runtime artifact", { titleSize: 14 });
connect(els, owners, artifact, { stroke: C.hero.st });

// diagnostic is not gateway-path proof
const diag = node(els, 300, 440, 320, 78, C.amber, "Direct component diagnostic", { titleSize: 14, sub: "e.g. a Content Safety call — not gateway-path proof", subSize: 11.5 });
els.push(arrow(diag.cx, diag.y, manifest.cx, manifest.b, { stroke: C.amber.st, curved: false, dashed: true, endArrowhead: null }));

write(new URL("./s6-security-runtime-correlation-flow.excalidraw", import.meta.url).pathname, els);
