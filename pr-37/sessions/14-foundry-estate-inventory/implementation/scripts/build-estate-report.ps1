[CmdletBinding()]
param(
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Get-Command -Name "az" -ErrorAction SilentlyContinue)) {
    throw "The Azure CLI is required."
}
if (-not (Get-Command -Name "python" -ErrorAction SilentlyContinue)) {
    throw "Python is required."
}

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$arguments = @(
    "--scope-path", (Join-Path $artifactRoot "estate-scope.json"),
    "--account-query-path", (Join-Path $artifactRoot "queries\foundry-accounts.kql"),
    "--service-health-query-path", (Join-Path $artifactRoot "queries\service-health-retirements.kql"),
    "--advisor-query-path", (Join-Path $artifactRoot "queries\advisor-retirement-findings.kql")
)
if ($OutputPath) {
    $arguments += @("--output-path", $OutputPath)
}

python (Join-Path $PSScriptRoot "build-estate-report.py") @arguments
if ($LASTEXITCODE -ne 0) {
    throw "The estate report found accounts or lifecycle events that need an owner decision."
}
