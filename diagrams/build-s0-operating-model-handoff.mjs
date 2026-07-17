// S0 — the operating model turns ownership into a backlog that routes later work.
import { C, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1400, "S0 · From operating model to an owned, routed backlog", C.found, { size: 26, align: "left" }));
els.push(text(40, 60, 1400, "S0 names owners and records decisions before any AI tool is enabled — then routes each capability track to the session or process that owns it.", C.neutral, { size: 14, align: "left" }));

const om = node(els, 40, 210, 250, 176, C.found, "Operating model", {
  titleSize: 16,
  sub: "Who decides?\nWho does the work?\nWhere are decisions recorded?\nHow are disagreements resolved?",
  subSize: 12.5,
});
const coe = node(els, 350, 250, 200, 96, C.found, "CoE stub & RACI", { titleSize: 15, sub: "makes ownership\nconcrete", subSize: 12.5 });
const own = node(els, 610, 250, 200, 96, C.hero, "Ownership", { titleSize: 15, sub: "named sponsor +\ngovernance lead", subSize: 12.5 });
const backlog = node(els, 870, 250, 210, 96, C.start, "Implementation backlog", { titleSize: 15, sub: "owners · decisions\nfollow-up actions", subSize: 12 });

connect(els, om, coe, { stroke: C.found.st });
connect(els, coe, own, { stroke: C.found.st });
connect(els, own, backlog, { stroke: C.hero.st });

const routes = [
  ["S1 · Identity", C.identity],
  ["S2 · Purview evidence", C.data],
  ["S3 · Platform owner", C.found],
  ["S4 / S6 · Validation", C.eval],
  ["Customer change process", C.neutral],
];
const rx = 1200, rw = 250, rh = 58, gap = 16;
const total = routes.length * rh + (routes.length - 1) * gap;
let ry = backlog.cy - total / 2;
routes.forEach(([label, color]) => {
  const r = node(els, rx, ry, rw, rh, color, label, { titleSize: 14 });
  els.push(arrow(backlog.r, backlog.cy, r.x, r.cy, { stroke: color.st, curved: false }));
  ry += rh + gap;
});

write(new URL("./s0-operating-model-handoff.excalidraw", import.meta.url).pathname, els);
