[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern("^[0-9a-fA-F-]{36}$")]
    [string]$ApprovedSubscriptionId,

    [Parameter(Mandatory)]
    [ValidatePattern("^https://")]
    [string]$Session05AgentBaseUrl,

    [Parameter(Mandatory)]
    [ValidatePattern("^https://")]
    [string]$RemoteMcpServerUrl
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Invoke-AzJson {
    param(
        [Parameter(Mandatory)]
        [string[]]$Arguments,

        [Parameter(Mandatory)]
        [string]$Description
    )

    $raw = & az @Arguments --only-show-errors --output json 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "$Description failed.`n$($raw | Out-String)"
    }
    return (($raw | Out-String) | ConvertFrom-Json -ErrorAction Stop)
}

function Assert-GovernanceRecord {
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$Record,

        [Parameter(Mandatory)]
        [string]$Description
    )

    $requiredProperties = @(
        "businessOwner"
        "technicalOwner"
        "assetKind"
        "dataClassification"
        "permittedConsumers"
        "modelProvider"
        "residencyProfile"
        "riskTier"
        "evaluationResultsUrl"
        "lastReviewDate"
        "expiryDate"
        "implementationSession"
    )
    $actualProperties = @($Record.customProperties.PSObject.Properties.Name)
    $missing = @($requiredProperties | Where-Object { $_ -notin $actualProperties })
    if ($missing.Count -gt 0) {
        throw "$Description is missing required metadata: $($missing -join ', ')."
    }
    if ([string]$Record.customProperties.assetKind -notin @("ai-api", "agent-api", "mcp-server")) {
        throw "$Description has an unsupported assetKind."
    }
    if ([string]$Record.customProperties.dataClassification -notin @("public", "internal", "confidential", "restricted")) {
        throw "$Description has an unsupported dataClassification."
    }
    if ([string]$Record.customProperties.riskTier -notin @("low", "moderate", "high", "critical")) {
        throw "$Description has an unsupported riskTier."
    }
    if (@($Record.customProperties.permittedConsumers).Count -eq 0) {
        throw "$Description must name at least one permitted consumer."
    }
    $evaluationUri = [uri][string]$Record.customProperties.evaluationResultsUrl
    if ($evaluationUri.Scheme -ne "https") {
        throw "$Description evaluationResultsUrl must use HTTPS."
    }
    $lastReview = [datetime]::ParseExact(
        [string]$Record.customProperties.lastReviewDate,
        "yyyy-MM-dd",
        [Globalization.CultureInfo]::InvariantCulture
    )
    $expiry = [datetime]::ParseExact(
        [string]$Record.customProperties.expiryDate,
        "yyyy-MM-dd",
        [Globalization.CultureInfo]::InvariantCulture
    )
    if ($expiry -le $lastReview) {
        throw "$Description expiryDate must be later than lastReviewDate."
    }
    if ([string]$Record.customProperties.implementationSession -ne "08-api-center-ai-mcp-inventory") {
        throw "$Description has the wrong implementationSession marker."
    }
}

function Assert-RuntimeUri {
    param(
        [Parameter(Mandatory)]
        [string]$Value,

        [Parameter(Mandatory)]
        [string]$Description
    )

    $uri = [uri]$Value
    if ($uri.Scheme -ne "https" -or
        [string]::IsNullOrWhiteSpace($uri.Host) -or
        $uri.Host -in @("localhost", "127.0.0.1", "::1") -or
        -not [string]::IsNullOrWhiteSpace($uri.UserInfo) -or
        -not [string]::IsNullOrWhiteSpace($uri.Query) -or
        -not [string]::IsNullOrWhiteSpace($uri.Fragment)) {
        throw "$Description must be a remote HTTPS URL without credentials, query string, or fragment."
    }
}

