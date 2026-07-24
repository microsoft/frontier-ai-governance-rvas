// S4 — classify a candidate by authority; the highest-impact action sets the admission bar.
import { C, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 760, "S4 · Set the admission bar by authority", C.eval, { size: 24, align: "left" }));
els.push(text(40, 58, 760, "Classify what the agent can do. Unclear authority? Do not admit.", C.neutral, { size: 14, align: "left" }));

const candidate = node(els, 40, 220, 190, 100, C.hero, "Agent candidate", { titleSize: 16, sub: "what can it do?", subSize: 12.5 });

const tiers = [
  ["Advisory assistant", "purpose · limits · owner", C.eval],
  ["Human-confirmed action", "confirm · approve · trace", C.eval],
  ["Bounded action agent", "allowed tools · safeguards · tests", C.eval],
  ["Coordinating agent", "orchestration · recovery · evidence", C.eval],
];
const tx = 300, tw = 300, th = 76, gap = 12;
let ty = 130;
const nodes = [];
tiers.forEach(([t, s], i) => {
  const n = node(els, tx, ty, tw, th, C.eval, t, { titleSize: 15, sub: s, subSize: 11.5 });
  nodes.push(n);
  els.push(arrow(candidate.r, candidate.cy, n.x, n.cy, { stroke: C.eval.st, curved: false }));
  ty += th + gap;
});

// rising-bar label
els.push(text(tx + tw + 20, 130, 180, "More impact =\nmore evidence", C.neutral, { size: 13, align: "left" }));

// unclassified stop
const unc = node(els, 40, 370, 190, 72, C.advers, "Unclassified", { titleSize: 15, sub: "unclear → do not admit", subSize: 11.5 });
connect(els, candidate, unc, { stroke: C.advers.st, dashed: true });

write(new URL("./s4-authority-admission-tree.excalidraw", import.meta.url).pathname, els);
