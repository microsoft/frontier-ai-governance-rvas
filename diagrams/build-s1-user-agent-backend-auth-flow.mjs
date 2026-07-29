// S1 — user-initiated agent flow with delegated authority and gateway proof boundary.
import { C, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S1 - User to agent to backend authentication flow", C.identity, { size: 26, align: "left" }));
els.push(text(40, 60, 1500, "Record user authority, agent identity, gateway validation, backend authorization, and correlation separately.", C.neutral, { size: 14, align: "left" }));

const user = node(els, 50, 260, 160, 90, C.start, "User", { titleSize: 16, sub: "corporate identity", subSize: 12 });
const idp = node(els, 50, 105, 160, 90, C.identity, "Identity provider", { titleSize: 14, sub: "issues user token", subSize: 12 });
const apim1 = node(els, 300, 240, 230, 130, C.indigo, "Gateway entry", { titleSize: 15, sub: "validate JWT\nquota · policy\ncorrelation ID", subSize: 12 });
const agent = node(els, 620, 240, 220, 130, C.hero, "Agent runtime", { titleSize: 15, sub: "OBO or scoped action\nagent identity record", subSize: 12 });
const apim2 = node(els, 930, 240, 230, 130, C.indigo, "Backend gateway", { titleSize: 15, sub: "validate caller\npolicy · telemetry", subSize: 12 });
const backend = node(els, 1250, 260, 170, 90, C.data, "Backend API", { titleSize: 15, sub: "RBAC / scopes", subSize: 12 });
const audit = node(els, 620, 470, 220, 90, C.eval, "Telemetry", { titleSize: 15, sub: "user · agent · route\noperation ID", subSize: 12 });

connect(els, idp, user, { stroke: C.identity.st });
connect(els, user, apim1, { stroke: C.start.st });
connect(els, apim1, agent, { stroke: C.indigo.st });
connect(els, agent, apim2, { stroke: C.hero.st });
connect(els, apim2, backend, { stroke: C.indigo.st });
els.push(arrow(apim1.cx, apim1.b, audit.x, audit.cy, { stroke: C.eval.st, dashed: true, curved: false, endArrowhead: null }));
els.push(arrow(agent.cx, agent.b, audit.cx, audit.y, { stroke: C.eval.st, dashed: true, curved: false, endArrowhead: null }));
els.push(arrow(apim2.cx, apim2.b, audit.r, audit.cy, { stroke: C.eval.st, dashed: true, curved: false, endArrowhead: null }));

els.push(text(300, 385, 230, "Invalid token or scope -> deny closed", C.security, { size: 12, align: "center" }));
els.push(text(930, 385, 230, "Out-of-scope backend call -> deny closed", C.security, { size: 12, align: "center" }));

write(new URL("./s1-user-agent-backend-auth-flow.excalidraw", import.meta.url).pathname, els);
