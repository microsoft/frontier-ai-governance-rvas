# Customer workspace generator

Use the generator at mobilization to create the delivery team's working
structure for one customer engagement. The generated workspace is a control
plane for tasks, decisions, and evidence references. It is not an evidence
store and must not contain customer credentials, tenant IDs, URLs, logs,
exports, or screenshots.

## Prerequisites

- Node.js 18 or later.
- A non-sensitive intake JSON document following
  [`contracts/intake.schema.json`](../../contracts/intake.schema.json).

Start from [`examples/engagement-intake.example.json`](../../examples/engagement-intake.example.json).
Use role aliases rather than personal data when needed.

## Generate the workspace

```bash
npm run generate-workspace -- \
  --intake examples/engagement-intake.example.json \
  --out ../contoso-agent-governance
```

The command validates that the intake has exactly these fields:

| Field | Purpose |
|---|---|
| `customer_slug` | Safe workspace identifier |
| `engagement_id` | Safe delivery identifier |
| `pilot_agent_slug` | Representative non-production agent path |
| `governance_lead` | Governance role or approved alias |
| `platform_lead` | Platform role or approved alias |
| `target_environment_label` | Safe environment label, for example `nonprod` |

The generator rejects unexpected fields and values that look like tenant
configuration, URLs, credentials, tokens, or secrets. Slugs and role aliases
are limited to 80 characters; role aliases cannot start or end with whitespace.

Use `--help` to print the command syntax. The CLI rejects duplicate options and
options without values.

## Result

The generated workspace contains:

```text
00-start-here/          mobilization, charter, and state model
01-platform-foundation/ Citadel/APIM delivery contract and gateway proof plan
02-governance-controls/ control register (`contracts/control-register.schema.json`)
03-assurance/           evaluation and authorized assurance entry point
04-operate/             evidence/decision registers and readiness package
evidence/               reference-only evidence boundary
```

The command is idempotent when the intake values are unchanged, including if
the JSON fields are reordered. It validates every destination before writing,
then refuses to overwrite any existing file with different content, protecting
customer-authored work from partial generation. It also refuses an output root,
parent directory, or generated file that is a symbolic link.

Store evidence in the approved customer records system and record only its
governed reference in the generated registers. Do not add evidence payloads,
credentials, tenant details, logs, exports, or screenshots to a generated
workspace.
