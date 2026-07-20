// S5 — the publication record must hold four fields, then choose a system of record.
import { C, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S5 · The tool/API publication record and its system of record", C.indigo, { size: 25, align: "left" }));
els.push(text(40, 58, 1500, "A publication record captures discoverability, owner, version/lifecycle, and exposure intent. Select a gateway, allow-list, or in-process tool boundary without implying publication or runtime safety is approved.", C.neutral, { size: 14, align: "left" }));

const fields = [
  "Discoverability",
  "Owner",
  "Version / lifecycle state",
  "Exposure-control intent",
];
const fx = 40, fw = 330, fh = 64, gap = 16;
let fy = 170;
const fnodes = [];
fields.forEach((f) => {
  fnodes.push(node(els, fx, fy, fw, fh, C.data, f, { titleSize: 14 }));
  fy += fh + gap;
});

const record = node(els, 440, 250, 250, 120, C.indigo, "Publication record", { titleSize: 16, sub: "must carry all four\nfields per candidate", subSize: 12.5 });
fnodes.forEach((n) => connect(els, n, record, { stroke: C.data.st }));

const choose = node(els, 760, 260, 200, 100, C.indigo, "Choose system of\nrecord + boundary", { titleSize: 15 });
connect(els, record, choose, { stroke: C.indigo.st });

const options = [
  ["Gateway-mediated route", "central auth · quota · telemetry\nfor published APIs or MCP", C.data],
  ["Vetted allow-list", "reviewed source + lifecycle\nwithout per-call context", C.neutral],
  ["In-process policy boundary", "pre-call allow / deny / approval\n→ S10 engineering decision", C.amber],
];
const ox = 1010, ow = 300, oh = 90, og = 24;
let oy = choose.cy - (options.length * oh + (options.length - 1) * og) / 2;
options.forEach(([t, s, color]) => {
  const o = node(els, ox, oy, ow, oh, color, t, { titleSize: 14, sub: s, subSize: 11.5 });
  els.push(arrow(choose.r, choose.cy, o.x, o.cy, { stroke: color.st, curved: false }));
  oy += oh + og;
});

write(new URL("./s5-tool-api-governance-record-model.excalidraw", import.meta.url).pathname, els);
