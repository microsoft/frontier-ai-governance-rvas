// S12 — the portfolio roadmap feeds the next S0 baseline, closing the improvement loop.
import { C, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1000, "S12 · Portfolio review feeds the next baseline", C.hero, { size: 26, align: "left" }));
els.push(text(40, 60, 1260, "Review records and risks, set priorities, then update the roadmap.", C.neutral, { size: 14, align: "left" }));

const records = node(els, 40, 170, 240, 86, C.indigo, "Portfolio records", { titleSize: 14, sub: "scope · coverage · gaps", subSize: 12 });
const exceptions = node(els, 40, 285, 240, 86, C.amber, "Exceptions & risks", { titleSize: 13.5, sub: "shared dependencies", subSize: 12 });

const review = node(els, 350, 200, 250, 130, C.hero, "Portfolio review", {
  titleSize: 16,
  sub: "investment priorities\nmaturity movement\npolicy questions",
  subSize: 12,
});
connect(els, records, review, { stroke: C.indigo.st });
connect(els, exceptions, review, { stroke: C.amber.st });

const dispositions = node(els, 670, 205, 230, 120, C.indigo, "Decisions, deferrals &\nremaining risk", { titleSize: 14 });
const roadmap = node(els, 970, 215, 200, 100, C.start, "Roadmap backlog", { titleSize: 15 });
const s0 = node(els, 1240, 205, 220, 110, C.found, "Next baseline review", { titleSize: 15, sub: "fresh evidence for\nselected domains", subSize: 11.5 });

connect(els, review, dispositions, { stroke: C.hero.st });
connect(els, dispositions, roadmap, { stroke: C.indigo.st });
connect(els, roadmap, s0, { stroke: C.start.st });

// feedback loop: S0 back to portfolio review (routed above the row)
const loopY = 115;
const dxLoop = review.cx - s0.cx;
els.push(arrow(s0.cx, s0.y, review.cx, review.y, {
  stroke: C.hero.st, strokeWidth: 2, dashed: true,
  points: [[0, 0], [0, loopY - s0.y], [dxLoop, loopY - s0.y], [dxLoop, review.y - s0.y]],
}));
els.push(text((review.cx + s0.cx) / 2 - 120, loopY - 28, 240, "review and improve", C.hero, { size: 13, align: "center" }));

write(new URL("./s12-portfolio-to-s0-feedback-loop.excalidraw", import.meta.url).pathname, els);
