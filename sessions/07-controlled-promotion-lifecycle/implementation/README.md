# Promote and operate the Citadel platform lifecycle

## Session scope

### What we will do

**Promote one immutable Citadel change and keep it operable afterward.** We will bind upstream commits, customer overlays, agent versions, contracts, gate results, and deployment parameters to one release; run protected promotion and restore paths; then add the deployed estate to lifecycle and retirement operations.

### Why it matters

Citadel spans several repositories and Azure control planes. Without one release identity, a reviewed contract can be promoted with another platform version or agent. The release record and estate report keep those parts connected after deployment.

### Boundaries

GitHub Actions controls the approved promotion path. Azure owns live deployment state, APIM owns routing, Foundry owns agent and model state, and the approved release store owns durable release records. The estate report reads live state; it does not replace those systems.

## Architecture

### Architecture at a glance

Citadel has independent release tracks. The hub landing zone, APIM gateway configuration, backend
contract, publish contract, access contracts, usage processing, Agent Spoke, and agent version do not
all change through one upstream deployment command. The release manifest binds the exact versions
that must move together for a customer change.

```text
Customer release manifest
  hub commit | spoke commit | gateway release
  backend contract | publish contract | access contracts
  agent version | evaluation gate | environment parameters
                              |
                    protected promotion workflow
                              |
             nonproduction preview -> apply -> smoke
                              |
                production preview -> approval -> apply
                              |
             APIM route / agent revision / release record
```

The initial hub template provisions the landing zone. Later APIM configuration releases should use
the pinned Gateway Upgrade path when it supports the required change, rather than reprovisioning the
whole hub. Gateway Upgrade changes APIs, policies, fragments, backend definitions, named values, and
diagnostics in place. It does not change the APIM tier, VNet, private endpoints, identities, or the
wider landing-zone infrastructure.

Restore follows the same protected workflow with a previous approved manifest. An APIM
configuration restore does not restore deleted data, network resources, identities, model capacity,
or regional services. Workload revision rollback, gateway rollback, infrastructure recovery, and
data recovery remain separate operations.

The estate workbook reads live Azure state after promotion. It identifies ownership, drift, and
retirement work, but the owning Azure, Foundry, APIM, and release systems remain authoritative.
### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
| --- | --- | --- | --- |
| Release identity | Full SHA and fixed component digests for every changed track | Every stage names the same customer change | Corrections require a new release |
| Hub lifecycle | Initial deployment and later gateway upgrades use separate paths | Avoids reprovisioning the landing zone for policy changes | Operators must choose the correct release track |
| Azure access | Environment-scoped OIDC | No stored Azure client secret | Trust and environment rules need maintenance |
| Restore | Manual protected workflow | Owner sees the selected release and route | Slower than automatic rollback |
| Recovery boundary | Separate application, gateway, infrastructure, and data recovery | Avoids false rollback expectations | Several owners maintain different procedures |
| Estate | Live query plus shared workbook | Finds drift and retirement signals | Owners must resolve findings in source systems |

### Architecture guidance

