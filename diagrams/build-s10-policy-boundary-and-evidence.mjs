// S10 — three enforcement points and why a local hash chain is not tamper evidence.
import { C, rect, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S10 · A different enforcement point — and what counts as evidence", C.security, { size: 24, align: "left" }));
els.push(text(40, 58, 1500, "The gateway applies shared controls at the network boundary; an in-process govern() checks the tool action before it runs. Both can work together — one does not prove the other.", C.neutral, { size: 14, align: "left" }));

const gateway = node(els, 40, 250, 210, 120, C.security, "Network & API\ngateway boundary", { titleSize: 14, sub: "Citadel Governance Hub —\nshared controls", subSize: 12 });

// agent application frame (in-process)
els.push(rect(300, 180, 560, 200, { bg: "#eef2ff", st: C.indigo.st, tx: C.indigo.tx }, { strokeStyle: "dashed", roundness: { type: 3 } }));
els.push(text(316, 192, 520, "Agent application (in-process)", C.indigo, { size: 14, align: "left" }));
const govern = node(els, 330, 250, 240, 110, C.indigo, "govern() wraps the tool call", { titleSize: 14, sub: "policy evaluation + audit\nlog · before the tool runs", subSize: 12 });
const tool = node(els, 610, 258, 220, 94, C.neutral, "Tool call /\ndownstream action", { titleSize: 14, sub: "decision record ≠ success", subSize: 11.5 });
connect(els, govern, tool, { stroke: C.indigo.st });
els.push(arrow(gateway.r, gateway.cy, 300, gateway.cy, { stroke: C.security.st, curved: false, dashed: true, endArrowhead: null }));

// evidence sub-flow
const hash = node(els, 330, 440, 240, 84, C.amber, "Local hash chain", { titleSize: 14, sub: "internal consistency only —\nnot tamper evidence", subSize: 11.5 });
const signed = node(els, 610, 440, 250, 84, C.start, "Signed record in immutable\nexternal storage", { titleSize: 13.5, sub: "customer-owned = tamper evidence", subSize: 11 });
els.push(arrow(govern.cx, govern.b, hash.cx, hash.y, { stroke: C.amber.st, curved: false }));
connect(els, hash, signed, { stroke: C.start.st });

write(new URL("./s10-policy-boundary-and-evidence.excalidraw", import.meta.url).pathname, els);
