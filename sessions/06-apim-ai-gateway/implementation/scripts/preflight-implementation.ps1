[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern("^[0-9a-fA-F-]{36}$")]
    [string]$ApprovedSubscriptionId,

    [Parameter(Mandatory)]
    [ValidatePattern("^https://")]
    [string]$PrimaryAgentBaseUrl,

    [Parameter()]
    [ValidatePattern("^$|^https://")]
    [string]$SecondaryAgentBaseUrl = "",

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$DesignRecordPath = (Join-Path $PSScriptRoot "..\artifacts\gateway-design-record.json")
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

$implementationSession = "06-apim-ai-gateway"
$foundryAgentConsumerRoleId = "eed3b665-ab3a-47b6-8f48-c9382fb1dad6"
$cognitiveServicesUserRoleId = "a97b65f3-24c7-4388-baec-2e87135dc908"
$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$gatewayRoot = Join-Path $artifactRoot "gateway"
$controlPath = Join-Path $artifactRoot "governance\gateway-control.json"
$environmentPath = Join-Path $artifactRoot "environments\sandbox.json"
$bicepPath = Join-Path $gatewayRoot "main.bicep"
$openApiPath = Join-Path $gatewayRoot "apis\policy-assistant-responses.openapi.json"
$policyPath = Join-Path $gatewayRoot "policies\policy.xml"
$requiredFiles = @(
    $controlPath
    $environmentPath
    $bicepPath
    $openApiPath
    $policyPath
)
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required."
}
foreach ($path in $requiredFiles) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required implementation file is missing: $path"
    }
}
if (-not (Test-Path -LiteralPath $DesignRecordPath -PathType Leaf)) {
    throw "The approved Session 06 gateway design record is missing: $DesignRecordPath"
}

$designRecordRaw = Get-Content -LiteralPath $DesignRecordPath -Raw
try {
    $designRecord = $designRecordRaw | ConvertFrom-Json -ErrorAction Stop
}
catch {
    throw "The Session 06 gateway design record must be valid JSON."
}
if ($designRecordRaw -match "_{2}REQUIRED_[A-Z0-9_]+_{2}") {
    throw "Resolve every required Session 06 gateway design decision before the Session 06 deployment."
}
if ([string]$designRecord.recordStatus -ne "ready-for-implementation") {
    throw "The Session 06 gateway design record must be ready-for-implementation."
}
if ([string]$designRecord.targetBackend.type -ne "foundry-agent-service" -or
    [string]$designRecord.targetBackend.implementationVariant -ne "policy-assistant-responses") {
    throw "Session 06 implements the foundry-agent-service policy-assistant-responses variant recorded in Session 06."
}
if ([string]$designRecord.contentSafety.decision -ne "enabled" -or
    [string]::IsNullOrWhiteSpace([string]$designRecord.contentSafety.backendReference)) {
    throw "The Session 06 design record must enable Content Safety and name its approved backend reference."
}
if (@($designRecord.readinessGaps | Where-Object { $_.status -eq "open" }).Count -gt 0) {
    throw "Resolve the open Session 06 readiness gaps before the Session 06 deployment."
}

$sentinels = Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
    Select-String -Pattern "_{2}REQUIRED_[A-Z0-9_]+_{2}"
if ($sentinels) {
    throw "Resolve every Session 06 customer decision before deployment."
}

$control = Get-Content -LiteralPath $controlPath -Raw | ConvertFrom-Json -ErrorAction Stop
$environment = Get-Content -LiteralPath $environmentPath -Raw | ConvertFrom-Json -ErrorAction Stop
$openApi = Get-Content -LiteralPath $openApiPath -Raw | ConvertFrom-Json -ErrorAction Stop
[xml]$policy = Get-Content -LiteralPath $policyPath -Raw

if ([string]$designRecord.apiManagement.instanceName -ne [string]$environment.apiManagementName) {
    throw "The Session 06 design record APIM instance does not match sandbox.json."
}
if ([string]::IsNullOrWhiteSpace([string]$designRecord.ingress.clientIdentity) -or
    [string]::IsNullOrWhiteSpace([string]$designRecord.ingress.backendIdentity) -or
    [string]::IsNullOrWhiteSpace([string]$designRecord.network.inboundPath) -or
    [string]::IsNullOrWhiteSpace([string]$designRecord.network.backendPath) -or
    [string]::IsNullOrWhiteSpace([string]$designRecord.network.privateDnsState)) {
    throw "The Session 06 design record must state the ingress identities and network paths."
}

