[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]$SourcePath,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovedSubscriptionId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$DeploymentPrincipalId,

    [Parameter()]
    [string]$ParametersOutput
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-Command {
    param([Parameter(Mandatory)][string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "$Name is required."
    }
}

function Normalize-RepositoryUrl {
    param([Parameter(Mandatory)][string]$Url)
    return $Url.ToLowerInvariant().
        Replace("git@github.com:", "https://github.com/").
        TrimEnd("/").
        Replace(".git", "")
}

Assert-Command az
Assert-Command git

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$releasePath = Join-Path $artifactRoot "citadel\release.json"
$profilePath = Join-Path $artifactRoot "citadel\spoke-profile.json"
$agentPath = Join-Path $artifactRoot "agents\policy-assistant\agent.json"
$requiredFiles = @($releasePath, $profilePath, $agentPath)
foreach ($path in $requiredFiles) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required implementation file is missing: $path"
    }
}

$requiredSentinels = @(
    "__REQUIRED_AGENT_NAME__",
    "__REQUIRED_AGENT_SUBNET_PREFIX__",
    "__REQUIRED_APPLICATION_INSIGHTS_NAME__",
    "__REQUIRED_DOWNSTREAM_API_AUTHORIZATION_OWNER__",
    "__REQUIRED_DOWNSTREAM_API_READ_ROLE_ID__",
    "__REQUIRED_DOWNSTREAM_API_READ_SCOPE__",
    "__REQUIRED_FOUNDRY_ACCOUNT_NAME__",
    "__REQUIRED_FOUNDRY_PROJECT_NAME__",
    "__REQUIRED_HUMAN_CHANGE_ROUTE__",
    "__REQUIRED_MODEL_API_VERSION__",
    "__REQUIRED_MODEL_CAPACITY__",
    "__REQUIRED_MODEL_DEPLOYMENT_NAME__",
    "__REQUIRED_MODEL_FORMAT__",
    "__REQUIRED_MODEL_NAME__",
    "__REQUIRED_MODEL_SKU__",
    "__REQUIRED_MODEL_VERSION__",
    "__REQUIRED_PROHIBITED_WRITE_ACTION__",
    "__REQUIRED_PRIVATE_ENDPOINT_SUBNET_PREFIX__",
    "__REQUIRED_RAI_POLICY_NAME__",
    "__REQUIRED_READ_PATH__",
    "__REQUIRED_SPOKE_RESOURCE_GROUP__",
    "__REQUIRED_SPOKE_ROUTE_TABLE_RESOURCE_ID__",
    "__REQUIRED_SPOKE_VNET_RESOURCE_ID__",
    "__REQUIRED_TARGET_AUDIENCE__"
)
$matches = @(Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
    Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__")
if ($matches.Count -gt 0) {
    $unresolved = @($matches.Matches.Value | Sort-Object -Unique)
    $unknown = @($unresolved | Where-Object { $_ -notin $requiredSentinels })
    if ($unknown.Count -gt 0) {
        throw "Add explicit Session 03 checks for new sentinels: $($unknown -join ', ')."
    }
    throw "Resolve every Session 03 customer decision before deployment: $($unresolved -join ', ')."
}

$release = Get-Content -LiteralPath $releasePath -Raw | ConvertFrom-Json -ErrorAction Stop
$profile = Get-Content -LiteralPath $profilePath -Raw | ConvertFrom-Json -ErrorAction Stop
$agent = Get-Content -LiteralPath $agentPath -Raw | ConvertFrom-Json -ErrorAction Stop

if ($profile.schemaVersion -ne 1 -or
    [string]$profile.implementationSession -ne "03-citadel-agent-spoke" -or
    [string]$profile.deploymentEngine -ne "bicep" -or
    [string]$profile.deploymentMode -ne "ailz-integrated" -or
    $profile.networkIsolation -ne $true -or
    $profile.foundry.disableLocalAuth -ne $true -or
    $profile.foundry.deployAgentService -ne $true -or
    $profile.components.deployPublicIngress -ne $false -or
    $profile.components.deployAzureFirewall -ne $false) {
    throw "spoke-profile.json does not match the approved integrated Bicep boundary."
}
if ([string]$agent.modelDeploymentName -ne [string]$profile.model.deploymentName) {
    throw "The agent and landing-zone profile must use the same model deployment name."
}
if ([string]$release.implementation.engine -ne "bicep") {
    throw "release.json must select the Bicep implementation."
}

$entryPoint = Join-Path $SourcePath ([string]$release.implementation.entryPoint)
if (-not (Test-Path -LiteralPath $entryPoint -PathType Leaf)) {
    throw "Pinned Bicep entry point is missing: $entryPoint"
}
$actualRepository = & git -C $SourcePath remote get-url origin
if ($LASTEXITCODE -ne 0 -or
    (Normalize-RepositoryUrl $actualRepository) -ne
    (Normalize-RepositoryUrl ([string]$release.implementation.repository))) {
    throw "The source checkout has the wrong Git remote."
}
$actualCommit = & git -C $SourcePath rev-parse HEAD
if ($LASTEXITCODE -ne 0 -or $actualCommit -ne [string]$release.implementation.commit) {
    throw "The source checkout is not at the pinned AI Landing Zones Bicep commit."
}
$gitStatus = & git -C $SourcePath status --porcelain
if ($LASTEXITCODE -ne 0 -or -not [string]::IsNullOrWhiteSpace(($gitStatus -join ""))) {
    throw "The pinned upstream checkout contains local changes."
}

$account = & az account show --only-show-errors --output json | ConvertFrom-Json
if ($LASTEXITCODE -ne 0 -or [string]$account.id -ne $ApprovedSubscriptionId) {
    throw "Azure CLI is not using the approved subscription."
}
& az group show --name ([string]$profile.resourceGroupName) --only-show-errors | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "The approved Agent Spoke resource group does not exist."
}
& az resource show --ids ([string]$profile.existingVnetResourceId) --only-show-errors | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "The existing Agent Spoke VNet could not be read."
}
& az resource show --ids ([string]$profile.existingRouteTableResourceId) --only-show-errors | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "The platform-owned Agent Spoke route table could not be read."
}
if (-not ([string]$profile.existingVnetResourceId).StartsWith(
        "/subscriptions/$ApprovedSubscriptionId/",
        [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "The existing VNet is outside the approved subscription."
}
if (-not ([string]$profile.existingRouteTableResourceId).StartsWith(
        "/subscriptions/$ApprovedSubscriptionId/",
        [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "The existing route table is outside the approved subscription."
}

$parameters = [ordered]@{
    '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
    contentVersion = "1.0.0.0"
    parameters = [ordered]@{
        environmentName = @{ value = [string]$profile.environmentName }
        location = @{ value = [string]$profile.location }
        principalId = @{ value = $DeploymentPrincipalId }
        principalType = @{ value = [string]$profile.deploymentPrincipalType }
        deploymentTags = @{ value = $profile.tags }
        networkIsolation = @{ value = $true }
        deploymentMode = @{ value = [string]$profile.deploymentMode }
        useExistingVNet = @{ value = $true }
        existingVnetResourceId = @{ value = [string]$profile.existingVnetResourceId }
        hubIntegrationExistingRouteTableResourceId = @{ value = [string]$profile.existingRouteTableResourceId }
        deploySubnets = @{ value = [bool]$profile.deploySubnets }
        agentSubnetName = @{ value = [string]$profile.agentSubnetName }
        agentSubnetPrefix = @{ value = [string]$profile.agentSubnetPrefix }
        peSubnetName = @{ value = [string]$profile.privateEndpointSubnetName }
        peSubnetPrefix = @{ value = [string]$profile.privateEndpointSubnetPrefix }
        policyManagedPrivateDns = @{ value = [bool]$profile.policyManagedPrivateDns }
        deployAiFoundry = @{ value = $true }
        deployAAfAgentSvc = @{ value = $true }
        aiFoundryDisableLocalAuth = @{ value = $true }
        aiFoundryAccountName = @{ value = [string]$profile.foundry.accountName }
        aiFoundryProjectName = @{ value = [string]$profile.foundry.projectName }
        deployAppInsights = @{ value = $true }
        appInsightsName = @{ value = [string]$profile.observability.applicationInsightsName }
        deployLogAnalytics = @{ value = [bool]$profile.observability.deployLogAnalytics }
        deployStorageAccount = @{ value = [bool]$profile.components.deployStorageAccount }
        deployKeyVault = @{ value = [bool]$profile.components.deployKeyVault }
        deploySearchService = @{ value = [bool]$profile.components.deploySearchService }
        deployCosmosDb = @{ value = [bool]$profile.components.deployCosmosDb }
        deployContainerApps = @{ value = [bool]$profile.components.deployContainerApps }
        deployContainerRegistry = @{ value = [bool]$profile.components.deployContainerRegistry }
        deployContainerEnv = @{ value = [bool]$profile.components.deployContainerApps }
        deployAppConfig = @{ value = [bool]$profile.components.deployAppConfiguration }
        deployNsgs = @{ value = $true }
        deployAzureFirewall = @{ value = $false }
        publicIngress = @{ value = @{ enabled = $false } }
        deployJumpbox = @{ value = $false }
        deployBastion = @{ value = $false }
        deployNatGateway = @{ value = $false }
        deployVM = @{ value = $false }
        deploySoftware = @{ value = $false }
        modelDeploymentList = @{
            value = @(
                @{
                    name = [string]$profile.model.deploymentName
                    model = @{
                        format = [string]$profile.model.format
                        name = [string]$profile.model.name
                        version = [string]$profile.model.version
                    }
                    sku = @{
                        name = [string]$profile.model.sku
                        capacity = [int]$profile.model.capacity
                    }
                    canonical_name = "CHAT_DEPLOYMENT_NAME"
                    apiVersion = [string]$profile.model.apiVersion
                }
            )
        }
    }
}

$temporaryOutput = [string]::IsNullOrWhiteSpace($ParametersOutput)
if ($temporaryOutput) {
    $ParametersOutput = Join-Path ([System.IO.Path]::GetTempPath()) "session03-$([guid]::NewGuid()).parameters.json"
}
try {
    $parameters | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $ParametersOutput -Encoding utf8NoBOM
    & az bicep build --file $entryPoint --stdout --only-show-errors | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "The pinned AI Landing Zones Bicep entry point did not compile."
    }
    & az deployment group what-if `
        --name session03-agent-spoke-preview `
        --resource-group ([string]$profile.resourceGroupName) `
        --template-file $entryPoint `
        --parameters "@$ParametersOutput" `
        --only-show-errors
    if ($LASTEXITCODE -ne 0) {
        throw "The AI Landing Zones deployment preview failed."
    }
}
finally {
    if ($temporaryOutput -and (Test-Path -LiteralPath $ParametersOutput)) {
        Remove-Item -LiteralPath $ParametersOutput -Force
    }
}

Write-Host "PASS: The pinned AI Landing Zones Bicep source, customer profile, Azure scope, generated parameters, and deployment preview are ready."
