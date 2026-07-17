// S7 — evaluation informs the release decision but requires accepted S6 proof first.
import { C, text, node, connect, diamond, labelIn, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S7 · Evaluation informs release — it is not the sign-off", C.eval, { size: 26, align: "left" }));
els.push(text(40, 60, 1500, "S7 requires the accepted S6 gateway proof first. Foundry evaluations inform the decision; the assurance owner selects continue or hold, and the customer owns how it runs and enforces.", C.neutral, { size: 14, align: "left" }));

const gate = node(els, 40, 250, 220, 120, C.security, "Accepted S6 gateway proof", { titleSize: 15, sub: "required first —\ncondition to proceed", subSize: 12 });
const plan = node(els, 320, 240, 240, 140, C.eval, "Evaluation plan", {
  titleSize: 15,
  sub: "quality · groundedness\nsafety · tool use\nregression · human review",
  subSize: 12,
});
const owner = node(els, 620, 260, 210, 100, C.hero, "Assurance owner", { titleSize: 15, sub: "names scope & limits", subSize: 12 });

connect(els, gate, plan, { stroke: C.security.st });
connect(els, plan, owner, { stroke: C.eval.st });

// decision diamond
const dx = 890, dy = 250, dw = 180, dh = 120;
els.push(diamond(dx, dy, dw, dh, C.hero));
els.push(labelIn(dx, dy, dw, dh, "Decision", C.hero, { size: 15 }));
const dnode = { x: dx, y: dy, w: dw, h: dh, cx: dx + dw / 2, cy: dy + dh / 2, r: dx + dw, b: dy + dh };
connect(els, owner, dnode, { stroke: C.hero.st });

const cont = node(els, 1120, 200, 180, 74, C.start, "continue", { titleSize: 15 });
const hold = node(els, 1120, 320, 180, 74, C.amber, "hold", { titleSize: 15 });
els.push(arrow(dnode.r, dnode.cy - 10, cont.x, cont.cy, { stroke: C.start.st, curved: false }));
els.push(arrow(dnode.r, dnode.cy + 10, hold.x, hold.cy, { stroke: C.amber.st, curved: false }));

// evaluators inform, do not replace
const note = node(els, 320, 440, 510, 70, C.neutral, "Foundry evaluations & agent evaluators inform the decision", { titleSize: 13.5, sub: "a fixture result or proposed CI gate is not enough on its own", subSize: 11.5 });
els.push(arrow(note.cx, note.y, plan.cx, plan.b, { stroke: C.neutral.st, curved: false, dashed: true, endArrowhead: null }));

write(new URL("./s7-evaluation-release-handoff.excalidraw", import.meta.url).pathname, els);