$implementationSession = "08-api-center-ai-mcp-inventory"
$apiManagementServiceReaderRoleId = "71522526-b88f-4d52-b57f-d31fc3546d0d"
$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$bicepPath = Join-Path $artifactRoot "api-center\main.bicep"
$metadataPath = Join-Path $artifactRoot "api-center\metadata-schemas.json"
$agentDefinitionPath = Join-Path $artifactRoot "api-center\agent-api-definition.json"
$openApiPath = Join-Path $artifactRoot "catalog\specs\policy-assistant-agent.openapi.json"
$environmentPath = Join-Path $artifactRoot "environments\sandbox.json"
$requiredFiles = @(
    $bicepPath
    $metadataPath
    $agentDefinitionPath
    $openApiPath
    $environmentPath
)
$requiredSentinels = @(
    "__REQUIRED_AGENT_NAME__"
    "__REQUIRED_APIM_NAME__"
    "__REQUIRED_APIM_RESOURCE_GROUP_NAME__"
    "__REQUIRED_API_CENTER_LOCATION__"
    "__REQUIRED_API_CENTER_NAME__"
    "__REQUIRED_API_CENTER_PLAN__"
    "__REQUIRED_API_CENTER_RESOURCE_GROUP_NAME__"
    "__REQUIRED_BUSINESS_OWNER__"
    "__REQUIRED_COST_CENTER__"
    "__REQUIRED_CRITICALITY__"
    "__REQUIRED_DATA_CLASSIFICATION__"
    "__REQUIRED_EVALUATION_RESULTS_URL__"
    "__REQUIRED_EXPIRY_DATE__"
    "__REQUIRED_FOUNDRY_ACCOUNT_NAME__"
    "__REQUIRED_FOUNDRY_PROJECT_NAME__"
    "__REQUIRED_LAST_REVIEW_DATE__"
    "__REQUIRED_MODEL_PROVIDER__"
    "__REQUIRED_PERMITTED_CONSUMER__"
    "__REQUIRED_RESIDENCY_PROFILE__"
    "__REQUIRED_RISK_TIER__"
    "__REQUIRED_TECHNICAL_OWNER__"
)

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required."
}
foreach ($path in $requiredFiles) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required implementation file is missing: $path"
    }
}

$sentinels = Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
    Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__"
if ($sentinels) {
    $unresolved = @($sentinels.Matches.Value | Sort-Object -Unique)
    $unknown = @($unresolved | Where-Object { $_ -notin $requiredSentinels })
    if ($unknown.Count -gt 0) {
        throw "Add explicit Session 08 preflight checks for new sentinels: $($unknown -join ', ')."
    }
    throw "Resolve every Session 08 customer decision before deployment: $($unresolved -join ', ')."
}

$environment = Get-Content -LiteralPath $environmentPath -Raw | ConvertFrom-Json -ErrorAction Stop
$metadataDefinitions = Get-Content -LiteralPath $metadataPath -Raw | ConvertFrom-Json -ErrorAction Stop
$agentDefinition = Get-Content -LiteralPath $agentDefinitionPath -Raw | ConvertFrom-Json -ErrorAction Stop
$agentRecord = $agentDefinition.api
$openApi = Get-Content -LiteralPath $openApiPath -Raw | ConvertFrom-Json -ErrorAction Stop

if ([string]$environment.implementationSession -ne $implementationSession) {
    throw "The approved environment has the wrong implementationSession marker."
}
if ([string]$agentDefinition.implementationSession -ne $implementationSession) {
    throw "The direct agent definition has the wrong implementationSession marker."
}
if ([string]$environment.apiCenterPlan -notin @("Free", "Standard")) {
    throw "apiCenterPlan must be Free or Standard."
}
$metadataNames = @($metadataDefinitions.name)
$requiredMetadataNames = @($agentRecord.customProperties.PSObject.Properties.Name)
$missingSchemas = @($requiredMetadataNames | Where-Object { $_ -notin $metadataNames })
if ($metadataDefinitions.Count -ne 12 -or $missingSchemas.Count -gt 0) {
    throw "The API Center metadata schema must define all 12 required governance properties."
}
foreach ($definition in $metadataDefinitions) {
    $null = [string]$definition.schema | ConvertFrom-Json -ErrorAction Stop
    if (-not [bool]$definition.required) {
        throw "Metadata '$($definition.name)' must remain required for APIs."
    }
}

