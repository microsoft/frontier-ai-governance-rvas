// S1 — autonomous agent app-only flow with managed identity/federation and gateway route.
import { C, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S1 - Autonomous agent to backend authentication flow", C.identity, { size: 26, align: "left" }));
els.push(text(40, 60, 1500, "App-only authority needs its own sponsor, non-secret credential path, least-privilege scope, and disable route.", C.neutral, { size: 14, align: "left" }));

const trigger = node(els, 50, 260, 170, 90, C.start, "Trigger", { titleSize: 15, sub: "timer · event · job", subSize: 12 });
const host = node(els, 290, 240, 220, 130, C.found, "Agent host", { titleSize: 15, sub: "managed identity\nor federation", subSize: 12 });
const entra = node(els, 580, 210, 240, 90, C.identity, "Entra token exchange", { titleSize: 15, sub: "blueprint / credential path", subSize: 12 });
const agentId = node(els, 580, 370, 240, 90, C.identity, "Agent identity", { titleSize: 15, sub: "app-only actor\nsponsor + lifecycle", subSize: 12 });
const apim = node(els, 910, 240, 230, 130, C.indigo, "Gateway route", { titleSize: 15, sub: "auth · quota · policy\ntelemetry", subSize: 12 });
const backend = node(els, 1230, 260, 180, 90, C.data, "Target API", { titleSize: 15, sub: "RBAC / app scope", subSize: 12 });
const audit = node(els, 910, 470, 230, 90, C.eval, "Audit and disable route", { titleSize: 14, sub: "sign-in · policy\nRBAC · gateway", subSize: 12 });

connect(els, trigger, host, { stroke: C.start.st });
connect(els, host, entra, { stroke: C.found.st });
connect(els, entra, agentId, { stroke: C.identity.st });
connect(els, agentId, apim, { stroke: C.identity.st });
connect(els, apim, backend, { stroke: C.indigo.st });
els.push(arrow(agentId.cx, agentId.b, audit.x, audit.cy, { stroke: C.eval.st, dashed: true, curved: false, endArrowhead: null }));
els.push(arrow(apim.cx, apim.b, audit.cx, audit.y, { stroke: C.eval.st, dashed: true, curved: false, endArrowhead: null }));

els.push(text(290, 385, 220, "No stored secret by default", C.start, { size: 12, align: "center" }));
els.push(text(1230, 370, 180, "Denied if scope or RBAC is missing", C.security, { size: 12, align: "center" }));

write(new URL("./s1-autonomous-agent-backend-auth-flow.excalidraw", import.meta.url).pathname, els);
