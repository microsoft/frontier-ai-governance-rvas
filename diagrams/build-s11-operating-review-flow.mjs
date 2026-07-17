// S11 — signals become an operating decision only with coverage and ownership.
import { C, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S11 · An operating review turns evidence into a decision", C.data, { size: 26, align: "left" }));
els.push(text(40, 60, 1500, "Signals matter only when the population and period are stated and someone owns the interpretation. An excluded population is a coverage limit, not a zero result or a pass.", C.neutral, { size: 14, align: "left" }));

const sources = [
  ["Foundry observability", "traces · tokens · latency · eval scores", C.data],
  ["OpenTelemetry · App Insights", "TTFT/TTFB · p95 · throughput · errors", C.data],
  ["Population & review period", "what the evidence covers", C.neutral],
];
const sx = 40, sw = 300, sh = 84, sg = 20;
let sy = 150;
const sn = [];
sources.forEach(([t, s, color]) => {
  sn.push(node(els, sx, sy, sw, sh, color, t, { titleSize: 14, sub: s, subSize: 11.5 }));
  sy += sh + sg;
});

const review = node(els, 420, 190, 250, 170, C.eval, "Operating review", {
  titleSize: 16,
  sub: "population · review period\ncoverage limit\naccountable owner\n+ decision per question",
  subSize: 12,
});
sn.forEach((n) => els.push(arrow(n.r, n.cy, review.x, review.cy, { stroke: n === sn[2] ? C.neutral.st : C.data.st, curved: false })));

const coverage = node(els, 420, 430, 250, 70, C.amber, "Coverage limit ≠ zero result", { titleSize: 13.5, sub: "blocks over-reading the evidence", subSize: 11.5 });
els.push(arrow(coverage.cx, coverage.y, review.cx, review.b, { stroke: C.amber.st, curved: false, dashed: true, endArrowhead: null }));

const decision = node(els, 740, 175, 220, 90, C.start, "Operating decision", { titleSize: 15, sub: "per selected question", subSize: 12 });
const drift = node(els, 740, 300, 220, 90, C.amber, "Drift hypothesis", { titleSize: 15, sub: "vs S7 baseline — not confirmed drift", subSize: 11.5 });
connect(els, review, decision, { stroke: C.eval.st });
connect(els, review, drift, { stroke: C.eval.st });

const routes = ["Accountable owner", "Validation reference", "Exception / escalation route"];
const rx = 1030, rw = 240, rh = 64, rg = 18;
let ry = drift.cy - (routes.length * rh + (routes.length - 1) * rg) / 2;
routes.forEach((t) => {
  const r = node(els, rx, ry, rw, rh, C.neutral, t, { titleSize: 13.5 });
  els.push(arrow(drift.r, drift.cy, r.x, r.cy, { stroke: C.neutral.st, curved: false }));
  ry += rh + rg;
});

write(new URL("./s11-operating-review-flow.excalidraw", import.meta.url).pathname, els);
