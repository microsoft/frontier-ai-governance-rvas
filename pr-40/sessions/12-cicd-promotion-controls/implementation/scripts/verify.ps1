[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet("Intended", "Blocked")]
    [string]$Check,

    [Parameter(Mandatory)]
    [ValidatePattern("^[0-9a-f]{40}$")]
    [string]$ReleaseSha,

    [Parameter()]
    [long]$PromotionRunId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$sessionRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$artifactRoot = Join-Path $sessionRoot "implementation\artifacts"
$validatorPath = Join-Path $artifactRoot "pipeline\validate-release.ps1"
$controlPath = Join-Path $artifactRoot "control-definition.json"

if (-not (Test-Path -LiteralPath $validatorPath -PathType Leaf)) {
    throw "Release validator is missing: $validatorPath"
}

switch ($Check) {
    "Intended" {
        if ($PromotionRunId -le 0) {
            throw "-PromotionRunId is required for the intended-path check."
        }
    }
    "Blocked" {
        if ($PromotionRunId -le 0) {
            throw "-PromotionRunId is required for the blocked-path check."
        }
        & $validatorPath -Mode Blocked -ReleaseSha $ReleaseSha
        if (-not $?) {
            throw "The Session 09 generated self-test did not produce the expected BLOCK outcome."
        }

    }
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI is required to inspect the workflow run."
}
$control = Get-Content -LiteralPath $controlPath -Raw | ConvertFrom-Json
$repository = "$($control.repository.owner)/$($control.repository.name)"
$run = gh api "repos/$repository/actions/runs/$PromotionRunId"
if ($LASTEXITCODE -ne 0) {
    throw "Could not inspect promotion run $PromotionRunId."
}
$run = $run | ConvertFrom-Json
$jobs = gh api "repos/$repository/actions/runs/$PromotionRunId/jobs?per_page=100"
if ($LASTEXITCODE -ne 0) {
    throw "Could not inspect jobs for promotion run $PromotionRunId."
}
$jobs = ($jobs | ConvertFrom-Json).jobs
$expectedValidationName = if ($Check -eq "Intended") {
    "Validate release and gate evaluation (candidate)"
}
else {
    "Validate release and gate evaluation (generated-blocked-tool-process-self-test)"
}
$expectedRunName = "Controlled AI release $ReleaseSha (" +
    $(if ($Check -eq "Intended") { "candidate" } else { "generated-blocked-tool-process-self-test" }) +
    ")"
$validationJob = @($jobs) |
    Where-Object { [string]$_.name -eq $expectedValidationName } |
    Select-Object -First 1
$nonproductionPreviewJob = @($jobs) | Where-Object { [string]$_.name -eq "Preview nonproduction" } | Select-Object -First 1
$nonproductionJob = @($jobs) | Where-Object { [string]$_.name -eq "Approve and deploy nonproduction" } | Select-Object -First 1
$productionPreviewJob = @($jobs) | Where-Object { [string]$_.name -eq "Preview production" } | Select-Object -First 1
$productionJob = @($jobs) |
    Where-Object { [string]$_.name -eq "Approve and deploy production" } |
    Select-Object -First 1

if ($Check -eq "Intended") {
    $gateStep = @($validationJob.steps) |
        Where-Object { [string]$_.name -eq "Apply evaluation and adversarial gates before deployment" } |
        Select-Object -First 1
    if ([string]$run.path -cne [string]$control.repository.workflowPath -or
        [string]$run.display_title -cne $expectedRunName -or
        [string]$run.event -ne "workflow_dispatch" -or
        [string]$run.status -ne "completed" -or [string]$run.conclusion -ne "success" -or
        $null -eq $validationJob -or [string]$validationJob.conclusion -ne "success" -or
        $null -eq $gateStep -or [string]$gateStep.conclusion -ne "success" -or
        $null -eq $nonproductionPreviewJob -or [string]$nonproductionPreviewJob.conclusion -ne "success" -or
        $null -eq $nonproductionJob -or [string]$nonproductionJob.conclusion -ne "success" -or
        $null -eq $productionPreviewJob -or [string]$productionPreviewJob.conclusion -ne "success" -or
        $null -eq $productionJob -or [string]$productionJob.conclusion -ne "success") {
        throw "The intended workflow run did not complete both controlled stages successfully."
    }
    Write-Host "PASS: the intended GitHub Actions run completed its evaluation and security gate, nonproduction, and protected production jobs successfully."
}
else {
    if ($null -eq $validationJob) {
        throw "The blocked workflow run does not identify the generated Session 09 self-test input."
    }
    $gateStep = @($validationJob.steps) |
        Where-Object { [string]$_.name -eq "Apply evaluation and adversarial gates before deployment" } |
        Select-Object -First 1
    $failedBeforeGate = @(
        @($validationJob.steps) | Where-Object {
            $null -ne $gateStep -and
            [int]$_.number -lt [int]$gateStep.number -and
            [string]$_.conclusion -ne "success"
        }
    )
    if ([string]$run.path -cne [string]$control.repository.workflowPath -or
        [string]$run.display_title -cne $expectedRunName -or
        [string]$run.event -ne "workflow_dispatch" -or
        [string]$validationJob.conclusion -ne "failure" -or
        $null -eq $gateStep -or [string]$gateStep.conclusion -ne "failure" -or
        $failedBeforeGate.Count -gt 0) {
        throw "The generated blocked self-test workflow must fail in the predeployment gate job."
    }
    foreach ($job in @($nonproductionPreviewJob, $nonproductionJob, $productionPreviewJob, $productionJob)) {
        if ($null -ne $job -and [string]$job.conclusion -notin @("", "skipped", "cancelled")) {
            throw "An Azure preview, approval, or deployment was reached by the blocked run."
        }
    }
    if ([string]$run.status -ne "completed" -or [string]$run.conclusion -ne "failure") {
        throw "Blocked workflow run must be completed with failure."
    }
    Write-Host "PASS: the generated blocked-tool-process self-test stopped promotion before Azure preview, approval, or deployment."
}