if ([string]$control.implementationSession -ne $implementationSession -or
    [string]$environment.implementationSession -ne $implementationSession) {
    throw "The implementation files have the wrong implementationSession marker."
}
if ([string]$control.api.operationPath -ne "/responses" -or
    $null -eq $openApi.paths."/responses".post) {
    throw "Session 06 must expose one POST /responses operation."
}
$includeUsage = $openApi.components.schemas.ResponseRequest.properties.stream_options.properties.include_usage
if ($null -eq $includeUsage -or [string]$includeUsage.type -ne "boolean") {
    throw "The Responses contract must document stream_options.include_usage for streaming token metrics."
}
if (-not [bool]$control.product.subscriptionRequired) {
    throw "The governed product must require an APIM subscription."
}
if ([bool]$control.semanticCaching.enabled) {
    throw "Semantic caching is deferred for Session 06."
}
if ([int]$control.telemetry.requestBodyBytesLogged -ne 0 -or
    [int]$control.telemetry.responseBodyBytesLogged -ne 0 -or
    [bool]$control.telemetry.clientIpLogged) {
    throw "Gateway diagnostics must keep request bodies, response bodies, and client IP logging disabled."
}
if ([int]$control.limits.tokensPerMinute -le 0 -or
    [int]$control.limits.tokenQuota -le 0 -or
    [int]$control.limits.requestMaxBytes -le 0 -or
    [int]$control.limits.requestMaxBytes -gt 4194304) {
    throw "Token and request-size limits must be positive; requestMaxBytes cannot exceed 4 MB."
}
if ([int]$control.limits.retryCount -lt 1 -or [int]$control.limits.retryCount -gt 3) {
    throw "Retry count must stay between 1 and 3 for the agent Responses call."
}
if ([int]$control.safety.harmThreshold -lt 0 -or [int]$control.safety.harmThreshold -gt 7) {
    throw "The eight-level Content Safety threshold must be between 0 and 7."
}

$requiredPolicyElements = @(
    "validate-azure-ad-token"
    "validate-content"
    "llm-token-limit"
    "llm-content-safety"
    "llm-emit-token-metric"
    "set-backend-service"
    "authentication-managed-identity"
    "retry"
    "forward-request"
)
foreach ($element in $requiredPolicyElements) {
    if ($policy.GetElementsByTagName($element).Count -ne 1) {
        throw "APIM policy must contain exactly one '$element' element."
    }
}
$managedIdentity = $policy.GetElementsByTagName("authentication-managed-identity")[0]
if ([string]$managedIdentity.resource -ne "https://ai.azure.com" -or
    [string]$managedIdentity."ignore-error" -ne "false") {
    throw "The Foundry backend hop must use fail-closed APIM managed identity for https://ai.azure.com."
}
$tokenLimit = $policy.GetElementsByTagName("llm-token-limit")[0]
if ([string]$tokenLimit."counter-key" -notmatch "context\.Subscription\.Id") {
    throw "Token limits must use the controlled APIM subscription as the counter key."
}
$forbiddenPolicyTerms = @(
    "llm-semantic-cache-lookup"
    "llm-semantic-cache-store"
    "log-to-eventhub"
    "trace"
)
$policyText = Get-Content -LiteralPath $policyPath -Raw
foreach ($term in $forbiddenPolicyTerms) {
    if ($policyText -match [regex]::Escape($term)) {
        throw "The Session 06 policy must not contain '$term'."
    }
}

