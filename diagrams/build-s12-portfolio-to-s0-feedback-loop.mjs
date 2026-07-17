// S12 — the portfolio roadmap feeds the next S0 baseline, closing the improvement loop.
import { C, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S12 · Continuous improvement closes through S0", C.hero, { size: 26, align: "left" }));
els.push(text(40, 60, 1500, "Portfolio governance turns prior-session records and exception patterns into ranked decisions and a roadmap backlog — which feeds the next S0 assessment rather than replacing it.", C.neutral, { size: 14, align: "left" }));

const records = node(els, 40, 210, 240, 96, C.indigo, "Prior session records", { titleSize: 14, sub: "references · scope\ncoverage limits · gaps", subSize: 12 });
const exceptions = node(els, 40, 340, 240, 96, C.amber, "Exceptions & portfolio risks", { titleSize: 13.5, sub: "concentrations & shared\ndependencies", subSize: 12 });

const review = node(els, 350, 250, 250, 150, C.hero, "Portfolio review", {
  titleSize: 16,
  sub: "investment priorities\nmaturity movement\npolicy questions",
  subSize: 12,
});
connect(els, records, review, { stroke: C.indigo.st });
connect(els, exceptions, review, { stroke: C.amber.st });

const dispositions = node(els, 670, 255, 230, 140, C.indigo, "Decisions, deferrals &\nremaining-risk dispositions", { titleSize: 14 });
const roadmap = node(els, 970, 270, 200, 110, C.start, "Roadmap backlog", { titleSize: 15 });
const s0 = node(els, 1240, 260, 220, 120, C.found, "Next S0 assessment", { titleSize: 15, sub: "reassess selected domains\nwith fresh evidence", subSize: 11.5 });

connect(els, review, dispositions, { stroke: C.hero.st });
connect(els, dispositions, roadmap, { stroke: C.indigo.st });
connect(els, roadmap, s0, { stroke: C.start.st });

// feedback loop: S0 back to portfolio review (routed above the row)
const loopY = 150;
const dxLoop = review.cx - s0.cx;
els.push(arrow(s0.cx, s0.y, review.cx, review.y, {
  stroke: C.hero.st, strokeWidth: 2, dashed: true,
  points: [[0, 0], [0, loopY - s0.y], [dxLoop, loopY - s0.y], [dxLoop, review.y - s0.y]],
}));
els.push(text((review.cx + s0.cx) / 2 - 150, loopY - 40, 300, "continuous improvement loop", C.hero, { size: 13, align: "center" }));

write(new URL("./s12-portfolio-to-s0-feedback-loop.excalidraw", import.meta.url).pathname, els);
