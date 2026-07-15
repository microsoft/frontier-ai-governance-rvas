#!/usr/bin/env node
/*
 * Generates a safe, customer-specific delivery workspace from non-sensitive
 * intake metadata. Customer evidence remains in the approved records system.
 */
'use strict';

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const REQUIRED_FIELDS = [
  'customer_slug',
  'engagement_id',
  'pilot_agent_slug',
  'governance_lead',
  'platform_lead',
  'target_environment_label',
];
const SLUG_FIELDS = new Set(['customer_slug', 'engagement_id', 'pilot_agent_slug', 'target_environment_label']);
const SLUG_RE = /^(?=.{1,80}$)[a-z0-9]+(?:-[a-z0-9]+)*$/;
const ROLE_RE = /^[A-Za-z0-9][A-Za-z0-9 ._-]{0,78}[A-Za-z0-9]$/;
const SENSITIVE_RE = /(?:https?:\/\/|password|secret|token|apikey|api_key|client_secret|subscription|tenant[_ -]?id|authorization|bearer|private[_ -]?key|access[_ -]?key|connection[_ -]?string|account[_ -]?key)/i;
const MANIFEST_NAME = '.rvas-workspace-manifest.json';

function usage() {
  return 'Usage: npm run generate-workspace -- --intake <intake.json> --out <workspace-directory>';
}

function parseArgs(argv) {
  const result = {};
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--help' || arg === '-h') {
      if (argv.length !== 1) throw new Error(usage());
      return { help: true };
    }
    if (arg === '--intake' || arg === '--out') {
      const key = arg.slice(2);
      const value = argv[index + 1];
      if (!value || value.startsWith('--')) throw new Error(`Argument ${arg} requires a value.\n${usage()}`);
      if (result[key]) throw new Error(`Argument ${arg} may only be specified once.`);
      result[key] = value;
      index += 1;
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  if (!result.intake || !result.out) throw new Error(usage());
  return result;
}

