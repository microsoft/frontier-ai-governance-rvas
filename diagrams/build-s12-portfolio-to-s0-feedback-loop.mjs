// S12 - Portfolio decision package: review card -> lineage -> scorecard -> prioritization -> roadmap/baseline.
import { C, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];

els.push(text(40, 24, 1500, "S12 · Portfolio decision package", C.hero, { size: 26, align: "left" }));
els.push(text(
  40,
  60,
  1500,
  "Portfolio governance is useful only when lineage, coverage limits, exception patterns, dependency clusters, prioritization, owner readiness, and baseline feedback are recorded.",
  C.neutral,
  { size: 14, align: "left" },
));

const card = node(els, 40, 150, 230, 120, C.hero, "Portfolio\nreview card", {
  titleSize: 15,
  sub: "population · period\nforum · owners",
  subSize: 12,
});

const lineage = node(els, 330, 140, 260, 140, C.indigo, "Source lineage +\ncoverage limits", {
  titleSize: 15,
  sub: "freshness · exclusions\nowner · safe reference",
  subSize: 12,
});

const scorecard = node(els, 650, 140, 260, 140, C.eval, "Portfolio\nscorecard", {
  titleSize: 15,
  sub: "coverage · risk · assurance\nops · cost · maturity\nconfidence",
  subSize: 11.5,
});

const insights = node(els, 970, 90, 270, 110, C.amber, "Exception\nconcentration", {
  titleSize: 15,
  sub: "owner · domain · expiry\nrecurrence · escalation",
  subSize: 11.5,
});

const deps = node(els, 970, 250, 270, 110, C.data, "Dependency\nclusters", {
  titleSize: 15,
  sub: "identity · gateway · model\ndata · telemetry · capacity",
  subSize: 11.5,
});

connect(els, card, lineage, { stroke: C.hero.st });
connect(els, lineage, scorecard, { stroke: C.indigo.st });
els.push(arrow(scorecard.r, scorecard.cy - 24, insights.x, insights.cy, { stroke: C.amber.st, curved: false }));
els.push(arrow(scorecard.r, scorecard.cy + 24, deps.x, deps.cy, { stroke: C.data.st, curved: false }));

const priority = node(els, 1305, 150, 260, 130, C.start, "Prioritization +\nroadmap action", {
  titleSize: 15,
  sub: "risk · value · cost\nowner readiness · target",
  subSize: 12,
});

els.push(arrow(insights.r, insights.cy, priority.x, priority.cy - 26, { stroke: C.start.st, curved: false }));
els.push(arrow(deps.r, deps.cy, priority.x, priority.cy + 26, { stroke: C.start.st, curved: false }));

const baseline = node(els, 1010, 450, 260, 110, C.found, "Next foundation\nbaseline question", {
  titleSize: 15,
  sub: "ownership · evidence\nrisk appetite · policy",
  subSize: 12,
});

const blocked = node(els, 40, 450, 320, 110, C.security, "Blocked / deferred gaps", {
  titleSize: 15,
  sub: "stale source · hidden exclusion\nno owner · no cost basis",
  subSize: 12,
});

const boundary = node(els, 420, 450, 470, 110, C.neutral, "Safe evidence boundary", {
  titleSize: 15,
  sub: "repository records references only · no exports, dashboards, telemetry, cost files, identifiers, policy state, funding approval, or certification",
  subSize: 11.2,
});

els.push(arrow(lineage.cx, lineage.b, blocked.cx, blocked.y, { stroke: C.security.st, curved: false, dashed: true }));
els.push(arrow(scorecard.cx, scorecard.b, boundary.cx, boundary.y, { stroke: C.neutral.st, curved: false, dashed: true, endArrowhead: null }));
els.push(arrow(priority.cx, priority.b, baseline.cx + 80, baseline.y, { stroke: C.found.st, curved: false }));

// Feedback loop: baseline questions return to the next portfolio review.
els.push(arrow(baseline.x, baseline.cy, card.cx, card.b, {
  stroke: C.hero.st,
  strokeWidth: 2,
  dashed: true,
  points: [[0, 0], [-250, 0], [-720, 0], [-855, -180]],
}));
els.push(text(670, 586, 300, "reassess selected questions", C.hero, { size: 13, align: "center" }));

write(new URL("./s12-portfolio-to-s0-feedback-loop.excalidraw", import.meta.url).pathname, els);
