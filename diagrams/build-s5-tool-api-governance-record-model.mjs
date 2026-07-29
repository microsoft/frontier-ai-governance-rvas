// S5 — trace the tool call before admitting or withdrawing a tool/API route.
import { C, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S5 · Tool/API admission package", C.indigo, { size: 25, align: "left" }));
els.push(text(40, 58, 1500, "Trace one consumer through identity, route, operation, audit, and withdrawal. The package supports admission decisions without implying publication, runtime proof, or production approval.", C.neutral, { size: 14, align: "left" }));

const rowY = 180;
const cards = [
  ["Consumer", "agent · app · workflow\nowner · environment", C.data],
  ["Identity contract", "Entra app · MI · OBO\nJWT audience · scopes", C.indigo],
  ["Catalog / route", "API Center · APIM\nconnector · MCP · allow-list", C.data],
  ["Operation boundary", "allowed actions · data class\nblocked operations", C.amber],
  ["Audit + correlation", "diagnostics · log owner\nrequest/tool/agent join fields", C.indigo],
  ["Withdrawal path", "disable · revoke · unpublish\nrotate · notify · verify", C.amber],
];

const nodes = [];
let x = 40;
cards.forEach(([title, sub, color]) => {
  const n = node(els, x, rowY, 190, 112, color, title, { titleSize: 14, sub, subSize: 11.5 });
  nodes.push(n);
  x += 220;
});
for (let i = 0; i < nodes.length - 1; i += 1) {
  els.push(arrow(nodes[i].r, nodes[i].cy, nodes[i + 1].x, nodes[i + 1].cy, { stroke: C.indigo.st, curved: false }));
}

const decision = node(els, 410, 380, 430, 108, C.indigo, "Admission decision", {
  titleSize: 16,
  sub: "approve · defer · reject · route · withdraw · block",
  subSize: 12.5,
});
nodes.forEach((n) => connect(els, n, decision, { stroke: C.neutral.st, dashed: true }));

const blockers = node(els, 40, 535, 410, 120, C.amber, "Hard stops", {
  titleSize: 15,
  sub: "unknown caller · unbounded write/admin authority · no audit · no quota · no owner · no revocation path",
  subSize: 12,
});
const handoff = node(els, 885, 535, 420, 120, C.data, "Customer handoff", {
  titleSize: 15,
  sub: "platform · identity · connector/MCP · runtime · evaluation · catalog · release · operations",
  subSize: 12,
});
els.push(arrow(blockers.r, blockers.cy, decision.x, decision.cy, { stroke: C.amber.st, curved: false }));
els.push(arrow(decision.r, decision.cy, handoff.x, handoff.cy, { stroke: C.data.st, curved: false }));

write(new URL("./s5-tool-api-governance-record-model.excalidraw", import.meta.url).pathname, els);
