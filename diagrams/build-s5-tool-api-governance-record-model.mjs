// S5 — the publication record must hold four fields, then choose a system of record.
import { C, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S5 · The tool/API publication record and its system of record", C.indigo, { size: 25, align: "left" }));
els.push(text(40, 58, 1500, "Choose a system that can hold the candidate's discoverability, owner, version/lifecycle state, and exposure-control intent — without implying publication or runtime safety is approved.", C.neutral, { size: 14, align: "left" }));

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

const choose = node(els, 760, 260, 200, 100, C.indigo, "Choose the\nsystem of record", { titleSize: 15 });
connect(els, record, choose, { stroke: C.indigo.st });

const options = [
  ["API Center + APIM products", "Microsoft-centred record +\nexposure boundaries", C.data],
  ["Existing estate / catalog", "approved process carries\nS5 fields (map them)", C.neutral],
  ["Ad-hoc list / no registry", "gap or hold state →\nbacklog a controlled model", C.amber],
];
const ox = 1010, ow = 300, oh = 90, og = 24;
let oy = choose.cy - (options.length * oh + (options.length - 1) * og) / 2;
options.forEach(([t, s, color]) => {
  const o = node(els, ox, oy, ow, oh, color, t, { titleSize: 14, sub: s, subSize: 11.5 });
  els.push(arrow(choose.r, choose.cy, o.x, o.cy, { stroke: color.st, curved: false }));
  oy += oh + og;
});

write(new URL("./s5-tool-api-governance-record-model.excalidraw", import.meta.url).pathname, els);
