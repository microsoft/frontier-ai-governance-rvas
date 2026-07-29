// S7 — evaluation evidence informs release readiness; diagnostic evidence stays separate.
import { C, text, node, connect, diamond, labelIn, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 980, "S7 · Evaluation evidence package", C.eval, { size: 26, align: "left" }));
els.push(text(40, 60, 1220, "Trace one candidate change through scenario evidence, evaluator route, baseline comparison, thresholds, and continue/hold handoff.", C.neutral, { size: 14, align: "left" }));

const runtime = node(els, 40, 140, 210, 92, C.security, "Runtime-path acceptance", {
  titleSize: 14,
  sub: "required for release reliance",
  subSize: 11.5,
});
const scenario = node(els, 300, 132, 210, 108, C.eval, "Scenario set", {
  titleSize: 15,
  sub: "version · owner\nincluded / excluded slices",
  subSize: 11.5,
});
const evaluator = node(els, 560, 132, 220, 108, C.hero, "Evaluator / rubric", {
  titleSize: 15,
  sub: "Foundry · agent evaluator\nmanual · CI/CD · load",
  subSize: 11.5,
});
const baseline = node(els, 830, 132, 220, 108, C.eval, "Baseline vs candidate", {
  titleSize: 15,
  sub: "comparison rule\nregression tolerance",
  subSize: 11.5,
});
const threshold = node(els, 1100, 132, 210, 108, C.amber, "Threshold interpretation", {
  titleSize: 14,
  sub: "customer-owned\nexception route",
  subSize: 11.5,
});

connect(els, runtime, scenario, { stroke: C.security.st });
connect(els, scenario, evaluator, { stroke: C.eval.st });
connect(els, evaluator, baseline, { stroke: C.hero.st });
connect(els, baseline, threshold, { stroke: C.eval.st });

const finding = node(els, 560, 320, 230, 92, C.neutral, "Finding-to-action map", {
  titleSize: 14,
  sub: "blocker · exception · backlog\noperating hypothesis",
  subSize: 11.5,
});
els.push(arrow(threshold.cx, threshold.b, finding.r, finding.cy, { stroke: C.amber.st, curved: true }));

const dx = 870, dy = 310, dw = 180, dh = 110;
els.push(diamond(dx, dy, dw, dh, C.hero));
els.push(labelIn(dx, dy, dw, dh, "Release\nhandoff", C.hero, { size: 15 }));
const decision = { x: dx, y: dy, w: dw, h: dh, cx: dx + dw / 2, cy: dy + dh / 2, r: dx + dw, b: dy + dh };
connect(els, finding, decision, { stroke: C.neutral.st });

const cont = node(els, 1120, 300, 180, 64, C.start, "continue", { titleSize: 15 });
const hold = node(els, 1120, 400, 180, 64, C.amber, "hold", { titleSize: 15 });
els.push(arrow(decision.r, decision.cy - 12, cont.x, cont.cy, { stroke: C.start.st, curved: false }));
els.push(arrow(decision.r, decision.cy + 12, hold.x, hold.cy, { stroke: C.amber.st, curved: false }));

const diagnostic = node(els, 40, 330, 300, 90, C.neutral, "Diagnostic-only path", {
  titleSize: 14,
  sub: "missing runtime/platform prerequisite\nuse for backlog, not release reliance",
  subSize: 11.5,
});
els.push(arrow(runtime.cx, runtime.b, diagnostic.cx, diagnostic.y, {
  stroke: C.neutral.st,
  curved: false,
  dashed: true,
  endArrowhead: "arrow",
}));
els.push(arrow(diagnostic.r, diagnostic.cy, finding.x, finding.cy, {
  stroke: C.neutral.st,
  curved: false,
  dashed: true,
  endArrowhead: "arrow",
}));

write(new URL("./s7-evaluation-release-handoff.excalidraw", import.meta.url).pathname, els);
