// Reference Azure agent platform pattern for the platform technical guide.
import { C, rect, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "Azure agent platform reference pattern", C.found, { size: 26, align: "left" }));
els.push(text(40, 60, 1500, "A planning view for S3, S5, S6, and S10. It names reviewable planes and evidence routes; it is not proof of a deployed topology.", C.neutral, { size: 14, align: "left" }));

els.push(rect(40, 108, 1320, 92, { bg: "#eef2ff", st: C.identity.st, tx: C.identity.tx }, { strokeStyle: "dashed", roundness: { type: 3 } }));
els.push(text(58, 122, 1280, "Identity plane: user identity · host workload identity · agent identity · delegated authority · resource authorization", C.identity, { size: 16, align: "left" }));

const caller = node(els, 60, 292, 170, 92, C.start, "Caller", { titleSize: 15, sub: "user or workload", subSize: 12 });
const gateway = node(els, 300, 258, 220, 160, C.indigo, "Entry and governance", { titleSize: 15, sub: "APIM gateway\nJWT · quota · safety\nlogs · routing", subSize: 12 });
const orchestration = node(els, 590, 238, 230, 110, C.hero, "Orchestration", { titleSize: 15, sub: "Foundry agents\nmodels · tools", subSize: 12 });
const execution = node(els, 590, 408, 230, 110, C.found, "Execution", { titleSize: 15, sub: "custom agent host\napps · functions", subSize: 12 });
const data = node(els, 900, 298, 230, 130, C.data, "Data services", { titleSize: 15, sub: "search · storage\nDB · documents\nPrivate Endpoint", subSize: 12 });
const catalog = node(els, 1180, 450, 160, 130, C.amber, "Catalog", { titleSize: 15, sub: "API Center\nlifecycle\nowners", subSize: 12 });

connect(els, caller, gateway, { stroke: C.start.st });
connect(els, gateway, orchestration, { stroke: C.indigo.st });
connect(els, gateway, execution, { stroke: C.indigo.st });
connect(els, orchestration, data, { stroke: C.data.st });
connect(els, execution, data, { stroke: C.data.st });
connect(els, gateway, catalog, { stroke: C.amber.st, dashed: true });

els.push(rect(40, 600, 1320, 110, { bg: "#f5f3ff", st: C.eval.st, tx: C.eval.tx }, { strokeStyle: "dashed", roundness: { type: 3 } }));
els.push(text(58, 616, 1280, "Observability plane: correlation IDs · traces · token metrics · safety events · cost signals · retention/export owner", C.eval, { size: 16, align: "left" }));
for (const n of [gateway, orchestration, execution, data]) {
  els.push(arrow(n.cx, n.b, n.cx, 600, { stroke: C.eval.st, dashed: true, curved: false, endArrowhead: null }));
}

write(new URL("./azure-agent-platform-reference.excalidraw", import.meta.url).pathname, els);
