// S9 — read-only reconciliation of many records into findings and a lifecycle backlog.
import { C, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S9 · Reconciliation keeps gaps visible", C.indigo, { size: 26, align: "left" }));
els.push(text(40, 60, 1500, "S9 compares explicit identity identifiers across records (never inferring matches). Disagreements become findings for accountable owners and route to the customer steward or change process.", C.neutral, { size: 14, align: "left" }));

const sources = [
  "Agent registry / Agent 365 view",
  "Entra Agent ID records",
  "API Center / gateway records",
  "Platform telemetry",
  "Approved lifecycle / change-review",
];
const sx = 40, sw = 250, sh = 60, sg = 14;
let sy = 150;
const sn = [];
sources.forEach((s) => {
  sn.push(node(els, sx, sy, sw, sh, C.data, s, { titleSize: 13 }));
  sy += sh + sg;
});

const reconcile = node(els, 350, 250, 210, 150, C.indigo, "Reconciliation", { titleSize: 15, sub: "compare explicit\nidentity identifiers\n(no name inference)", subSize: 12 });
sn.forEach((n) => els.push(arrow(n.r, n.cy, reconcile.x, reconcile.cy, { stroke: C.data.st, curved: false })));

const findings = node(els, 620, 210, 300, 230, C.amber, "Findings", {
  titleSize: 15,
  sub: "unmatched identities\ncatalog-only entries\nmissing owners\ninvalid lifecycle states\nunreviewed material changes\nincomplete closure records",
  subSize: 12,
});
connect(els, reconcile, findings, { stroke: C.indigo.st });

const steward = node(els, 980, 250, 210, 110, C.hero, "Customer steward /\nchange process", { titleSize: 14, sub: "owns the fix", subSize: 12 });
const backlog = node(els, 1250, 250, 200, 110, C.start, "Lifecycle backlog", { titleSize: 15 });
connect(els, findings, steward, { stroke: C.amber.st });
connect(els, steward, backlog, { stroke: C.hero.st });

write(new URL("./s9-reconciliation-gap-flow.excalidraw", import.meta.url).pathname, els);
