// Governance journey: agents-built -> S1..S6 rising pipeline, framed by S0, iterating.
import { C, rect, ellipse, text, labelIn, arrow, line, write } from "./lib.mjs";

const els = [];

// ---- Title ----
els.push(text(40, 24, 1200, "The governance stack you implement — session by session", C.found, { size: 27, align: "left" }));
els.push(text(40, 62, 1200, "Agents you build climb an identity → data → security → evaluation → control pipeline, framed by an operating model and re-scored each loop.", C.neutral, { size: 15, align: "left" }));

// ---- Input (where agents are built) ----
const inX = 40, inY = 361, inW = 220, inH = 128;
els.push(ellipse(inX, inY, inW, inH, C.start, { id: "built" }));
els.push(text(inX, inY + 30, inW, "Where agents are built", C.start, { size: 15 }));
els.push(text(inX, inY + 56, inW, "Copilot Studio · Foundry\nSDK · 3rd-party", C.start, { size: 12.5 }));

// ---- Rising pipeline S1..S6 ----
const stages = [
  { tag: "S1 · Identity", tech: "Entra Agent ID", c: C.identity },
  { tag: "S2 · Data & Compliance", tech: "Purview", c: C.data },
  { tag: "S3 · Security & Runtime", tech: "Defender +\nContent Safety", c: C.security },
  { tag: "S4 · Evaluation", tech: "Foundry evals", c: C.eval },
  { tag: "S5 · Adversarial Testing", tech: "PyRIT ·\nRed Teaming Agent", c: C.advers },
  { tag: "S6 · Control Plane", tech: "Agent 365 +\nCopilot Control System", c: C.hero },
];
const bW = 214, bH = 114, stepX = 240, x0 = 320, yBase = 360, rise = 22;
const box = [];
stages.forEach((s, i) => {
  const x = x0 + i * stepX;
  const y = yBase - i * rise;
  box.push({ x, y, cx: x + bW / 2, cy: y + bH / 2 });
  els.push(rect(x, y, bW, bH, s.c, { id: "s" + (i + 1) }));
  els.push(text(x + 6, y + 20, bW - 12, s.tag, s.c, { size: 15 }));
  const techLines = s.tech.split("\n").length;
  els.push(text(x + 6, y + 52, bW - 12, s.tech, s.c, { size: 12.5 }));
});

// input -> S1
els.push(arrow(inX + inW, inY + inH / 2, box[0].x, box[0].cy, { stroke: C.start.st, strokeWidth: 2 }));
// stage -> stage (rising)
for (let i = 0; i < box.length - 1; i++) {
  els.push(arrow(box[i].x + bW, box[i].cy, box[i + 1].x, box[i + 1].cy,
    { stroke: stages[i + 1].c.st, strokeWidth: 2, curved: false }));
}

// ---- Foundation slab (S0) ----
const slabX = box[0].x, slabW = box[5].x + bW - box[0].x, slabY = 508, slabH = 76;
els.push(rect(slabX, slabY, slabW, slabH, C.found, { id: "s0" }));
els.push(text(slabX, slabY + 16, slabW, "S0 · Foundations & Operating Model", C.found, { size: 16 }));
els.push(text(slabX, slabY + 42, slabW, "CAF for AI · AI Center of Excellence · Readiness Assessment", C.neutral, { size: 13 }));

// frames arrow: slab -> S1 (dashed, upward)
els.push(arrow(box[0].cx, slabY, box[0].cx, box[0].y + bH, { stroke: C.found.st, strokeWidth: 2, dashed: true, curved: false }));
els.push(text(box[0].cx - 78, (slabY + box[0].y + bH) / 2 - 9, 70, "frames", C.found, { size: 12, align: "right" }));

// ---- Iterate feedback arc: S6 -> S4 (over the top) ----
const s6 = box[5], s4 = box[3], apex = 130;
els.push(arrow(s6.cx, s6.y, s4.cx, s4.y, {
  stroke: C.hero.st, strokeWidth: 2, dashed: true,
  points: [[0, 0], [0, -apex], [s4.cx - s6.cx, -apex], [s4.cx - s6.cx, s4.y - s6.y]],
}));
els.push(text((s4.cx + s6.cx) / 2 - 40, Math.min(s4.y, s6.y) - apex + 16, 120, "iterate", C.hero, { size: 13 }));

write(new URL("./journey.excalidraw", import.meta.url).pathname, els);
