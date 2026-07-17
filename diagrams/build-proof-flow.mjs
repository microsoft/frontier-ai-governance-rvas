// Executive flow: ambition becomes scalable only when it is backed by evidence.
import { C, rect, ellipse, text, arrow, write } from "./lib.mjs";

const els = [];

els.push(text(36, 28, 748, "Scale AI with evidence, not assurances", C.hero, { size: 26, align: "left" }));
els.push(text(36, 66, 748, "A governed path turns strategic ambition into decisions leaders can stand behind.", C.neutral, { size: 14, align: "left" }));

const stages = [
  {
    title: "Ambition and use cases",
    detail: "Priorities, value, and the agents that matter",
    color: C.start,
    shape: "ellipse",
  },
  {
    title: "Accountable decisions",
    detail: "Owners, authority, scope, and risk choices",
    color: C.identity,
  },
  {
    title: "Enforceable controls",
    detail: "Platform, data, engineering, and runtime boundaries",
    color: C.data,
  },
  {
    title: "Evidence and observation",
    detail: "Assurance findings, operating signals, and exceptions",
    color: C.eval,
  },
  {
    title: "Portfolio learning",
    detail: "Priorities, remediation, and the next governance cycle",
    color: C.hero,
    shape: "ellipse",
  },
];

const x = 78;
const w = 664;
const h = 66;
const y0 = 128;
const gap = 23;

stages.forEach((stage, index) => {
  const y = y0 + index * (h + gap);
  const textInset = stage.shape === "ellipse" ? 72 : 24;
  const textWidth = w - textInset * 2;
  if (stage.shape === "ellipse") {
    els.push(ellipse(x, y, w, h, stage.color, { id: `proof-flow-${index}` }));
  } else {
    els.push(rect(x, y, w, h, stage.color, { id: `proof-flow-${index}` }));
  }
  els.push(text(x + textInset, y + 15, textWidth, stage.title, stage.color, { size: 16, align: "left" }));
  els.push(text(x + textInset, y + 38, textWidth, stage.detail, stage.color, { size: 12.5, align: "left" }));

  if (index < stages.length - 1) {
    els.push(arrow(x + w / 2, y + h, x + w / 2, y + h + gap, {
      stroke: stages[index + 1].color.st,
      strokeWidth: 2,
      curved: false,
    }));
  }
});

els.push(arrow(x + w - 16, y0 + (h + gap) * 4 + h / 2, x + w - 16, y0 + h / 2, {
  stroke: C.hero.st,
  strokeWidth: 1.5,
  dashed: true,
  points: [[0, 0], [52, 0], [52, -(h + gap) * 4], [0, -(h + gap) * 4]],
}));
els.push(text(570, 99, 172, "Learn and improve", C.hero, { size: 12, align: "right" }));

write(new URL("./proof-flow.excalidraw", import.meta.url).pathname, els);