$primaryUri = [uri]$PrimaryAgentBaseUrl
if ($primaryUri.Scheme -ne "https" -or
    -not [string]::IsNullOrWhiteSpace($primaryUri.Query) -or
    -not [string]::IsNullOrWhiteSpace($primaryUri.Fragment)) {
    throw "PrimaryAgentBaseUrl must be an HTTPS base URL without a query string or fragment."
}
$expectedPrimaryBase = "https://$($environment.foundryAccountName).services.ai.azure.com/api/projects/$($environment.foundryProjectName)/agents/$($environment.agentName)/endpoint/protocols/openai"
if ($PrimaryAgentBaseUrl.TrimEnd("/") -ne $expectedPrimaryBase) {
    throw "PrimaryAgentBaseUrl does not match the existing Session 04 Foundry agent."
}
if ([bool]$environment.secondaryBackendEnabled) {
    if ([string]::IsNullOrWhiteSpace($SecondaryAgentBaseUrl)) {
        throw "SecondaryAgentBaseUrl is required because the approved environment enables secondary routing."
    }
    if ($SecondaryAgentBaseUrl.TrimEnd("/") -eq $PrimaryAgentBaseUrl.TrimEnd("/")) {
        throw "Primary and secondary agent base URLs must differ."
    }
}
elseif (-not [string]::IsNullOrWhiteSpace($SecondaryAgentBaseUrl)) {
    throw "Remove SecondaryAgentBaseUrl or set secondaryBackendEnabled to true after approving the route."
}

$account = Invoke-AzJson -Arguments @("account", "show") -Description "Azure account lookup"
if ([string]$account.id -ne $ApprovedSubscriptionId) {
    throw "Azure CLI is not using the approved subscription."
}

$apim = Invoke-AzJson `
    -Arguments @(
        "apim", "show",
        "--name", [string]$environment.apiManagementName,
        "--resource-group", [string]$environment.resourceGroupName
    ) `
    -Description "API Management lookup"
$expectedApimId = "/subscriptions/$ApprovedSubscriptionId/resourceGroups/$($environment.resourceGroupName)/providers/Microsoft.ApiManagement/service/$($environment.apiManagementName)"
if ([string]$apim.id -ne $expectedApimId) {
    throw "API Management is outside the approved subscription or resource group."
}
if ([string]$apim.sku.name -eq "Consumption") {
    throw "The deployed token-limit and content-safety policy set is not supported on the Consumption tier."
}
if ([string]$designRecord.apiManagement.tier -ne [string]$apim.sku.name) {
    throw "The Session 06 design record APIM tier does not match the live APIM instance."
}
$expectedApimNetworkMode = [string]$environment.network.apimVirtualNetworkType
if ([string]$apim.virtualNetworkType -ne $expectedApimNetworkMode) {
    throw "API Management virtualNetworkType does not match sandbox.json."
}
$apimPrincipalId = [string]$apim.identity.principalId
if ([string]::IsNullOrWhiteSpace($apimPrincipalId)) {
    throw "API Management must have a system-assigned managed identity."
}

$agentScope = "/subscriptions/$ApprovedSubscriptionId/resourceGroups/$($environment.resourceGroupName)/providers/Microsoft.CognitiveServices/accounts/$($environment.foundryAccountName)/projects/$($environment.foundryProjectName)/agents/$($environment.agentName)"
$foundryRole = Invoke-AzJson `
    -Arguments @("role", "definition", "list", "--name", $foundryAgentConsumerRoleId) `
    -Description "Foundry Agent Consumer role lookup"
if (@($foundryRole).Count -ne 1 -or [string]$foundryRole[0].roleName -ne "Foundry Agent Consumer") {
    throw "Role definition $foundryAgentConsumerRoleId is not the current Foundry Agent Consumer role."
}
$foundryAssignments = Invoke-AzJson `
    -Arguments @(
        "role", "assignment", "list",
        "--assignee", $apimPrincipalId,
        "--role", $foundryAgentConsumerRoleId,
        "--scope", $agentScope,
        "--include-inherited"
    ) `
    -Description "APIM Foundry Agent Consumer assignment lookup"
if (@($foundryAssignments).Count -eq 0) {
    throw "Assign Foundry Agent Consumer to the APIM identity at the individual Session 04 agent scope."
}

$contentSafetyResourceId = [string]$environment.contentSafetyResourceId
if ($contentSafetyResourceId -notlike "/subscriptions/$ApprovedSubscriptionId/*") {
    throw "The Content Safety resource is outside the approved subscription."
}
$contentSafety = Invoke-AzJson `
    -Arguments @("resource", "show", "--ids", $contentSafetyResourceId) `
    -Description "Azure AI Content Safety lookup"