Assert-GovernanceRecord -Record $agentRecord -Description "Agent API record"
if ([string]$openApi.openapi -ne "3.0.3" -or $null -eq $openApi.paths."/responses".post) {
    throw "The authoritative agent definition must be OpenAPI 3.0.3 with POST /responses."
}
if ($null -ne $openApi.PSObject.Properties["servers"]) {
    throw "The authoritative OpenAPI definition must not commit a runtime server URL."
}

Assert-RuntimeUri -Value $Session05AgentBaseUrl -Description "Session05AgentBaseUrl"
Assert-RuntimeUri -Value $RemoteMcpServerUrl -Description "RemoteMcpServerUrl"
$expectedAgentBaseUrl = "https://$($environment.foundryAccountName).services.ai.azure.com/api/projects/$($environment.foundryProjectName)/agents/$($environment.agentName)/endpoint/protocols/openai"
if ($Session05AgentBaseUrl.TrimEnd("/") -ne $expectedAgentBaseUrl) {
    throw "Session05AgentBaseUrl does not match the existing Session 05 Foundry account, project, and agent."
}

$cliVersion = Invoke-AzJson -Arguments @("version") -Description "Azure CLI version lookup"
if ([version][string]$cliVersion."azure-cli" -lt [version]"2.57.0") {
    throw "Azure CLI 2.57.0 or later is required."
}
$extension = Invoke-AzJson -Arguments @("extension", "show", "--name", "apic-extension") -Description "apic-extension lookup"
if ([string]::IsNullOrWhiteSpace([string]$extension.version)) {
    throw "Install the current apic-extension before delivery."
}
& az apic integration create apim --help *> $null
if ($LASTEXITCODE -ne 0) {
    throw "The installed apic-extension does not expose the GA APIM integration command."
}

$account = Invoke-AzJson -Arguments @("account", "show") -Description "Azure account lookup"
if ([string]$account.id -ne $ApprovedSubscriptionId) {
    throw "Azure CLI is not using the approved subscription."
}
$resourceGroup = Invoke-AzJson `
    -Arguments @("group", "show", "--name", [string]$environment.resourceGroupName) `
    -Description "API Center resource group lookup"
if ([string]$resourceGroup.id -ne "/subscriptions/$ApprovedSubscriptionId/resourceGroups/$($environment.resourceGroupName)") {
    throw "The API Center resource group is outside the approved subscription."
}

$provider = Invoke-AzJson -Arguments @("provider", "show", "--namespace", "Microsoft.ApiCenter") -Description "API Center provider lookup"
$serviceType = @($provider.resourceTypes | Where-Object { [string]$_.resourceType -eq "services" })
if ($serviceType.Count -ne 1) {
    throw "The Microsoft.ApiCenter provider did not return one services resource type."
}
$normalizedLocation = ([string]$environment.location -replace "\s", "").ToLowerInvariant()
$availableLocations = @($serviceType[0].locations | ForEach-Object {
        ([string]$_ -replace "\s", "").ToLowerInvariant()
    })
if ($normalizedLocation -notin $availableLocations) {
    throw "The approved location is not currently advertised for Microsoft.ApiCenter/services in this subscription."
}

$apim = Invoke-AzJson `
    -Arguments @(
        "apim", "show",
        "--name", [string]$environment.apiManagementName,
        "--resource-group", [string]$environment.apiManagementResourceGroupName
    ) `
    -Description "API Management lookup"
$expectedApimId = "/subscriptions/$ApprovedSubscriptionId/resourceGroups/$($environment.apiManagementResourceGroupName)/providers/Microsoft.ApiManagement/service/$($environment.apiManagementName)"
if ([string]$apim.id -ne $expectedApimId) {
    throw "API Management is outside the approved subscription or existing resource group."
}
$eligibleStandardBenefitTiers = @("Standard", "StandardV2", "Premium", "PremiumV2")
if ([string]$environment.apiCenterPlan -eq "Standard" -and
    [string]$apim.sku.name -notin $eligibleStandardBenefitTiers) {
    throw "The approved Standard plan decision requires an eligible linked APIM tier or separate cost approval."
}
if ([string]$environment.apiCenterPlan -eq "Free") {
    Write-Warning "The Free plan has limited features and no Microsoft support. Confirm its limits fit this nonproduction scope."
}

