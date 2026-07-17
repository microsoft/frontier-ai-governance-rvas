// S8 — Attack Success Rate is a decision aid: above tolerance -> remediation, below -> supports scope.
import { C, text, node, connect, diamond, labelIn, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S8 · Attack Success Rate is a decision aid", C.advers, { size: 26, align: "left" }));
els.push(text(40, 60, 1500, "ASR only makes sense with its category, sample size, target version, and approved threshold. Above tolerance becomes a remediation item; below tolerance supports the tested scope.", C.neutral, { size: 14, align: "left" }));

// setup chain across the top
const chain = [
  "Target",
  "Attack\ncategories",
  "Sample\nsize",
  "Target\nversion",
  "Approved\nthreshold",
];
let cx = 40;
const cn = [];
chain.forEach((t) => {
  cn.push(node(els, cx, 150, 170, 84, C.advers, t, { titleSize: 14 }));
  cx += 194;
});
for (let i = 0; i < cn.length - 1; i++) connect(els, cn[i], cn[i + 1], { stroke: C.advers.st });

// attempts -> ASR
const attempts = node(els, 40, 320, 200, 90, C.advers, "Authorized attempts", { titleSize: 14, sub: "on a non-prod endpoint", subSize: 12 });
const dx = 320, dy = 300, dw = 210, dh = 130;
els.push(diamond(dx, dy, dw, dh, C.advers));
els.push(labelIn(dx, dy, dw, dh, "Attack Success\nRate vs threshold", C.advers, { size: 14 }));
const asr = { x: dx, y: dy, w: dw, h: dh, cx: dx + dw / 2, cy: dy + dh / 2, r: dx + dw, b: dy + dh };
connect(els, attempts, asr, { stroke: C.advers.st });
els.push(arrow(cn[2].cx, cn[2].b, asr.cx, asr.y, { stroke: C.advers.st, curved: false, dashed: true, endArrowhead: null }));

const above = node(els, 600, 250, 260, 90, C.amber, "Above tolerance", { titleSize: 15, sub: "remediation item with an owner", subSize: 12 });
const below = node(els, 600, 390, 260, 90, C.start, "Below tolerance", { titleSize: 15, sub: "supports the tested scope only", subSize: 12 });
els.push(arrow(asr.r, asr.cy - 12, above.x, above.cy, { stroke: C.amber.st, curved: false }));
els.push(arrow(asr.r, asr.cy + 12, below.x, below.cy, { stroke: C.start.st, curved: false }));

// native scorecard -> optional comparison sidecar
const native = node(els, 950, 250, 230, 90, C.neutral, "Foundry native scorecard", { titleSize: 14, sub: "preserved unchanged", subSize: 12 });
const sidecar = node(els, 950, 390, 230, 90, C.neutral, "Comparison sidecar", { titleSize: 14, sub: "optional · references native", subSize: 12 });
connect(els, native, sidecar, { stroke: C.neutral.st, dashed: true });

write(new URL("./s8-red-teaming-asr-decision.excalidraw", import.meta.url).pathname, els);
