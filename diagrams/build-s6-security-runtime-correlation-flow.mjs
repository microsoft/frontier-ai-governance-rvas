// S6 — a completed request plus correlation becomes a reviewable runtime artifact.
import { C, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S6 · Correlation makes a request reviewable", C.security, { size: 26, align: "left" }));
els.push(text(40, 60, 1500, "Identity/network, gateway, model or agent, and tool controls can be layered. Owners use correlation_id to review the selected path; a completed request is not proof that a policy was enforced.", C.neutral, { size: 14, align: "left" }));

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

const layers = [
  ["Identity / network", C.identity],
  ["Gateway policy", C.indigo],
  ["Model / agent", C.eval],
  ["Tool boundary", C.amber],
];
let lx = 40;
layers.forEach(([label, color]) => {
  node(els, lx, 440, 190, 64, color, label, { titleSize: 13.5 });
  lx += 208;
});
// A direct diagnostic remains distinct from the selected gateway path.
const diag = node(els, 900, 440, 320, 78, C.amber, "Direct component diagnostic", { titleSize: 14, sub: "useful diagnosis; not gateway-path proof", subSize: 11.5 });
els.push(arrow(diag.cx, diag.y, manifest.cx, manifest.b, { stroke: C.amber.st, curved: false, dashed: true, endArrowhead: null }));

write(new URL("./s6-security-runtime-correlation-flow.excalidraw", import.meta.url).pathname, els);