$session07Api = Invoke-AzJson `
    -Arguments @(
        "apim", "api", "show",
        "--api-id", "policy-assistant-responses",
        "--service-name", [string]$environment.apiManagementName,
        "--resource-group", [string]$environment.apiManagementResourceGroupName
    ) `
    -Description "Session 07 APIM API lookup"
if ([string]$session07Api.description -notlike "*implementationSession=07-apim-ai-gateway*") {
    throw "The APIM source does not contain the marked Session 07 API."
}
if ([string]$session07Api.displayName -ne "Governed policy assistant Responses API") {
    throw "The Session 07 APIM display name does not match the approved synchronized API."
}

$role = Invoke-AzJson `
    -Arguments @("role", "definition", "list", "--name", $apiManagementServiceReaderRoleId) `
    -Description "API Management Service Reader Role lookup"
if (@($role).Count -ne 1 -or
    [string]$role[0].roleName -ne "API Management Service Reader Role") {
    throw "Role definition $apiManagementServiceReaderRoleId is not the current API Management Service Reader Role."
}

$existingApiCenterRaw = & az apic show `
    --name ([string]$environment.apiCenterName) `
    --resource-group ([string]$environment.resourceGroupName) `
    --only-show-errors `
    --output json 2>$null
$apiCenterExists = $LASTEXITCODE -eq 0
if ($apiCenterExists) {
    $existingApiCenter = $existingApiCenterRaw | ConvertFrom-Json -ErrorAction Stop
    $tagsProperty = $existingApiCenter.PSObject.Properties["tags"]
    $tags = if ($null -eq $tagsProperty) {
        $null
    }
    else {
        $tagsProperty.Value
    }
    $marker = if ($null -eq $tags) {
        $null
    }
    else {
        $markerProperty = $tags.PSObject.Properties["implementationSession"]
        if ($null -eq $markerProperty) {
            $null
        }
        else {
            $markerProperty.Value
        }
    }
    if ([string]$marker -ne $implementationSession) {
        throw "An existing API Center uses the configured name without the Session 08 marker."
    }
    $existingIntegrationRaw = & az apic integration show `
        --resource-group ([string]$environment.resourceGroupName) `
        --service-name ([string]$environment.apiCenterName) `
        --integration-name ([string]$environment.integrationName) `
        --only-show-errors `
        --output json 2>$null
    if ($LASTEXITCODE -eq 0 -and
        ($existingIntegrationRaw | Out-String) -notmatch [regex]::Escape($expectedApimId)) {
        throw "The current integration name already points to a different API source."
    }
}

Write-Host "Deployment preview:"
Write-Host "  API Center: /subscriptions/$ApprovedSubscriptionId/resourceGroups/$($environment.resourceGroupName)/providers/Microsoft.ApiCenter/services/$($environment.apiCenterName)"
Write-Host "  Location: $($environment.location)"
Write-Host "  Plan decision: $($environment.apiCenterPlan)"
Write-Host "  APIM source: $expectedApimId"
Write-Host "  Agent API: $($agentRecord.title)"
Write-Host "  Remote MCP server: supplied at registration and retained in API Center only"
Write-Host "  Runtime URLs: supplied at delivery and not retained"

& az bicep build --file $bicepPath --stdout *> $null
if ($LASTEXITCODE -ne 0) {
    throw "The API Center Bicep definition failed to compile."
}
& az deployment group what-if `
    --name "session07-api-center-preview" `
    --resource-group ([string]$environment.resourceGroupName) `
    --template-file $bicepPath `
    --parameters `
      "apiManagementResourceGroupName=$($environment.apiManagementResourceGroupName)" `
      "apiManagementName=$($environment.apiManagementName)" `
      "apiCenterName=$($environment.apiCenterName)" `
      "location=$($environment.location)" `
      "session05AgentBaseUrl=$Session05AgentBaseUrl" `
    --only-show-errors `
    --no-pretty-print
if ($LASTEXITCODE -ne 0) {
    throw "The API Center deployment preview failed."
}

Write-Host "PASS: Session 08 files, direct-agent desired state, APIM boundary, runtime coordinates, CLI integration, and deployment preview are ready."
