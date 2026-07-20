// S3 — the AI gateway as a platform trust boundary between callers and AI services.
import { C, rect, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S3 · The AI gateway as a platform trust boundary", C.found, { size: 26, align: "left" }));
els.push(text(40, 60, 1500, "An illustrative Azure pattern: optional gateway, orchestration or hosted execution, private data access, identity, and observability layers. A design remains an assumption until later sessions evidence it.", C.neutral, { size: 14, align: "left" }));

const caller = node(els, 40, 250, 180, 100, C.start, "Caller", { titleSize: 16, sub: "person or workload", subSize: 12.5 });

// boundary frame around the gateway
els.push(rect(300, 170, 300, 270, { bg: "#eef2ff", st: C.found.st, tx: C.found.tx }, { strokeStyle: "dashed", roundness: { type: 3 } }));
els.push(text(316, 182, 270, "Platform trust boundary", C.found, { size: 14, align: "left" }));
const gw = node(els, 330, 240, 240, 130, C.indigo, "AI gateway", {
  titleSize: 16,
  sub: "authn · authz · routing\nthrottling · logging · policy\n(Azure API Management)",
  subSize: 12,
});

const svc = node(els, 700, 250, 220, 110, C.found, "Orchestration /\nhosted execution", { titleSize: 15, sub: "models · agents · tools", subSize: 12 });
const data = node(els, 700, 430, 220, 86, C.data, "Private data access", { titleSize: 14, sub: "endpoint + DNS when selected", subSize: 11.5 });
const monitor = node(els, 1000, 430, 240, 86, C.eval, "Observability", { titleSize: 14, sub: "correlation · coverage · retention", subSize: 11.5 });

connect(els, caller, gw, { stroke: C.start.st });
connect(els, gw, svc, { stroke: C.indigo.st });
connect(els, svc, data, { stroke: C.data.st });
els.push(arrow(svc.r, svc.cy, monitor.x, monitor.cy, { stroke: C.eval.st, dashed: true, curved: false, endArrowhead: null }));

// attached boundary concerns (owners / evidence), not inside the workload
const attachments = [
  ["Private connectivity", "endpoint / DNS option"],
  ["Hybrid dependencies", "identity · logging · IR"],
  ["Identity boundary", "who starts the action"],
  ["Telemetry coverage", "not operating proof"],
];
let ax = 40;
attachments.forEach(([t, s]) => {
  const a = node(els, ax, 570, 220, 78, C.neutral, t, { titleSize: 13.5, sub: s, subSize: 11.5 });
  els.push(arrow(a.cx, a.y, gw.cx, gw.b, { stroke: C.neutral.st, curved: false, dashed: true, endArrowhead: null }));
  ax += 236;
});

// platform-security owner accountable for the boundary
const owner = node(els, 1000, 250, 240, 110, C.hero, "Platform-security owner", { titleSize: 14, sub: "owns selected boundaries;\nS6 later reviews evidence", subSize: 11.5 });
els.push(arrow(gw.r, gw.cy, owner.x, owner.cy, { stroke: C.hero.st, curved: false, dashed: true, endArrowhead: null }));

write(new URL("./s3-gateway-trust-boundary.excalidraw", import.meta.url).pathname, els);
