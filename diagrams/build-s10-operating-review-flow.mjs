// S10 - Operating review package: review card -> coverage -> correlation/retention -> routes -> validation/recurrence.
import { C, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S10 · Operating review package", C.data, { size: 26, align: "left" }));
els.push(text(
  40,
  60,
  1500,
  "Operating evidence becomes useful only when the review card, signal coverage, correlation, retention, ownership, validation, and recurrence are recorded. Coverage limits are not passes.",
  C.neutral,
  { size: 14, align: "left" },
));

const card = node(els, 40, 160, 240, 110, C.data, "Operating\nreview card", {
  titleSize: 15,
  sub: "workload · period\npopulation · owners",
  subSize: 12,
});
const coverage = node(els, 340, 150, 260, 130, C.eval, "Signal coverage", {
  titleSize: 15,
  sub: "usage · quality · safety\nlatency · errors · cost\ncapacity · feedback",
  subSize: 12,
});
const correlation = node(els, 660, 150, 260, 130, C.amber, "Correlation +\nretention contract", {
  titleSize: 15,
  sub: "join method · blind spots\nquery owner · safe refs",
  subSize: 12,
});
connect(els, card, coverage, { stroke: C.data.st });
connect(els, coverage, correlation, { stroke: C.eval.st });

const routes = [
  ["Alert / response route", "threshold owner · SOC/action group\nsuppression review", C.indigo],
  ["FinOps / capacity route", "allocation rule · budget owner\nquota / PTU owner", C.hero],
  ["Drift hypothesis route", "signal change · evidence limits\nobservation plan", C.amber],
];
const rx = 990, rw = 270, rh = 88, rg = 24;
let ry = 100;
const routeNodes = [];
routes.forEach(([t, s, color]) => {
  const r = node(els, rx, ry, rw, rh, color, t, { titleSize: 14.5, sub: s, subSize: 11.5 });
  routeNodes.push(r);
  els.push(arrow(correlation.r, correlation.cy, r.x, r.cy, { stroke: color.st, curved: false }));
  ry += rh + rg;
});

const validation = node(els, 1320, 180, 230, 110, C.start, "Validation +\nrecurrence backlog", {
  titleSize: 15,
  sub: "reviewer accepts evidence\nnext review trigger",
  subSize: 12,
});
routeNodes.forEach((r) => els.push(arrow(r.r, r.cy, validation.x, validation.cy, { stroke: C.start.st, curved: false })));

const gap = node(els, 340, 420, 280, 90, C.security, "Coverage gap", {
  titleSize: 15,
  sub: "missing · sampled · planned\nunavailable · excluded",
  subSize: 12,
});
els.push(arrow(coverage.cx, coverage.b, gap.cx, gap.y, { stroke: C.security.st, curved: false, dashed: true }));

const boundary = node(els, 700, 420, 500, 90, C.neutral, "Safe evidence boundary", {
  titleSize: 15,
  sub: "repository records references only · no telemetry, exports, dashboards, incident payloads, cost exports, or production claims",
  subSize: 12,
});
els.push(arrow(correlation.cx, correlation.b, boundary.cx, boundary.y, { stroke: C.neutral.st, curved: false, dashed: true, endArrowhead: null }));

write(new URL("./s10-operating-review-flow.excalidraw", import.meta.url).pathname, els);
