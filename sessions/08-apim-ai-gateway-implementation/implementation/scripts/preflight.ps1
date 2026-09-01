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
    [string]$SecondaryAgentBaseUrl = ""
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

$implementationSession = "07-apim-ai-gateway"
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
$requiredSentinels = @(
    "__REQUIRED_AGENT_NAME__"
    "__REQUIRED_API_AUDIENCE__"
    "__REQUIRED_APIM_NAME__"
    "__REQUIRED_APP_INSIGHTS_LOGGER_NAME__"
    "__REQUIRED_APP_ROLE__"
    "__REQUIRED_CLIENT_APPLICATION_ID__"
    "__REQUIRED_CONTENT_SAFETY_BACKEND_ID__"
    "__REQUIRED_CONTENT_SAFETY_RESOURCE_ID__"
    "__REQUIRED_ENTRA_TENANT_ID__"
    "__REQUIRED_FOUNDRY_ACCOUNT_NAME__"
    "__REQUIRED_FOUNDRY_PROJECT_NAME__"
    "__REQUIRED_IDENTITY_OWNER__"
    "__REQUIRED_OPERATIONS_OWNER__"
    "__REQUIRED_PLATFORM_OWNER__"
    "__REQUIRED_PRODUCT_OWNER__"
    "__REQUIRED_RESOURCE_GROUP_NAME__"
    "__REQUIRED_SAFETY_OWNER__"
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
        throw "Add explicit Session 07 preflight checks for new sentinels: $($unknown -join ', ')."
    }
    throw "Resolve every Session 07 customer decision before deployment: $($unresolved -join ', ')."
}

$control = Get-Content -LiteralPath $controlPath -Raw | ConvertFrom-Json -ErrorAction Stop
$environment = Get-Content -LiteralPath $environmentPath -Raw | ConvertFrom-Json -ErrorAction Stop
$openApi = Get-Content -LiteralPath $openApiPath -Raw | ConvertFrom-Json -ErrorAction Stop
[xml]$policy = Get-Content -LiteralPath $policyPath -Raw

if ([string]$control.implementationSession -ne $implementationSession -or
    [string]$environment.implementationSession -ne $implementationSession) {
    throw "The implementation files have the wrong implementationSession marker."
}
if ([string]$control.api.operationPath -ne "/responses" -or
    $null -eq $openApi.paths."/responses".post) {
    throw "Session 07 must expose one POST /responses operation."
}
$includeUsage = $openApi.components.schemas.ResponseRequest.properties.stream_options.properties.include_usage
if ($null -eq $includeUsage -or [string]$includeUsage.type -ne "boolean") {
    throw "The Responses contract must document stream_options.include_usage for streaming token metrics."
}
if (-not [bool]$control.product.subscriptionRequired) {
    throw "The governed product must require an APIM subscription."
}
if ([bool]$control.semanticCaching.enabled) {
    throw "Semantic caching is deferred for Session 07."
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
        throw "The Session 07 policy must not contain '$term'."
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
    throw "PrimaryAgentBaseUrl does not match the existing Session 05 Foundry agent."
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
    throw "Assign Foundry Agent Consumer to the APIM identity at the individual Session 05 agent scope."
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
        throw "An existing APIM API uses the configured ID without the Session 07 marker."
    }
}

Write-Host "Deployment preview:"
Write-Host "  APIM: $expectedApimId"
Write-Host "  API path: /$($control.api.path)$($control.api.operationPath)"
Write-Host "  Agent scope: $agentScope"
Write-Host "  Secondary backend enabled: $($environment.secondaryBackendEnabled)"
Write-Host "  Request/response body logging: disabled"
Write-Host "  Semantic caching: deferred"

& az deployment group what-if `
    --name "session07-apim-ai-gateway-preview" `
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

Write-Host "PASS: Session 07 files, decisions, policy, approved Azure scope, identities, safety backend, logger, agent route, and deployment preview are ready."
