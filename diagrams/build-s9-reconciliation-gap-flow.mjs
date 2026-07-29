// S9 - Control-plane reconciliation package: population -> source map -> joins -> findings -> lifecycle -> closeout.
import { C, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S9 · Control-plane reconciliation package", C.indigo, { size: 26, align: "left" }));
els.push(text(
  40,
  60,
  1500,
  "S9 reconciles a bounded registry population using field-level sources of record and explicit join keys. Disagreements become owned findings and lifecycle backlog.",
  C.neutral,
  { size: 14, align: "left" },
));

const population = node(els, 40, 150, 230, 100, C.indigo, "Registry\npopulation card", {
  titleSize: 15,
  sub: "scope · included records\nsteward · cadence",
  subSize: 12,
});

const fieldMap = node(els, 330, 140, 260, 120, C.data, "Field-level\nsource-of-record map", {
  titleSize: 15,
  sub: "agent · identity · API/tool\nmodel · data · telemetry · lifecycle",
  subSize: 12,
});

const joinKeys = node(els, 660, 140, 240, 120, C.data, "Explicit join keys", {
  titleSize: 15,
  sub: "object ID · API ID · route ID\nFoundry ref · correlation key",
  subSize: 12,
});

connect(els, population, fieldMap, { stroke: C.indigo.st });
connect(els, fieldMap, joinKeys, { stroke: C.data.st });

const findings = node(els, 970, 110, 290, 180, C.amber, "Reconciliation\nfindings", {
  titleSize: 15,
  sub: "missing owner · stale version\norphan identity · route mismatch\ntelemetry gap · lifecycle conflict\nexception aging",
  subSize: 12,
});
connect(els, joinKeys, findings, { stroke: C.amber.st });

const lifecycle = node(els, 970, 390, 290, 120, C.hero, "Lifecycle +\nmaterial-change decision", {
  titleSize: 15,
  sub: "state · transition owner\nreview ref · reopen trigger",
  subSize: 12,
});
connect(els, findings, lifecycle, { stroke: C.hero.st });

const closeout = node(els, 1320, 140, 210, 110, C.start, "Close / close\nwith owned gaps", {
  titleSize: 15,
  sub: "owners · dates\nrecurrence checks",
  subSize: 12,
});
const blocked = node(els, 1320, 400, 210, 110, C.security, "Defer / route\n/ block", {
  titleSize: 15,
  sub: "no steward · no join key\nunsupported coverage",
  subSize: 12,
});
els.push(arrow(lifecycle.r, lifecycle.cy - 18, closeout.x, closeout.cy, { stroke: C.start.st, curved: true }));
els.push(arrow(lifecycle.r, lifecycle.cy + 18, blocked.x, blocked.cy, { stroke: C.security.st, curved: true }));

const safe = node(els, 330, 420, 480, 100, C.neutral, "Safe evidence boundary", {
  titleSize: 15,
  sub: "repository stores field shapes and references only · customer exports, object IDs, telemetry, config, and closure evidence stay in customer systems",
  subSize: 12,
});
els.push(arrow(fieldMap.cx, fieldMap.b, safe.cx, safe.y, { stroke: C.neutral.st, curved: false, dashed: true, endArrowhead: null }));
els.push(arrow(joinKeys.cx, joinKeys.b, safe.cx, safe.y, { stroke: C.neutral.st, curved: false, dashed: true, endArrowhead: null }));

write(new URL("./s9-reconciliation-gap-flow.excalidraw", import.meta.url).pathname, els);
