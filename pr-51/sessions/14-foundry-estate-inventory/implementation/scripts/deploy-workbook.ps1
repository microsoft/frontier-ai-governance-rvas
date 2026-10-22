[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetScope,

    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $true)]
    [string]$ResourceGroup
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

& (Join-Path $PSScriptRoot "preflight.ps1") `
    -TargetScope $TargetScope `
    -WorkbookSubscriptionId $SubscriptionId `
    -WorkbookResourceGroup $ResourceGroup

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
az deployment group create `
    --subscription $SubscriptionId `
    --resource-group $ResourceGroup `
    --name rvas-foundry-estate-lifecycle-workbook `
    --template-file (Join-Path $artifactRoot "infra\deploy-workbook.json") `
    --only-show-errors

if ($LASTEXITCODE -ne 0) {
    throw "Workbook deployment failed."
}
