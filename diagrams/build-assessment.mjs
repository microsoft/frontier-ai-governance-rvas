// Assessment fan-out: scorecard.csv -> score.py -> {per-domain, overall, roadmap}
import { C, rect, ellipse, text, labelIn, arrow, line, write } from "./lib.mjs";

const dark = { bg: "#1e293b", st: "#0f172a", tx: "#e2e8f0" };
const els = [];

// ---- Title ----
els.push(text(60, 24, 900, "How the readiness score is produced", C.found, { size: 26, align: "left" }));
els.push(text(60, 60, 900, "Fill one instrument, run one script, get a prioritized roadmap.", C.neutral, { size: 15, align: "left" }));

// ---- Input: scorecard.csv (ellipse = input/source) ----
els.push(ellipse(60, 190, 210, 90, C.start, { id: "input" }));
els.push(labelIn(60, 190, 210, 90, "scorecard.csv\n(1–4 per question)", C.start, { size: 16 }));

// evidence artifact: sample rows
els.push(rect(55, 315, 230, 132, dark, { id: "csv" }));
els.push(text(70, 328, 210,
  "domain,domain_name,…,weight,score\nD0,Operating model,…,2,3\nD1,Identity & access,…,2,2\nD2,Data & compliance,…,2,2\n… 7 domains × ~3 questions", dark,
  { size: 11.5, align: "left", family: 3 }));
els.push(line(165, 280, 165, 315, { dashed: true, stroke: "#94a3b8", curved: false }));

// ---- Process: score.py ----
els.push(rect(390, 200, 170, 72, C.indigo, { id: "proc" }));
els.push(labelIn(390, 200, 170, 72, "score.py", C.indigo, { size: 19 }));
els.push(text(390, 278, 170, "computes maturity", C.neutral, { size: 12 }));

// input -> process
els.push(arrow(270, 235, 390, 236, { stroke: C.start.st, strokeWidth: 2 }));

// ---- Outputs (fan-out) ----
els.push(rect(700, 96, 250, 66, C.eval, { id: "out1" }));
els.push(labelIn(700, 96, 250, 66, "Per-domain maturity", C.eval, { size: 16 }));

els.push(rect(700, 200, 250, 66, C.data, { id: "out2" }));
els.push(labelIn(700, 200, 250, 66, "Overall maturity", C.data, { size: 16 }));

els.push(rect(700, 304, 250, 78, C.start, { id: "out3" }));
els.push(labelIn(700, 304, 250, 78, "Prioritized roadmap\n(which sessions first)", C.start, { size: 16 }));

// fan-out arrows
els.push(arrow(560, 226, 700, 129, { stroke: C.eval.st, points: [[0, 0], [70, 0], [140, -97]] }));
els.push(arrow(560, 236, 700, 233, { stroke: C.data.st, strokeWidth: 2 }));
els.push(arrow(560, 246, 700, 343, { stroke: C.start.st, points: [[0, 0], [70, 0], [140, 97]] }));

// roadmap evidence artifact
els.push(rect(700, 412, 470, 118, dark, { id: "road" }));
els.push(text(716, 424, 450,
  "Prioritized roadmap (lowest maturity first):\n  1. S2 Data & Compliance  (maturity 2.00, gap 2.00)  ← start here\n  2. S1 Identity & Access  (maturity 2.00, gap 2.00)\n  3. S3 Security Posture & Runtime  (maturity 2.33)\n  …", dark,
  { size: 11, align: "left", family: 3 }));
els.push(arrow(825, 382, 825, 412, { stroke: C.start.st, strokeWidth: 2, curved: false }));

write(new URL("./assessment.excalidraw", import.meta.url).pathname, els);
