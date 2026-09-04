[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]$SourcePath,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovedSubscriptionId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$DeploymentPrincipalId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$profilePath = Join-Path $artifactRoot "citadel\spoke-profile.json"
$releasePath = Join-Path $artifactRoot "citadel\release.json"
$profile = Get-Content -LiteralPath $profilePath -Raw | ConvertFrom-Json -ErrorAction Stop
$release = Get-Content -LiteralPath $releasePath -Raw | ConvertFrom-Json -ErrorAction Stop
$parametersPath = Join-Path ([System.IO.Path]::GetTempPath()) "session03-$([guid]::NewGuid()).parameters.json"

try {
    & (Join-Path $PSScriptRoot "preflight.ps1") `
        -SourcePath $SourcePath `
        -ApprovedSubscriptionId $ApprovedSubscriptionId `
        -DeploymentPrincipalId $DeploymentPrincipalId `
        -ParametersOutput $parametersPath

    if (-not $PSCmdlet.ShouldProcess(
            [string]$profile.resourceGroupName,
            "Deploy the pinned AI Landing Zones Agent Spoke profile")) {
        return
    }

    $entryPoint = Join-Path $SourcePath ([string]$release.implementation.entryPoint)
    & az deployment group create `
        --name session03-agent-spoke `
        --resource-group ([string]$profile.resourceGroupName) `
        --template-file $entryPoint `
        --parameters "@$parametersPath" `
        --only-show-errors | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "The AI Landing Zones Agent Spoke deployment failed."
    }

    & az cognitiveservices account show `
        --name ([string]$profile.foundry.accountName) `
        --resource-group ([string]$profile.resourceGroupName) `
        --only-show-errors | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "The deployed Microsoft Foundry resource could not be read."
    }
    $projectId = "/subscriptions/$ApprovedSubscriptionId/resourceGroups/$($profile.resourceGroupName)/providers/Microsoft.CognitiveServices/accounts/$($profile.foundry.accountName)/projects/$($profile.foundry.projectName)"
    & az resource show --ids $projectId --only-show-errors | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "The deployed Microsoft Foundry project could not be read."
    }
    & az monitor app-insights component show `
        --app ([string]$profile.observability.applicationInsightsName) `
        --resource-group ([string]$profile.resourceGroupName) `
        --only-show-errors | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "The deployed Application Insights component could not be read."
    }
}
finally {
    if (Test-Path -LiteralPath $parametersPath) {
        Remove-Item -LiteralPath $parametersPath -Force
    }
}

Write-Host "PASS: The pinned AI Landing Zones Bicep implementation deployed the approved Agent Spoke profile."
