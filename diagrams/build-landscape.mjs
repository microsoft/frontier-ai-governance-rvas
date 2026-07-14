// Landscape: Agent 365 control-plane hub; disciplines converge up; OP frames all.
import { C, rect, ellipse, text, labelIn, arrow, line, write } from "./lib.mjs";

const els = [];
const group = { bg: "#f8fafc", st: "#94a3b8", tx: "#475569" };

// ---- Title ----
els.push(text(150, 24, 1200, "Microsoft capabilities used across the AI Governance programme", C.found, { size: 27, align: "left" }));
els.push(text(150, 62, 1200, "Identity, data, security, evaluation, and testing records inform a shared governance view, anchored by an operating model.", C.neutral, { size: 15, align: "left" }));

// ---- Hero: Agent 365 (control plane) ----
const aX = 530, aY = 118, aW = 420, aH = 118, aBottom = aY + aH, aCx = aX + aW / 2;
els.push(rect(aX, aY, aW, aH, C.hero, { id: "a365" }));
els.push(text(aX, aY + 22, aW, "Microsoft Agent 365", C.hero, { size: 22 }));
els.push(text(aX, aY + 58, aW, "Control plane · Registry · Access · Visualization\nInteroperability · Security", C.hero, { size: 13 }));

// ---- Pillars ----
const py = 340;
// Identity
els.push(rect(150, py, 250, 178, C.identity, { id: "eid" }));
els.push(text(158, py + 22, 234, "Microsoft Entra Agent ID", C.identity, { size: 16 }));
els.push(text(158, py + 78, 234, "Blueprints · Agent identities\nConditional Access\nID Protection", C.identity, { size: 13 }));
// Data & Compliance
els.push(rect(430, py, 250, 178, C.data, { id: "pur" }));
els.push(text(438, py + 22, 234, "Microsoft Purview", C.data, { size: 16 }));
els.push(text(438, py + 70, 234, "DSPM for AI · DLP · IRM\nComm. Compliance\neDiscovery · Audit", C.data, { size: 13 }));

// Security group
els.push(rect(710, py, 270, 220, group, { id: "secg", strokeStyle: "dashed" }));
els.push(text(724, py + 12, 242, "Security Posture & Threats", group, { size: 13, align: "left" }));
els.push(rect(726, py + 42, 238, 80, C.security, { id: "def" }));
els.push(text(726, py + 56, 238, "Defender for Cloud", C.security, { size: 15 }));
els.push(text(726, py + 82, 238, "AI-SPM · AI Threat Protection", C.security, { size: 12.5 }));
els.push(rect(726, py + 134, 238, 74, C.amber, { id: "cs" }));
els.push(text(726, py + 146, 238, "Azure AI Content Safety", C.amber, { size: 14 }));
els.push(text(726, py + 170, 238, "Prompt Shields · Groundedness", C.amber, { size: 12 }));
// CS -> Defender
els.push(arrow(845, py + 134, 845, py + 122, { stroke: C.amber.st, strokeWidth: 2, curved: false }));

// Quality & Adversarial group
els.push(rect(1010, py, 320, 220, group, { id: "qualg", strokeStyle: "dashed" }));
els.push(text(1024, py + 12, 292, "Quality, Safety & Adversarial Testing", group, { size: 13, align: "left" }));
els.push(rect(1026, py + 42, 288, 80, C.eval, { id: "eval" }));
els.push(text(1026, py + 56, 288, "Microsoft Foundry Evaluations", C.eval, { size: 14.5 }));
els.push(text(1026, py + 82, 288, "azure-ai-evaluation SDK", C.eval, { size: 12.5 }));
els.push(rect(1026, py + 134, 288, 74, C.advers, { id: "rt" }));
els.push(text(1026, py + 146, 288, "AI Red Teaming Agent + PyRIT", C.advers, { size: 13.5 }));
els.push(text(1026, py + 170, 288, "ASR scorecards", C.advers, { size: 12.5 }));

// ---- Converging arrows into A365 bottom ----
els.push(arrow(275, py, 610, aBottom, { stroke: C.identity.st, strokeWidth: 2, curved: false }));
els.push(arrow(555, py, 700, aBottom, { stroke: C.data.st, strokeWidth: 2, curved: false }));
els.push(arrow(845, py + 42, 790, aBottom, { stroke: C.security.st, strokeWidth: 2, curved: false }));
els.push(arrow(1170, py, 880, aBottom, { stroke: C.advers.st, strokeWidth: 2, dashed: true, curved: false }));
els.push(text(960, 288, 90, "gates", C.advers, { size: 12, align: "left" }));

// ---- Operating Model foundation slab ----
const slabX = 150, slabW = 1180, slabY = 600, slabH = 80;
els.push(rect(slabX, slabY, slabW, slabH, C.found, { id: "op" }));
els.push(text(slabX, slabY + 16, slabW, "Operating Model", C.found, { size: 16 }));
els.push(text(slabX, slabY + 44, slabW, "CAF for AI · WAF for AI · AI Center of Excellence · Copilot Control System", C.neutral, { size: 13 }));


write(new URL("./landscape.excalidraw", import.meta.url).pathname, els);
