# Controlled-promotion artifact index

The [implementation guide](../README.md) is the operator runbook. This file maps the desired-state
definitions and machine contracts used by the validators and GitHub Actions workflows.

| Path | Updater and cadence | Consumer |
|---|---|
| `control-definition.json` | Release controls owner before a boundary or external-interface contract change | Validators, preflight, promotion, and restore workflows |
| `github/promotion.yml` | Release engineering owner before a process change | GitHub Actions release operators |
| `github/restore-previous-release.yml` | Release engineering owner before a restore-path change | GitHub Actions restore operators |
| `pipeline/release-manifest.template.json` | Promotion workflow on every successful production promotion | Approved release store and manual restore workflow |
| `pipeline/validate-release.ps1` | Release controls owner when a contract changes | Windows workflow and PowerShell release operators |
| `pipeline/validate-release.sh` | Release controls owner when a contract changes | Bash release operators |
| `environments/nonproduction.parameters.json` | Platform owner before a nonproduction desired-state change | Nonproduction preview and apply jobs |
| `environments/production.parameters.json` | Platform owner before a production desired-state change | Production preview and apply jobs |

The repository keeps Session 11's evaluation definition, threshold policy, release policy, and
generated `blocked-tool-process` self-test as desired state. The approved release/security-store
interface retrieves baseline and candidate results into the temporary workspace for each gate check.

The same interface retrieves a version 1 `security-release-attestation` for Session 12. The
temporary artifact must show external authorization status `authorized`, a report location, a
confirmed comparison for the release agent's approved baseline and remediated versions, lower
aggregate attack success, per-risk non-regression, blocked prohibited actions, and all five privacy
flags set to `false`. The security and change systems retain authorization and report records.

Keep the approved commit SHA outside the release commit. An authorized operator supplies the full
SHA as `workflow_dispatch.release_sha`. Every promotion checkout uses that ref, and deployment
commands pass it as the runtime `releaseCommitSha`.

The `nonproduction` GitHub environment provides Session 13's normal and failure URLs, Application
Insights and Log Analytics resource IDs, and bounded polling settings. Its bearer token is an
environment secret. Session 13 owns the retry loop; this session validates the timeout, retry, and
attempt fields without querying telemetry a second time.

GitHub owns workflow, environment, and deployment metadata. Azure Resource Manager owns deployment
state, and API Management owns live routing. The promotion workflow writes one small release record
to the approved release store after production routing. Manual restore reads that record. The
repository keeps no runtime copy.
