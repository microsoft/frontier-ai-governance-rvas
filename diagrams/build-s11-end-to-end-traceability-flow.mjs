// S11 — end-to-end traceability across gateway, orchestration, execution, data, and monitoring.
import { C, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S11 - End-to-end traceability flow", C.eval, { size: 26, align: "left" }));
els.push(text(40, 60, 1500, "A reviewer needs a documented join method across the route. Missing correlation is a coverage gap, not a pass.", C.neutral, { size: 14, align: "left" }));

const apim = node(els, 70, 160, 220, 110, C.indigo, "1. Gateway", { titleSize: 16, sub: "request · policy\nquota · correlation", subSize: 12 });
const foundry = node(els, 360, 160, 220, 110, C.hero, "2. Orchestration", { titleSize: 16, sub: "agent run · model\ntool decision", subSize: 12 });
const exec = node(els, 650, 160, 220, 110, C.found, "3. Execution host", { titleSize: 16, sub: "app trace\ndependency call", subSize: 12 });
const data = node(els, 940, 160, 220, 110, C.data, "4. Data or tool", { titleSize: 16, sub: "query · auth\nlatency · error", subSize: 12 });
const monitor = node(els, 1230, 160, 220, 110, C.eval, "5. Monitor", { titleSize: 16, sub: "logs · metrics\ntraces · alerts", subSize: 12 });

connect(els, apim, foundry, { stroke: C.indigo.st });
connect(els, foundry, exec, { stroke: C.hero.st });
connect(els, exec, data, { stroke: C.found.st });
connect(els, data, monitor, { stroke: C.data.st });

const op = node(els, 470, 390, 600, 90, C.amber, "Shared correlation method", { titleSize: 18, sub: "traceparent · operation ID · gateway request ID · run ID · documented time-window join", subSize: 13 });
for (const n of [apim, foundry, exec, data, monitor]) {
  els.push(arrow(n.cx, n.b, op.cx, op.y, { stroke: C.amber.st, dashed: true, curved: false, endArrowhead: null }));
}

const owner = node(els, 470, 560, 600, 80, C.start, "Operating decision record", { titleSize: 16, sub: "population · review period · coverage limit · owner · action", subSize: 13 });
connect(els, op, owner, { stroke: C.start.st });

write(new URL("./s11-end-to-end-traceability-flow.excalidraw", import.meta.url).pathname, els);
