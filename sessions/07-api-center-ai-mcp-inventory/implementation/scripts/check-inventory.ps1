[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern("^[0-9a-fA-F-]{36}$")]
    [string]$ApprovedSubscriptionId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$RemoteMcpServerTitle
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

function Get-OneApiByTitle {
    param(
        [Parameter(Mandatory)]
        [object[]]$Apis,

        [Parameter(Mandatory)]
        [string]$Title
    )

    $matches = @($Apis | Where-Object { [string]$_.properties.title -eq $Title })
    if ($matches.Count -ne 1) {
        throw "Expected exactly one inventory asset titled '$Title'; found $($matches.Count)."
    }
    return $matches[0]
}

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$environment = Get-Content -LiteralPath (Join-Path $artifactRoot "environments\sandbox.json") -Raw |
    ConvertFrom-Json -ErrorAction Stop
$agentDefinition = Get-Content -LiteralPath (Join-Path $artifactRoot "api-center\agent-api-definition.json") -Raw |
    ConvertFrom-Json -ErrorAction Stop
$agentRecord = $agentDefinition.api
if ([string]$agentDefinition.implementationSession -ne "07-api-center-ai-mcp-inventory") {
    throw "The direct agent definition has the wrong implementationSession marker."
}

if ((Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
        Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__")) {
    throw "Resolve every Session 07 deployment decision before checking the live inventory."
}

$account = Invoke-AzJson -Arguments @("account", "show") -Description "Azure account lookup"
if ([string]$account.id -ne $ApprovedSubscriptionId) {
    throw "Azure CLI is not using the approved subscription."
}

$session06Api = Invoke-AzJson -Arguments @(
    "apim", "api", "show",
    "--api-id", "policy-assistant-responses",
    "--service-name", [string]$environment.apiManagementName,
    "--resource-group", [string]$environment.apiManagementResourceGroupName
) -Description "Session 06 APIM API lookup"
if ([string]$session06Api.description -notlike "*implementationSession=06-apim-ai-gateway*") {
    throw "The Session 06 APIM source does not contain the expected marker."
}

$result = Invoke-AzJson -Arguments @(
    "apic", "api", "list",
    "--resource-group", [string]$environment.resourceGroupName,
    "--service-name", [string]$environment.apiCenterName,
    "--max-items", "500"
) -Description "API Center inventory lookup"
$apis = if ($null -ne $result.PSObject.Properties["value"]) { @($result.value) } else { @($result) }
$selectedApis = @(
    Get-OneApiByTitle -Apis $apis -Title ([string]$agentRecord.title)
    Get-OneApiByTitle -Apis $apis -Title ([string]$session06Api.displayName)
    Get-OneApiByTitle -Apis $apis -Title $RemoteMcpServerTitle
)

$requiredProperties = @(
    "businessOwner", "technicalOwner", "assetKind", "dataClassification", "permittedConsumers",
    "modelProvider", "residencyProfile", "riskTier", "evaluationResultsUrl", "lastReviewDate",
    "expiryDate", "implementationSession"
)
$incomplete = [System.Collections.Generic.List[string]]::new()
foreach ($api in $selectedApis) {
    $customProperties = $api.properties.customProperties
    $missing = @($requiredProperties | Where-Object {
            $property = $customProperties.PSObject.Properties[$_]
            $null -eq $property -or $null -eq $property.Value -or
            [string]::IsNullOrWhiteSpace([string]$property.Value)
        })
    if ($missing.Count -gt 0) {
        $incomplete.Add("$($api.properties.title): $($missing -join ', ')")
    }
}
if ($incomplete.Count -gt 0) {
    throw "Selected inventory assets are missing mandatory metadata:`n$($incomplete -join "`n")"
}

$integration = Invoke-AzJson -Arguments @(
    "apic", "integration", "show",
    "--resource-group", [string]$environment.resourceGroupName,
    "--service-name", [string]$environment.apiCenterName,
    "--integration-name", [string]$environment.integrationName
) -Description "API Center APIM integration lookup"
$expectedApimId = "/subscriptions/$ApprovedSubscriptionId/resourceGroups/$($environment.apiManagementResourceGroupName)/providers/Microsoft.ApiManagement/service/$($environment.apiManagementName)"
if (($integration | ConvertTo-Json -Depth 30) -notlike "*$expectedApimId*") {
    throw "The API Center integration does not point to the current APIM source."
}
$state = [string]$integration.properties.provisioningState
if ([string]::IsNullOrWhiteSpace($state)) {
    Write-Warning "This API Center response does not expose integration provisioning state. Check source health manually in the portal."
}
elseif ($state -notin @("Succeeded", "Ready")) {
    throw "The APIM source integration is not healthy. Current provisioning state: $state."
}

Write-Host "PASS: the selected agent, APIM, and MCP records have mandatory metadata and the APIM integration resolves to the implementation source."