function readIntake(filePath) {
  let intake;
  try {
    intake = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch (error) {
    throw new Error(`Could not read intake JSON: ${error.message}`);
  }
  if (!intake || Array.isArray(intake) || typeof intake !== 'object') {
    throw new Error('Intake must be a JSON object.');
  }
  const actual = Object.keys(intake).sort();
  const expected = [...REQUIRED_FIELDS].sort();
  if (actual.join(',') !== expected.join(',')) {
    throw new Error(`Intake must contain exactly: ${REQUIRED_FIELDS.join(', ')}`);
  }
  for (const field of REQUIRED_FIELDS) {
    const value = intake[field];
    if (typeof value !== 'string' || !value.trim()) throw new Error(`Intake field ${field} must be a non-empty string.`);
    if (SENSITIVE_RE.test(value)) throw new Error(`Intake field ${field} contains a prohibited sensitive or tenant-specific value.`);
    const valid = SLUG_FIELDS.has(field) ? SLUG_RE.test(value) : ROLE_RE.test(value);
    if (!valid) throw new Error(`Intake field ${field} does not match the safe format defined in contracts/intake.schema.json.`);
  }
  return intake;
}

function hash(value) {
  return crypto.createHash('sha256').update(value).digest('hex');
}

function json(value) {
  return `${JSON.stringify(value, null, 2)}\n`;
}

function canonicalIntake(intake) {
  return Object.fromEntries(REQUIRED_FIELDS.map((field) => [field, intake[field]]));
}

function lstatIfExists(filePath) {
  try {
    return fs.lstatSync(filePath);
  } catch (error) {
    if (error.code === 'ENOENT') return null;
    throw error;
  }
}

function assertSafeDirectory(directory) {
  const stats = lstatIfExists(directory);
  if (!stats) return;
  if (stats.isSymbolicLink() || !stats.isDirectory()) {
    throw new Error(`Refusing unsafe workspace path: ${directory}`);
  }
}

function assertSafeFilePath(outputRoot, relativePath) {
  const parts = relativePath.split(path.sep);
  let directory = outputRoot;
  assertSafeDirectory(directory);
  for (const part of parts.slice(0, -1)) {
    directory = path.join(directory, part);
    assertSafeDirectory(directory);
  }
  const destination = path.join(directory, parts.at(-1));
  const stats = lstatIfExists(destination);
  if (stats && (!stats.isFile() || stats.isSymbolicLink())) {
    throw new Error(`Refusing unsafe workspace path: ${destination}`);
  }
  return destination;
}

function assertUnchangedOrMissing(outputRoot, relativePath, content) {
  const destination = assertSafeFilePath(outputRoot, relativePath);
  if (!fs.existsSync(destination)) return;
  if (fs.readFileSync(destination, 'utf8') !== content) {
    throw new Error(`Refusing to overwrite existing file: ${destination}`);
  }
}

function workspaceFiles(input) {
  const title = `${input.customer_slug} Agent Governance Delivery Workspace`;
  const pilot = input.pilot_agent_slug;
  const env = input.target_environment_label;
  const controls = {
    schema: 'rvas.delivery.control-register.v1',
    pilot_agent_slug: pilot,
    entries: [
      {
        control_id: 'gateway-proof',
        state: 'designed',
        owner: input.platform_lead,
        evidence_references: [],
        note: 'Hard exit gate: prove the representative non-production agent path through the approved gateway.',
        validation_reference: '',
        recurrence_review: '',
        exception_reference: ''
      }
    ]
  };
  const evidence = { schema: 'rvas.delivery.evidence-register.v1', entries: [] };
  const decisions = { schema: 'rvas.delivery.decision-register.v1', entries: [] };
  return {
    'README.md': `# ${title}\n\nThis workspace is the engagement control plane for **${pilot}** in **${env}**. It contains templates and references only; store customer identifiers, credentials, exports, logs, and evidence payloads in the approved customer records system.\n\n## Current exit gate\n\nThe programme cannot close until the representative non-production agent path has gateway-proof evidence and named owners have accepted the operating handoff. A production deployment is outside this workspace; the final output is a production-readiness decision package.\n\n## Start here\n\n1. Complete [mobilization](00-start-here/README.md).\n2. Run the [Platform Foundation](01-platform-foundation/README.md) and [Governance Controls](02-governance-controls/README.md) tracks in parallel.\n3. Complete [Assurance](03-assurance/README.md) after the gateway route is available.\n4. Close through [Operate](04-operate/README.md).\n\n| Role | Assigned lead |\n|---|---|\n| Governance | ${input.governance_lead} |\n| Platform | ${input.platform_lead} |\n\nGenerated from engagement \`${input.engagement_id}\`. Regeneration will not overwrite customer-authored files.\n`,
    '00-start-here/README.md': `# 00 · Start here\n\n## Mobilization gate\n\n- [ ] Delivery charter approved.\n- [ ] Pilot agent and non-production environment confirmed.\n- [ ] Governance and platform leads confirm the parallel workstream plan.\n- [ ] Customer records-system location and classification policy recorded as references only.\n- [ ] Blockers have an owner and review date.\n\nUse [engagement-charter.md](engagement-charter.md) to record the scope and [delivery-state.md](delivery-state.md) to track gates.\n`,
    '00-start-here/engagement-charter.md': `# Engagement charter\n\n| Field | Value |\n|---|---|\n| Customer | ${input.customer_slug} |\n| Engagement | ${input.engagement_id} |\n| Pilot agent | ${pilot} |\n| Target environment | ${env} |\n| Governance lead | ${input.governance_lead} |\n| Platform lead | ${input.platform_lead} |\n\n## Scope\n\nOne representative, customer-owned non-production agent path. Production promotion is explicitly out of scope; use the final readiness package for a separate customer change decision.\n`,
    '00-start-here/delivery-state.md': `# Delivery state\n\nUse only these states for a control: \`designed\`, \`report_only_deployed\`, \`observed\`, \`approved_for_enforcement\`, \`enforced\`, \`accepted_risk\`, or \`blocked\`.\n\nOffline fixtures and CI mocks are not delivery evidence and must not advance a control state.\n`,
    '01-platform-foundation/README.md': `# 01 · Platform Foundation\n\nThis workstream is co-delivered with the customer platform team. Install and upgrade the AI Hub Gateway/Citadel accelerator using its external guidance; this workspace records the delivery contract and proof references only.\n\n## Exit criteria\n\n- [ ] Gateway route, access contract, backend, and telemetry path are owned.\n- [ ] A non-production request from \`${pilot}\` traverses the gateway.\n- [ ] APIM request and telemetry references use the same correlation identifier.\n- [ ] Expected gateway policy behavior is evidenced.\n\nSee [gateway-proof-plan.md](gateway-proof-plan.md).\n`,
    '01-platform-foundation/gateway-proof-plan.md': `# Gateway proof plan\n\nCapture references—not evidence payloads—for gateway route, access contract, backend mapping, policy/version, request result, APIM request evidence, and telemetry evidence. Use a correlation identifier shared by the customer-operated smoke test and platform logs.\n\nA direct Content Safety check is a component test. It is not gateway proof.\n`,
    '02-governance-controls/README.md': `# 02 · Governance Controls\n\nRun identity, data, security, policy, and ownership work packages in parallel with Platform Foundation. Record each control in [control-register.json](control-register.json) and link evidence only through the approved customer records system.\n`,
    '02-governance-controls/control-register.json': json(controls),
    '03-assurance/README.md': `# 03 · Assurance\n\nDo not begin final assurance until Platform Foundation has a non-production gateway route. Run evaluation and authorized adversarial testing against the representative path, then record remediation decisions and evidence references in the operating registers.\n`,
    '04-operate/README.md': `# 04 · Operate\n\n## Formal handoff\n\n- [ ] Baseline-to-exit maturity comparison completed.\n- [ ] Evidence register reconciled.\n- [ ] Decision register has risk owners, approvers, and review dates.\n- [ ] Every open finding has a target date, validation reference, recurrence review, and exception or escalation reference where applicable.\n- [ ] Production-readiness package completed without promoting production.\n- [ ] 30/60/90 operating backlog accepted.\n\nUse [production-readiness-decision.md](production-readiness-decision.md) for the separate change-review decision.\n`,
    '04-operate/evidence-register.json': json(evidence),
    '04-operate/decision-register.json': json(decisions),
    '04-operate/production-readiness-decision.md': `# Production-readiness decision package\n\nThis is not a production deployment approval or change record.\n\n| Decision | Owner | Approver | Review by |\n|---|---|---|---|\n| ‹ready for separate change review / not ready / accepted risk› | ‹name› | ‹name› | ‹date› |\n\n## Required references\n\n- Gateway proof evidence manifest\n- Control-state register\n- Evaluation and authorized assurance results\n- Residual-risk register\n- Rollback and monitoring runbooks\n`,
    'evidence/README.md': `# Evidence references only\n\nDo not store customer logs, exports, screenshots, credentials, tenant details, or evidence payloads here. Register the approved customer records-system reference, classification, retention reference, capture time, and integrity reference in \`../04-operate/evidence-register.json\`.\n`
  };
}

function writeFile(outputRoot, relativePath, content) {
  const destination = assertSafeFilePath(outputRoot, relativePath);
  fs.mkdirSync(path.dirname(destination), { recursive: true });
  if (fs.existsSync(destination)) {
    const current = fs.readFileSync(destination, 'utf8');
    if (current === content) return 'unchanged';
    throw new Error(`Refusing to overwrite existing file: ${destination}`);
  }
  fs.writeFileSync(destination, content, 'utf8');
  return 'created';
}

function generate({ intakePath, outputPath }) {
  const intake = readIntake(intakePath);
  const files = workspaceFiles(intake);
  const root = path.resolve(outputPath);
  fs.mkdirSync(root, { recursive: true });
  assertSafeDirectory(root);
  const manifest = {
    schema: 'rvas.delivery.workspace-manifest.v1',
    generator: 'tools/generate-workspace.js',
    intake_sha256: hash(json(canonicalIntake(intake))),
    generated_files: Object.keys(files).sort()
  };
  for (const [relativePath, content] of Object.entries(files)) {
    assertUnchangedOrMissing(root, relativePath, content);
  }
  assertUnchangedOrMissing(root, MANIFEST_NAME, json(manifest));
  for (const [relativePath, content] of Object.entries(files)) writeFile(root, relativePath, content);
  writeFile(root, MANIFEST_NAME, json(manifest));
  return { root, fileCount: Object.keys(files).length };
}

function main() {
  try {
    const args = parseArgs(process.argv.slice(2));
    if (args.help) {
      console.log(usage());
      return;
    }
    const result = generate({ intakePath: args.intake, outputPath: args.out });
    console.log(`Generated ${result.fileCount} workspace files in ${result.root}`);
  } catch (error) {
    console.error(`Workspace generation failed: ${error.message}`);
    process.exitCode = 1;
  }
}

if (require.main === module) main();

module.exports = { generate, parseArgs, readIntake, workspaceFiles };