- [Authenticate to Azure from GitHub Actions by OpenID Connect](https://learn.microsoft.com/azure/developer/github/connect-from-azure-openid-connect)
- [Deployments and environments](https://learn.microsoft.com/azure/developer/github/github-actions)
- [Microsoft Foundry model lifecycle](https://learn.microsoft.com/azure/foundry/openai/concepts/model-retirements)

## Before you start

Use the [upstream Citadel release guidance](https://github.com/Azure-Samples/ai-hub-gateway-solution-accelerator/blob/citadel-v1/guides/release-version-management.md)
for supported deployment and gateway upgrade mechanics. This guide owns the customer release
identity, protected promotion path, restore decision, and estate lifecycle process across the
independent components.

Prepare the protected repository, default branch, four GitHub environments, exact Azure OIDC subjects, scoped deployment roles, required reviewers, secret protection, release store, previous approved release, Citadel source pins, overlays, gate records, smoke interface, routing selector, and estate scope.

### Implementation files

| Type | File | Consumer |
| --- | --- | --- |
| Record | `artifacts/control-definition.json` | Citadel promotion workflows and validators |
| Deployment | `artifacts/github/promotion.yml` | GitHub Actions and the release operator |
| Deployment | `artifacts/github/restore-previous-release.yml` | GitHub Actions and the restore operator |
| Runtime | `artifacts/pipeline/release-manifest.template.json` | promotion workflow and approved release store |
| Runtime | `artifacts/pipeline/validate-release.ps1` | GitHub Actions workflow and PowerShell release operator |
| Runtime | `artifacts/pipeline/validate-release.sh` | Bash-based release operator |
| Deployment | `artifacts/environments/nonproduction.parameters.json` | nonproduction preview and apply jobs |
| Deployment | `artifacts/environments/production.parameters.json` | production preview and apply jobs |
| Record | `artifacts/estate/estate-scope.json` | estate report scripts and platform inventory owner |
| Deployment | `artifacts/estate/infra/main.bicep` | estate workbook deployment |
| Deployment | `artifacts/estate/monitoring/estate-lifecycle-workbook.json` | shared Azure Workbook |
| Runtime | `artifacts/estate/queries/foundry-accounts.kql` | estate report and Azure Resource Graph Explorer |
| Runtime | `artifacts/estate/queries/service-health-retirements.kql` | estate report and Azure Resource Graph Explorer |
| Runtime | `artifacts/estate/queries/advisor-retirement-findings.kql` | estate report and Azure Resource Graph Explorer |

## Decisions and stop conditions

Stop when an action uses a floating tag, a component uses `latest`, the release SHA is outside the protected branch, an OIDC subject differs from the observed GitHub subject, apply credentials are available before approval, gate or smoke records refer to another release, what-if contains unexplained changes, the previous release cannot be restored, or an estate finding has no owner.

## Implement

### 1. Complete the release and estate definitions

Resolve every `__REQUIRED_*__` value. Bind the pinned Citadel hub and spoke commits, customer overlays, agent version, contract digests, gate records, smoke contract, environment parameters, and APIM selector to the release SHA.

### 2. Run preflight

```powershell
.\scripts\preflight.ps1 -Phase Ready -ApprovedNonproductionScope $nonproductionScope -ApprovedProductionScope $productionScope -ApprovedReleaseSha $releaseSha -BaselineRecordPath $baselineRecord -CandidateRecordPath $candidateRecord -SecurityReleaseAttestationPath $securityRecord
```

```bash
./scripts/preflight.sh --phase ready --approved-nonproduction-scope "$nonproduction_scope" --approved-production-scope "$production_scope" --approved-release-sha "$release_sha" --baseline-record-path "$baseline_record" --candidate-record-path "$candidate_record" --security-release-attestation-path "$security_record"
```

Review both Azure what-if results before approval.

### 3. Promote the release

Install `promotion.yml` and `restore-previous-release.yml` through the normal repository change path. Dispatch the promotion workflow with the approved full SHA. It must run local validation, the Session 05 gate, the Session 06 smoke path, both previews, both protected apply stages, routing, and release-record approval in that order.

### 4. Deploy the estate workbook and run the report

```powershell
.\scripts\deploy-workbook.ps1
.\scripts\build-estate-report.ps1
```

```bash
./scripts/deploy-workbook.sh
./scripts/build-estate-report.sh
```

Assign every tag, network, region, lifecycle, Service Health, and Advisor finding to its owning platform or workload team.

## Confirm the result

### Intended path

```powershell
.\scripts\verify.ps1 -Check Intended -ReleaseSha $releaseSha -PromotionRunId $runId
```

```bash
./scripts/verify.sh --check intended --release-sha "$release_sha" --promotion-run-id "$run_id"
```

The same SHA reaches both apply environments after their previews, the selector moves once, the release record is approved, and the estate report includes the deployed Citadel resources.

### Blocked or failure path

Run the workflow with the generated blocked gate. Validation returns `BLOCK`, and no Azure preview, approval, deployment, route change, or release approval runs.

### Delivery-owner checkpoint

The delivery owner confirms both sequences. Keep the previous selector at 100 percent if either path differs.

## After implementation

The release owner manages promotion, action pins, restore, and release records. GitHub and Entra administrators manage environment protection and OIDC trust. Platform and workload owners resolve estate findings and plan Citadel upgrades. Restore through the approved release record and protected workflow. Do not delete shared state, logs, or earlier immutable releases as part of restore.
