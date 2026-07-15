#!/usr/bin/env node
'use strict';

const assert = require('assert');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const { generate, parseArgs, readIntake } = require('./generate-workspace');

const root = path.join(__dirname, '..', `.rvas-workspace-test-${crypto.randomUUID()}`);

try {
  const intakePath = path.join(root, 'intake.json');
  const outputPath = path.join(root, 'workspace');
  const intake = {
    customer_slug: 'contoso',
    engagement_id: 'fy27-governance',
    pilot_agent_slug: 'permit-agent',
    governance_lead: 'Governance Lead',
    platform_lead: 'Platform Lead',
    target_environment_label: 'nonprod'
  };

  fs.mkdirSync(root);
  fs.writeFileSync(intakePath, JSON.stringify(intake), 'utf8');
  generate({ intakePath, outputPath });
  fs.writeFileSync(intakePath, JSON.stringify({
    target_environment_label: intake.target_environment_label,
    platform_lead: intake.platform_lead,
    governance_lead: intake.governance_lead,
    pilot_agent_slug: intake.pilot_agent_slug,
    engagement_id: intake.engagement_id,
    customer_slug: intake.customer_slug
  }), 'utf8');
  generate({ intakePath, outputPath });
  assert(fs.existsSync(path.join(outputPath, '01-platform-foundation', 'gateway-proof-plan.md')));
  assert(fs.existsSync(path.join(outputPath, '04-operate', 'evidence-register.json')));
  assert.strictEqual(
    JSON.parse(fs.readFileSync(path.join(outputPath, '02-governance-controls', 'control-register.json'), 'utf8')).schema,
    'rvas.delivery.control-register.v1'
  );

  const unsafePath = path.join(root, 'unsafe.json');
  fs.writeFileSync(unsafePath, JSON.stringify({ ...intake, platform_lead: 'Bearer test' }), 'utf8');
  assert.throws(() => readIntake(unsafePath), /prohibited sensitive/);

  assert.deepStrictEqual(parseArgs(['--help']), { help: true });
  assert.throws(() => parseArgs(['--intake']), /requires a value/);
  assert.throws(() => parseArgs(['--out', 'one', '--out', 'two']), /only be specified once/);

  const conflictingOutput = path.join(root, 'conflicting-workspace');
  const conflictFile = path.join(conflictingOutput, '04-operate', 'decision-register.json');
  fs.mkdirSync(path.dirname(conflictFile), { recursive: true });
  fs.writeFileSync(conflictFile, '{"customer":"authored"}\n', 'utf8');
  assert.throws(() => generate({ intakePath, outputPath: conflictingOutput }), /Refusing to overwrite/);
  assert(!fs.existsSync(path.join(conflictingOutput, 'README.md')));

  const linkedOutput = path.join(root, 'linked-workspace');
  fs.symlinkSync(outputPath, linkedOutput, 'dir');
  assert.throws(() => generate({ intakePath, outputPath: linkedOutput }), /unsafe workspace path/);

  console.log('Workspace generator tests passed.');
} finally {
  fs.rmSync(root, { recursive: true, force: true });
}
