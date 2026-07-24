// S10 — three enforcement points and why a local hash chain is not tamper evidence.
import { C, rect, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 900, "S10 · In-process control needs its own evidence", C.security, { size: 24, align: "left" }));
els.push(text(40, 58, 900, "A gateway and an in-process check can work together. Neither proves the other.", C.neutral, { size: 14, align: "left" }));

const gateway = node(els, 40, 180, 210, 100, C.security, "Gateway boundary", { titleSize: 14, sub: "shared controls", subSize: 12 });

// agent application frame (in-process)
els.push(rect(300, 120, 560, 180, { bg: "#eef2ff", st: C.indigo.st, tx: C.indigo.tx }, { strokeStyle: "dashed", roundness: { type: 3 } }));
els.push(text(316, 132, 520, "Agent application", C.indigo, { size: 14, align: "left" }));
const govern = node(els, 330, 175, 240, 90, C.indigo, "govern() checks the tool call", { titleSize: 14, sub: "policy + audit · before it runs", subSize: 12 });
const tool = node(els, 610, 180, 220, 80, C.neutral, "Tool call", { titleSize: 14, sub: "a decision is not success", subSize: 11.5 });
connect(els, govern, tool, { stroke: C.indigo.st });
els.push(arrow(gateway.r, gateway.cy, 300, gateway.cy, { stroke: C.security.st, curved: false, dashed: true, endArrowhead: null }));

// evidence sub-flow
const hash = node(els, 330, 340, 240, 76, C.amber, "Local hash chain", { titleSize: 14, sub: "consistency only, not tamper evidence", subSize: 11.5 });
const signed = node(els, 610, 340, 250, 76, C.start, "Signed immutable record", { titleSize: 13.5, sub: "customer-owned tamper evidence", subSize: 11 });
els.push(arrow(govern.cx, govern.b, hash.cx, hash.y, { stroke: C.amber.st, curved: false }));
connect(els, hash, signed, { stroke: C.start.st });

write(new URL("./s10-policy-boundary-and-evidence.excalidraw", import.meta.url).pathname, els);
