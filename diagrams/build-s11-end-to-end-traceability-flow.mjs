// S11 - End-to-end traceability across gateway, orchestration, execution, data/tool, monitoring, and operating decision.
import { C, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S11 · End-to-end traceability flow", C.eval, { size: 26, align: "left" }));
els.push(text(
  40,
  60,
  1500,
  "A reviewer needs a documented join method across the route. Missing or broken correlation is a coverage gap, not proof of healthy behavior.",
  C.neutral,
  { size: 14, align: "left" },
));

const apim = node(els, 60, 160, 220, 110, C.indigo, "1. Gateway", {
  titleSize: 16,
  sub: "request · policy\nquota · caller",
  subSize: 12,
});
const orchestration = node(els, 340, 160, 220, 110, C.hero, "2. Orchestration", {
  titleSize: 16,
  sub: "agent run · model\ntool decision",
  subSize: 12,
});
const exec = node(els, 620, 160, 220, 110, C.found, "3. Execution host", {
  titleSize: 16,
  sub: "app trace\nexception · dependency",
  subSize: 12,
});
const data = node(els, 900, 160, 220, 110, C.data, "4. Tool / data", {
  titleSize: 16,
  sub: "operation · auth\nlatency · result",
  subSize: 12,
});
const monitor = node(els, 1180, 160, 220, 110, C.eval, "5. Monitor", {
  titleSize: 16,
  sub: "logs · metrics\ntraces · alerts",
  subSize: 12,
});

connect(els, apim, orchestration, { stroke: C.indigo.st });
connect(els, orchestration, exec, { stroke: C.hero.st });
connect(els, exec, data, { stroke: C.found.st });
connect(els, data, monitor, { stroke: C.data.st });

const op = node(els, 390, 385, 680, 100, C.amber, "Shared correlation contract", {
  titleSize: 18,
  sub: "traceparent · operation ID · gateway request ID · run ID · tool call ID · cost dimension · documented time-window join",
  subSize: 12.5,
});
for (const n of [apim, orchestration, exec, data, monitor]) {
  els.push(arrow(n.cx, n.b, op.cx, op.y, { stroke: C.amber.st, dashed: true, curved: false, endArrowhead: null }));
}

const blind = node(els, 70, 410, 250, 90, C.security, "Coverage gap", {
  titleSize: 15,
  sub: "missing hop · sampled route\nretention/export break",
  subSize: 12,
});
els.push(arrow(blind.r, blind.cy, op.x, op.cy, { stroke: C.security.st, dashed: true, curved: false }));

const owner = node(els, 430, 570, 600, 90, C.start, "Operating decision record", {
  titleSize: 16,
  sub: "population · review period · coverage limit · query owner · validation reference · action",
  subSize: 13,
});
connect(els, op, owner, { stroke: C.start.st });

write(new URL("./s11-end-to-end-traceability-flow.excalidraw", import.meta.url).pathname, els);
