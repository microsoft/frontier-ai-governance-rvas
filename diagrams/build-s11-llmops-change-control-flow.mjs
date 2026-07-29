// S11 - LLMOps change control package: change card -> lifecycle artifacts -> manifest -> rollout/feedback.
import { C, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];

els.push(text(40, 24, 1500, "S11 · LLMOps change control package", C.hero, { size: 26, align: "left" }));
els.push(text(
  40,
  60,
  1500,
  "A bounded LLMOps change becomes actionable when artifact versions, evidence references, rollout authority, fallback, rollback, feedback governance, and automation prerequisites are recorded.",
  C.neutral,
  { size: 14, align: "left" },
));

const change = node(els, 40, 150, 230, 120, C.hero, "LLMOps\nchange card", {
  titleSize: 15,
  sub: "change type · owners\ntarget process · stop condition",
  subSize: 12,
});

const lifecycle = node(els, 330, 135, 270, 150, C.indigo, "Seven-stage\nlifecycle package", {
  titleSize: 15,
  sub: "data · experiment · evaluation\nvalidate/deploy · inference\nmonitor · feedback",
  subSize: 11.5,
});

const versions = node(els, 660, 135, 260, 150, C.eval, "Artifact version\ncontracts", {
  titleSize: 15,
  sub: "prompt · retrieval · tools\nmodel · dataset · rubric\nalias · feedback",
  subSize: 11.5,
});

const manifest = node(els, 980, 150, 260, 120, C.amber, "Release manifest", {
  titleSize: 15,
  sub: "safe references only\nrollback target · approver",
  subSize: 12,
});

connect(els, change, lifecycle, { stroke: C.hero.st });
connect(els, lifecycle, versions, { stroke: C.indigo.st });
connect(els, versions, manifest, { stroke: C.eval.st });

const rollout = node(els, 1300, 90, 260, 110, C.start, "Rollout / fallback /\nrollback authority", {
  titleSize: 14.5,
  sub: "stage · population · signal\nstop · fallback · rollback",
  subSize: 11.5,
});

const automation = node(els, 1300, 250, 260, 110, C.data, "Automation\nreadiness", {
  titleSize: 15,
  sub: "trigger · evidence · owner\nmanual override",
  subSize: 11.5,
});

els.push(arrow(manifest.r, manifest.cy - 22, rollout.x, rollout.cy, { stroke: C.start.st, curved: false }));
els.push(arrow(manifest.r, manifest.cy + 22, automation.x, automation.cy, { stroke: C.data.st, curved: false }));

const feedback = node(els, 650, 430, 300, 110, C.data, "Feedback-to-curation gate", {
  titleSize: 15,
  sub: "signal -> hypothesis -> curation\ncandidate input, not mutation",
  subSize: 12,
});

const blocked = node(els, 40, 430, 320, 110, C.security, "Blocked / deferred gaps", {
  titleSize: 15,
  sub: "missing owner · unversioned artifact\nno fallback · no stop condition",
  subSize: 12,
});

const boundary = node(els, 1040, 430, 520, 110, C.neutral, "Safe evidence boundary", {
  titleSize: 15,
  sub: "repository records references only · no prompts, outputs, datasets, telemetry, identifiers, live config, traffic moves, or production approval",
  subSize: 11.2,
});

els.push(arrow(lifecycle.cx, lifecycle.b, feedback.cx, feedback.y, { stroke: C.data.st, curved: false }));
els.push(arrow(feedback.x, feedback.cy, lifecycle.cx, lifecycle.b, {
  stroke: C.data.st,
  dashed: true,
  points: [[0, 0], [-160, 0], [-160, -120], [-185, -145]],
}));
els.push(arrow(change.cx, change.b, blocked.cx, blocked.y, { stroke: C.security.st, curved: false, dashed: true }));
els.push(arrow(manifest.cx, manifest.b, boundary.cx, boundary.y, { stroke: C.neutral.st, curved: false, dashed: true, endArrowhead: null }));
els.push(arrow(rollout.cx, rollout.b, boundary.cx + 140, boundary.y, { stroke: C.neutral.st, curved: false, dashed: true, endArrowhead: null }));
els.push(arrow(automation.cx, automation.b, boundary.cx + 190, boundary.y, { stroke: C.neutral.st, curved: false, dashed: true, endArrowhead: null }));

write(new URL("./s11-llmops-change-control-flow.excalidraw", import.meta.url).pathname, els);
