// S8 - Authorized red-team remediation package: ROE -> method -> finding -> remediation -> retest.
import { C, text, node, connect, diamond, labelIn, arrow, write } from "./lib.mjs";

const els = [];

els.push(text(40, 24, 1500, "S8 · Authorized red-team remediation package", C.advers, { size: 26, align: "left" }));
els.push(text(
  40,
  60,
  1500,
  "Evidence is scoped to the authorized target, category, method, threshold, finding owner, remediation path, and retest closure. Scorecards and run records stay in customer systems.",
  C.neutral,
  { size: 14, align: "left" },
));

const roe = node(els, 40, 150, 210, 100, C.advers, "Authorized target\n+ ROE", {
  titleSize: 15,
  sub: "non-prod · owners · stop conditions",
  subSize: 12,
});
const method = node(els, 310, 150, 220, 100, C.advers, "Category +\nmethod route", {
  titleSize: 15,
  sub: "AI Red Teaming Agent · PyRIT · manual",
  subSize: 12,
});
const evidence = node(els, 590, 150, 230, 100, C.neutral, "Native scorecard\nor run reference", {
  titleSize: 15,
  sub: "preserved externally",
  subSize: 12,
});

connect(els, roe, method, { stroke: C.advers.st });
connect(els, method, evidence, { stroke: C.advers.st });

const dx = 880, dy = 130, dw = 240, dh = 140;
els.push(diamond(dx, dy, dw, dh, C.advers));
els.push(labelIn(dx, dy, dw, dh, "ASR / qualitative\nresult vs threshold", C.advers, { size: 14 }));
const threshold = { x: dx, y: dy, w: dw, h: dh, cx: dx + dw / 2, cy: dy + dh / 2, r: dx + dw, b: dy + dh };
connect(els, evidence, threshold, { stroke: C.advers.st });

const finding = node(els, 1190, 90, 260, 96, C.amber, "Above tolerance\nor severity finding", {
  titleSize: 15,
  sub: "category · technique · affected route",
  subSize: 12,
});
const scoped = node(els, 1190, 230, 260, 96, C.start, "Below tolerance", {
  titleSize: 15,
  sub: "supports tested scope only",
  subSize: 12,
});
els.push(arrow(threshold.r, threshold.cy - 22, finding.x, finding.cy, { stroke: C.amber.st, curved: false }));
els.push(arrow(threshold.r, threshold.cy + 22, scoped.x, scoped.cy, { stroke: C.start.st, curved: false }));

const remediation = node(els, 1190, 410, 260, 110, C.amber, "Remediation owner\n+ control surface", {
  titleSize: 15,
  sub: "Prompt Shields · gateway · tool · data · SOC",
  subSize: 12,
});
connect(els, finding, remediation, { stroke: C.amber.st });

const retest = node(els, 880, 430, 240, 100, C.start, "Retest closure", {
  titleSize: 15,
  sub: "same category · evidence accepted",
  subSize: 12,
});
connect(els, remediation, retest, { stroke: C.start.st });
els.push(arrow(retest.x, retest.cy, evidence.cx, evidence.b, { stroke: C.start.st, curved: true, dashed: true }));

const blocked = node(els, 40, 410, 250, 110, C.security, "Blocked / route", {
  titleSize: 15,
  sub: "missing ROE · unsupported target · production request",
  subSize: 12,
});
els.push(arrow(roe.cx, roe.b, blocked.cx, blocked.y, { stroke: C.security.st, curved: false, dashed: true }));
els.push(arrow(method.cx, method.b, blocked.r, blocked.cy, { stroke: C.security.st, curved: true, dashed: true }));

const boundary = node(els, 360, 420, 400, 100, C.neutral, "Safe evidence boundary", {
  titleSize: 15,
  sub: "repository records references only · no prompts, outputs, payloads, scorecards, or production claims",
  subSize: 12,
});
connect(els, evidence, boundary, { stroke: C.neutral.st, dashed: true });

write(new URL("./s8-red-teaming-asr-decision.excalidraw", import.meta.url).pathname, els);
