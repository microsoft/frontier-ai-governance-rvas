// Governance journey: S0 baseline -> domain work -> S6 reconciliation -> owned backlog.
import { C, rect, ellipse, text, labelIn, arrow, line, write } from "./lib.mjs";

const els = [];

// ---- Title ----
els.push(text(40, 24, 1100, "How the curriculum turns a baseline into owned work", C.found, { size: 27, align: "left" }));
els.push(text(40, 62, 1200, "Start with S0, choose the reviews that fit, and assign the resulting work to named owners.", C.neutral, { size: 15, align: "left" }));

// ---- Input: the customer starts with a known situation, not a blank slate ----
const inX = 40, inY = 180, inW = 220, inH = 128;
els.push(ellipse(inX, inY, inW, inH, C.start, { id: "starting-point" }));
els.push(text(inX, inY + 30, inW, "Customer starting point", C.start, { size: 15 }));
els.push(text(inX, inY + 56, inW, "Agents · owners · evidence\npriorities · platform path", C.start, { size: 12.5 }));

// ---- S0 establishes the foundation before priority domain work ----
const s0X = 320, s0Y = 160, s0W = 220, s0H = 122;
els.push(rect(s0X, s0Y, s0W, s0H, C.found, { id: "s0" }));
els.push(text(s0X + 8, s0Y + 22, s0W - 16, "S0 · Foundations", C.found, { size: 16 }));
els.push(text(s0X + 8, s0Y + 54, s0W - 16, "Owners · baseline\nprioritised session plan", C.found, { size: 12.5 }));
els.push(arrow(inX + inW, inY + inH / 2, s0X, s0Y + s0H / 2, { stroke: C.start.st, strokeWidth: 2 }));

// ---- S1-S5: evidence-producing governance work ----
const stages = [
  { tag: "S1 · Identity", tech: "Entra Agent ID", c: C.identity },
  { tag: "S2 · Data & Compliance", tech: "Purview", c: C.data },
  { tag: "S3 · Platform", tech: "Trust boundary", c: C.security },
  { tag: "S4 · Agent admission", tech: "Authority + owners", c: C.eval },
  { tag: "S5 · Tool/API governance", tech: "Publication record", c: C.advers },
];
const bW = 190, bH = 106, stepX = 210, x0 = 600, yBase = 190;
const box = [];
stages.forEach((s, i) => {
  const x = x0 + i * stepX;
  const y = yBase;
  box.push({ x, y, cx: x + bW / 2, cy: y + bH / 2 });
  els.push(rect(x, y, bW, bH, s.c, { id: "s" + (i + 1) }));
  els.push(text(x + 6, y + 20, bW - 12, s.tag, s.c, { size: 15 }));
  const techLines = s.tech.split("\n").length;
  els.push(text(x + 6, y + 52, bW - 12, s.tech, s.c, { size: 12.5 }));
});

els.push(arrow(s0X + s0W, s0Y + s0H / 2, box[0].x, box[0].cy, { stroke: C.found.st, strokeWidth: 2 }));
for (let i = 0; i < box.length - 1; i++) {
  els.push(arrow(box[i].x + bW, box[i].cy, box[i + 1].x, box[i + 1].cy,
    { stroke: stages[i + 1].c.st, strokeWidth: 2, curved: false }));
}

// ---- S6 makes the integrated record actionable ----
const s6X = 1670, s6Y = 160, s6W = 220, s6H = 122;
els.push(rect(s6X, s6Y, s6W, s6H, C.hero, { id: "s6" }));
els.push(text(s6X + 8, s6Y + 22, s6W - 16, "S6 · Runtime assurance", C.hero, { size: 16 }));
els.push(text(s6X + 8, s6Y + 54, s6W - 16, "Review the selected\nruntime path", C.hero, { size: 12.5 }));
els.push(arrow(box[4].x + bW, box[4].cy, s6X, s6Y + s6H / 2, { stroke: C.hero.st, strokeWidth: 2 }));

const outX = 1950, outY = 160, outW = 220, outH = 122;
els.push(ellipse(outX, outY, outW, outH, C.start, { id: "owned-backlog" }));
els.push(text(outX, outY + 30, outW, "Owned backlog", C.start, { size: 16 }));
els.push(text(outX, outY + 58, outW, "Evidence · decisions\nnext review", C.start, { size: 12.5 }));
els.push(arrow(s6X + s6W, s6Y + s6H / 2, outX, outY + outH / 2, { stroke: C.start.st, strokeWidth: 2 }));

// The backlog informs the next review cycle without suggesting every session is repeated.
const loopY = 110;
els.push(arrow(outX + outW / 2, outY, s0X + s0W / 2, s0Y, {
  stroke: C.hero.st, strokeWidth: 2, dashed: true,
  points: [[0, 0], [0, loopY - outY], [s0X + s0W / 2 - (outX + outW / 2), loopY - outY], [s0X + s0W / 2 - (outX + outW / 2), s0Y - outY]],
}));
els.push(text(1130, 88, 200, "Review and improve", C.hero, { size: 13 }));

write(new URL("./journey.excalidraw", import.meta.url).pathname, els);
