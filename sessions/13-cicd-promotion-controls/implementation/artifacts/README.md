# Controlled-promotion artifact index

The [implementation guide](../README.md) is the operator runbook. This file maps the machine
contracts that the validators and GitHub Actions workflows consume.

| Path | Runtime consumer |
|---|---|
| `control-definition.json` | Validators, preflight, promotion, and restore workflows |
| `github/promotion.yml` | GitHub Actions release operators |
| `github/restore-previous-release.yml` | GitHub Actions restore operators |
| `pipeline/release-manifest.template.json` | Promotion workflow and approved release store |
| `pipeline/validate-release.ps1` | Windows workflow and PowerShell release operators |
| `pipeline/validate-release.sh` | Bash release operators |
| `environments/nonproduction.parameters.json` | Nonproduction preview and apply jobs |
| `environments/production.parameters.json` | Production preview and apply jobs |

The control points to Session 10's active threshold policy, enabled release policy, approved
baseline, matching candidate, and generated `blocked-tool-process` self-test. Session 11's report
must name the same agent and immutable version, keep complete per-risk comparison rows, and set all
five privacy flags to `false`. Its `socDelivery` object is separate operational evidence.

The approved commit SHA stays outside the release commit. An authorized operator supplies the full
SHA as `workflow_dispatch.release_sha`; every promotion checkout uses that ref, deployment commands
pass it as the runtime `releaseCommitSha`, and manifest creation requires the same value.

The `nonproduction` GitHub environment provides Session 12's normal and failure URLs, Application
Insights and Log Analytics resource IDs, and bounded polling settings. Its bearer token is an
environment secret. Session 12 owns the retry loop; this session validates the timeout, retry, and
attempt fields without querying telemetry a second time.

Restore remains manual. A manifest-finalization failure stops the promotion workflow and leaves the
staged manifest unapproved.
