[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
param(
    [Parameter(Mandatory)]
    [string]$CitadelPath,

    [Parameter(Mandatory)]
    [string]$ResourceGroup,

    [switch]$IncludePublish
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

& (Join-Path $PSScriptRoot "preflight.ps1") -CitadelPath $CitadelPath -ResourceGroup $ResourceGroup
$artifactRoot = Join-Path $PSScriptRoot "../artifacts"

function Deploy-Contract {
    param([string]$Name, [string]$Template, [string]$Parameters)
    & az deployment group what-if --name "$Name-preview" --resource-group $ResourceGroup --template-file $Template --parameters $Parameters --only-show-errors
    if ($LASTEXITCODE -ne 0) { throw "$Name what-if failed." }
    if ($PSCmdlet.ShouldProcess($ResourceGroup, "Deploy $Name")) {
        & az deployment group create --name $Name --resource-group $ResourceGroup --template-file $Template --parameters $Parameters --only-show-errors
        if ($LASTEXITCODE -ne 0) { throw "$Name deployment failed." }
    }
}

Deploy-Contract "citadel-backend-contract" (Join-Path $CitadelPath "bicep/infra/llm-backend-onboarding/main.bicep") (Join-Path $artifactRoot "contracts/backend/main.bicepparam")
if ($IncludePublish) {
    Deploy-Contract "citadel-publish-contract" (Join-Path $CitadelPath "bicep/infra/citadel-publish-contracts/main.bicep") (Join-Path $artifactRoot "contracts/publish/main.bicepparam")
}
Deploy-Contract "citadel-access-contract" (Join-Path $CitadelPath "bicep/infra/citadel-access-contracts/main.bicep") (Join-Path $artifactRoot "contracts/access/main.bicepparam")

Write-Host "PASS: Citadel contracts were previewed and deployed in dependency order."