if ([string]$contentSafety.kind -ne "ContentSafety") {
    throw "contentSafetyResourceId must identify an Azure AI Content Safety resource."
}
if ([string]$contentSafety.properties.publicNetworkAccess -ne [string]$environment.network.contentSafetyPublicNetworkAccess) {
    throw "Azure AI Content Safety publicNetworkAccess does not match sandbox.json."
}
$contentSafetyAssignments = Invoke-AzJson `
    -Arguments @(
        "role", "assignment", "list",
        "--assignee", $apimPrincipalId,
        "--role", $cognitiveServicesUserRoleId,
        "--scope", $contentSafetyResourceId,
        "--include-inherited"
    ) `
    -Description "APIM Content Safety role assignment lookup"
if (@($contentSafetyAssignments).Count -eq 0) {
    throw "Assign Cognitive Services User to the APIM identity on the Content Safety resource."
}

$foundryResourceId = "/subscriptions/$ApprovedSubscriptionId/resourceGroups/$($environment.resourceGroupName)/providers/Microsoft.CognitiveServices/accounts/$($environment.foundryAccountName)"
$foundry = Invoke-AzJson `
    -Arguments @("resource", "show", "--ids", $foundryResourceId) `
    -Description "Foundry account network lookup"
if ([string]$foundry.properties.publicNetworkAccess -ne [string]$environment.network.foundryPublicNetworkAccess) {
    throw "Foundry publicNetworkAccess does not match sandbox.json."
}

$apiVersion = "2024-05-01"
$loggerUrl = "https://management.azure.com$expectedApimId/loggers/$($environment.applicationInsightsLoggerName)?api-version=$apiVersion"
$logger = Invoke-AzJson -Arguments @("rest", "--method", "get", "--url", $loggerUrl) -Description "Application Insights logger lookup"
if ([string]$logger.properties.loggerType -ne "applicationInsights") {
    throw "The configured logger name does not identify an Application Insights logger."
}
$contentSafetyBackendUrl = "https://management.azure.com$expectedApimId/backends/$($environment.contentSafetyBackendId)?api-version=$apiVersion"
$contentSafetyBackend = Invoke-AzJson -Arguments @("rest", "--method", "get", "--url", $contentSafetyBackendUrl) -Description "Content Safety backend lookup"
if ([string]$contentSafetyBackend.properties.url -notmatch "^https://[^/]+\.cognitiveservices\.azure\.com/?$") {
    throw "The Content Safety backend URL must be an Azure Cognitive Services endpoint."
}

$apiUrl = "https://management.azure.com$expectedApimId/apis/$($control.api.id)?api-version=$apiVersion"
$existingApiRaw = & az rest --method get --url $apiUrl --only-show-errors --output json 2>$null
if ($LASTEXITCODE -eq 0) {
    $existingApi = $existingApiRaw | ConvertFrom-Json -ErrorAction Stop
    if ([string]$existingApi.properties.description -notlike "*implementationSession=$implementationSession*") {
        throw "An existing APIM API uses the configured ID without the Session 06 marker."
    }
}

Write-Host "Deployment preview:"
Write-Host "  APIM: $expectedApimId"
Write-Host "  API path: /$($control.api.path)$($control.api.operationPath)"
Write-Host "  Agent scope: $agentScope"
Write-Host "  Secondary backend enabled: $($environment.secondaryBackendEnabled)"
Write-Host "  APIM virtual network type: $($environment.network.apimVirtualNetworkType)"
Write-Host "  Request/response body logging: disabled"
Write-Host "  Semantic caching: deferred"

& az deployment group what-if `
    --name "session06-apim-ai-gateway-preview" `
    --resource-group ([string]$environment.resourceGroupName) `
    --template-file $bicepPath `
    --parameters `
      "primaryAgentBaseUrl=$PrimaryAgentBaseUrl" `
      "secondaryAgentBaseUrl=$SecondaryAgentBaseUrl" `
      "apiManagementName=$($environment.apiManagementName)" `
      "applicationInsightsLoggerName=$($environment.applicationInsightsLoggerName)" `
      "contentSafetyBackendId=$($environment.contentSafetyBackendId)" `
      "secondaryBackendEnabled=$($environment.secondaryBackendEnabled.ToString().ToLowerInvariant())" `
    --only-show-errors `
    --no-pretty-print
if ($LASTEXITCODE -ne 0) {
    throw "The API Management deployment preview failed."
}

Write-Host "PASS: Session 06 design, Session 06 files, actual backend, identities, network, safety backend, logger, and deployment preview are ready."
