// S2 — the compliance plane: discovery -> controls -> evidence, with gateway masking alongside.
import { C, rect, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S2 · The compliance plane: discovery to controls to evidence", C.data, { size: 26, align: "left" }));
els.push(text(40, 60, 1500, "Microsoft Purview answers which data reaches the agent, which sensitive data appears, and which evidence remains. DSPM finds exposure before enforcement; gateway masking complements it.", C.neutral, { size: 14, align: "left" }));

const dspm = node(els, 40, 240, 220, 110, C.data, "DSPM for AI", { titleSize: 16, sub: "diagnostic: surfaces\noversharing & exposure", subSize: 12.5 });
const findings = node(els, 320, 250, 180, 90, C.data, "Prioritised\nfindings", { titleSize: 15 });

// controls fan (labels + DLP)
const labels = node(els, 560, 176, 240, 84, C.data, "Sensitivity labels", { titleSize: 14, sub: "how data is handled", subSize: 12 });
const dlp = node(els, 560, 300, 240, 84, C.data, "DLP policies", { titleSize: 14, sub: "conditions govern sharing/use", subSize: 12 });

// investigation evidence trail
const invest = node(els, 860, 176, 250, 130, C.indigo, "Evidence trail", {
  titleSize: 15,
  sub: "Audit · eDiscovery\nInsider Risk Mgmt\nCommunication Compliance",
  subSize: 12,
});
const controls = node(els, 860, 340, 250, 60, C.indigo, "Customer compliance\n& change process", { titleSize: 13 });

connect(els, dspm, findings, { stroke: C.data.st });
connect(els, findings, labels, { stroke: C.data.st });
connect(els, findings, dlp, { stroke: C.data.st });
connect(els, dlp, invest, { stroke: C.data.st });
connect(els, labels, invest, { stroke: C.data.st });
connect(els, invest, controls, { stroke: C.indigo.st });

// gateway masking complements, does not replace
const gw = node(els, 320, 430, 480, 76, C.security, "Gateway masking (AI Hub Gateway / Citadel)", {
  titleSize: 14,
  sub: "runtime PII masking complements, but does not replace, Purview",
  subSize: 12,
});
els.push(arrow(gw.cx, gw.y, dlp.cx, dlp.b, { stroke: C.security.st, curved: false, dashed: true, endArrowhead: null }));

write(new URL("./s2-compliance-flow.excalidraw", import.meta.url).pathname, els);
