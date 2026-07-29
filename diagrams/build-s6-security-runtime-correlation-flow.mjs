// S6 — runtime-path acceptance needs route, correlation, SOC, and retention.
import { C, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S6 · Runtime-path acceptance package", C.security, { size: 26, align: "left" }));
els.push(text(40, 60, 1500, "Trace one non-production request through the expected path. Customer reviewers accept the interpretation only after telemetry, SOC route, and retention are reviewable.", C.neutral, { size: 14, align: "left" }));

const path = [
  ["Caller + app", "caller identity\nworkload identity", C.identity],
  ["Gateway / APIM", "route · policy\ncorrelation starts", C.indigo],
  ["Model / agent", "safety settings\ntrace context", C.eval],
  ["Tool / API", "operation boundary\ntool response", C.amber],
  ["Response path", "block · annotate · log\nalert · fallback", C.security],
];

const nodes = [];
let x = 40;
path.forEach(([title, sub, color]) => {
  const n = node(els, x, 190, 210, 104, color, title, { titleSize: 14, sub, subSize: 11.5 });
  nodes.push(n);
  x += 250;
});
for (let i = 0; i < nodes.length - 1; i += 1) {
  els.push(arrow(nodes[i].r, nodes[i].cy, nodes[i + 1].x, nodes[i + 1].cy, { stroke: C.security.st, curved: false }));
}

const manifest = node(els, 315, 385, 260, 110, C.indigo, "gateway-proof manifest", {
  titleSize: 14,
  sub: "safe refs + correlation_id\ntransport result only",
  subSize: 11.5,
});
const telemetry = node(els, 650, 385, 260, 110, C.data, "Telemetry contract", {
  titleSize: 14,
  sub: "log source · query owner\ntime window · blind spots",
  subSize: 11.5,
});
const soc = node(els, 985, 385, 260, 110, C.hero, "SOC + response route", {
  titleSize: 14,
  sub: "queue · severity · playbook\nstop condition",
  subSize: 11.5,
});

connect(els, nodes[1], manifest, { stroke: C.indigo.st });
connect(els, manifest, telemetry, { stroke: C.data.st });
connect(els, telemetry, soc, { stroke: C.hero.st });

const reviewer = node(els, 490, 590, 330, 110, C.start, "Customer reviewer decision", {
  titleSize: 15,
  sub: "accept · defer · reject · route\nblock · diagnostic-only",
  subSize: 12,
});
const retention = node(els, 875, 590, 300, 110, C.data, "Retention boundary", {
  titleSize: 14,
  sub: "records location · export/deletion/hold\ninvestigation references",
  subSize: 11.5,
});
connect(els, telemetry, reviewer, { stroke: C.start.st });
connect(els, soc, reviewer, { stroke: C.start.st });
connect(els, reviewer, retention, { stroke: C.data.st });

const diag = node(els, 40, 560, 330, 110, C.amber, "Direct diagnostic path", {
  titleSize: 14,
  sub: "Content Safety / Prompt Shields test\nuseful context; not path proof",
  subSize: 11.5,
});
els.push(arrow(diag.r, diag.cy, reviewer.x, reviewer.cy, { stroke: C.amber.st, curved: false, dashed: true }));

write(new URL("./s6-security-runtime-correlation-flow.excalidraw", import.meta.url).pathname, els);
