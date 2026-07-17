// S4 — classify a candidate by authority; the highest-impact action sets the admission bar.
import { C, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S4 · Classification is about authority — the highest-impact action sets the bar", C.eval, { size: 24, align: "left" }));
els.push(text(40, 58, 1500, "Classify a candidate by what it is meant to do, not its label. Each archetype raises the minimum admission focus. Unclear authority = unclassified → do not admit.", C.neutral, { size: 14, align: "left" }));

const candidate = node(els, 40, 250, 210, 110, C.hero, "Agent candidate", { titleSize: 16, sub: "classify by intended\nauthority", subSize: 12.5 });

const tiers = [
  ["Advisory assistant", "purpose · audience · limits\naccountable owner", C.eval],
  ["Human-confirmed action", "confirmation point · approver\naction traceability · test evidence", C.eval],
  ["Bounded delegated-action", "authority & tool inventory · safeguards\nexception path · negative testing", C.eval],
  ["Coordinating agent", "+ orchestration boundary · dependency map\nescalation · recovery · per-path evidence", C.eval],
];
const tx = 340, tw = 340, th = 88, gap = 20;
let ty = 150;
const nodes = [];
tiers.forEach(([t, s], i) => {
  const n = node(els, tx, ty, tw, th, C.eval, t, { titleSize: 15, sub: s, subSize: 11.5 });
  nodes.push(n);
  els.push(arrow(candidate.r, candidate.cy, n.x, n.cy, { stroke: C.eval.st, curved: false }));
  ty += th + gap;
});

// rising-bar label
els.push(text(tx + tw + 30, 150, 260, "↑ minimum admission focus rises\nwith the highest-impact action", C.neutral, { size: 13, align: "left" }));

// unclassified stop
const unc = node(els, 40, 470, 210, 80, C.advers, "Unclassified", { titleSize: 15, sub: "authority unclear → do not admit", subSize: 11.5 });
connect(els, candidate, unc, { stroke: C.advers.st, dashed: true });

write(new URL("./s4-authority-admission-tree.excalidraw", import.meta.url).pathname, els);
