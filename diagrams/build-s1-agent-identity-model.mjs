// S1 — agent identity object model vs the separate runtime-access boundary.
import { C, rect, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S1 · Agent identity, its sponsor, and the separate runtime boundary", C.identity, { size: 26, align: "left" }));
els.push(text(40, 60, 1500, "Entra Agent ID gives an agent a governable identity in the tenant; a human sponsor is accountable. Gateway/Conditional Access guard runtime access — you often need both.", C.neutral, { size: 14, align: "left" }));

// identity-plane frame
els.push(rect(24, 200, 900, 240, { bg: "#eef2ff", st: C.identity.st, tx: C.identity.tx }, { strokeStyle: "dashed", roundness: { type: 3 } }));
els.push(text(40, 212, 860, "Tenant identity plane — Microsoft Entra Agent ID", C.identity, { size: 14, align: "left" }));

// object chain: blueprint -> blueprint principal -> agent identity -> agent user account
const chain = ["Blueprint", "Blueprint\nprincipal", "Agent\nidentity", "Agent user\naccount"];
const boxes = [];
let cx = 44;
chain.forEach((label, i) => {
  const b = node(els, cx, 300, 190, 96, C.identity, label, { titleSize: 15 });
  boxes.push(b);
  cx += 214;
});
for (let i = 0; i < boxes.length - 1; i++) connect(els, boxes[i], boxes[i + 1], { stroke: C.identity.st });

// human sponsor accountable for the agent identity
const sponsor = node(els, boxes[2].x, 100, 190, 74, C.hero, "Human sponsor", { titleSize: 14, sub: "accountable · lifecycle", subSize: 12 });
connect(els, sponsor, boxes[2], { stroke: C.hero.st });

// runtime-access frame
els.push(rect(960, 200, 520, 240, { bg: "#fef2f2", st: C.security.st, tx: C.security.tx }, { strokeStyle: "dashed", roundness: { type: 3 } }));
els.push(text(976, 212, 500, "Runtime access controls — gateway boundary", C.security, { size: 14, align: "left" }));
const ca = node(els, 984, 300, 232, 96, C.security, "Conditional Access", { titleSize: 14, sub: "for workload identities", subSize: 12 });
const gw = node(els, 1236, 300, 232, 96, C.security, "Gateway authentication", { titleSize: 14, sub: "JWT at API Management", subSize: 12 });

// note that the two planes are separate but complementary
els.push(text(930, 350, 30, "≠", C.neutral, { size: 26 }));

// OBO recorded as a gap
const obo = node(els, boxes[2].x - 40, 480, 320, 84, C.amber, "On-behalf-of (OBO)", { titleSize: 14, sub: "can appear in telemetry without its\nown Agent ID → recorded as a gap", subSize: 12 });
connect(els, boxes[3], obo, { stroke: C.amber.st, dashed: true });

write(new URL("./s1-agent-identity-model.excalidraw", import.meta.url).pathname, els);
