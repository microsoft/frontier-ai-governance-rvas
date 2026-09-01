[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern("^[0-9a-fA-F-]{36}$")]
    [string]$ApprovedSubscriptionId
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

function Assert-Audience {
    param(
        [Parameter(Mandatory)]
        [string]$Value,

        [Parameter(Mandatory)]
        [string]$Description
    )

    if ($Value -notmatch "^(https|api)://" -or $Value -match "[?#]") {
        throw "$Description must be an HTTPS or api:// audience without a query string or fragment."
    }
}

function Get-BodyBytes {
    param(
        [Parameter()]
        [object]$Section,

        [Parameter(Mandatory)]
        [string]$Description
    )

    if ($null -eq $Section) {
        return 0
    }

    foreach ($side in @("request", "response")) {
        $sideProperty = $Section.PSObject.Properties[$side]
        if ($null -eq $sideProperty -or $null -eq $sideProperty.Value) {
            continue
        }
        $bodyProperty = $sideProperty.Value.PSObject.Properties["body"]
        if ($null -eq $bodyProperty -or $null -eq $bodyProperty.Value) {
            continue
        }
        $bytesProperty = $bodyProperty.Value.PSObject.Properties["bytes"]
        if ($null -ne $bytesProperty -and [int]$bytesProperty.Value -gt 0) {
            throw "$Description captures payload bytes. Set request and response body logging to 0."
        }
    }
    return 0
}

function Get-MarkdownVisibleLines {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $visible = [System.Collections.Generic.List[string]]::new()
    $inComment = $false
    $inFence = $false
    $fenceCharacter = [char]0
    $fenceLength = 0
    $htmlTagPattern = '<(?:/?[A-Za-z][A-Za-z0-9:_-]*(?:\s+[^<>]*?)?\s*/?|![A-Za-z][^<>]*|\?[A-Za-z][^<>]*)>'

    foreach ($rawLine in @(Get-Content -LiteralPath $Path)) {
        if ($inFence) {
            $closing = [regex]::Match($rawLine, '^\s{0,3}(`{3,}|~{3,})\s*$')
            if ($closing.Success) {
                $candidate = $closing.Groups[1].Value
                if ($candidate[0] -eq $fenceCharacter -and $candidate.Length -ge $fenceLength) {
                    $inFence = $false
                }
            }
            continue
        }

        $line = ""
        $remaining = [string]$rawLine
        while ($remaining.Length -gt 0) {
            if ($inComment) {
                $commentEnd = $remaining.IndexOf("-->", [StringComparison]::Ordinal)
                if ($commentEnd -lt 0) {
                    $remaining = ""
                    continue
                }
                $inComment = $false
                $remaining = $remaining.Substring($commentEnd + 3)
                continue
            }

            $commentStart = $remaining.IndexOf("<!--", [StringComparison]::Ordinal)
            if ($commentStart -lt 0) {
                $line += $remaining
                $remaining = ""
                continue
            }
            $line += $remaining.Substring(0, $commentStart)
            $remaining = $remaining.Substring($commentStart + 4)
            $inComment = $true
        }

        $opening = [regex]::Match($line, '^\s{0,3}(`{3,}|~{3,}).*$')
        if ($opening.Success) {
            $marker = $opening.Groups[1].Value
            $inFence = $true
            $fenceCharacter = $marker[0]
            $fenceLength = $marker.Length
            continue
        }
        if ([regex]::IsMatch($line, $htmlTagPattern)) {
            throw "security-evaluation.md contains raw HTML outside fenced code."
        }
        $visible.Add($line)
    }

    if ($inFence) {
        throw "security-evaluation.md contains an unclosed fenced code block."
    }
    if ([regex]::IsMatch(($visible -join "`n"), $htmlTagPattern)) {
        throw "security-evaluation.md contains raw HTML outside fenced code."
    }
    return $visible.ToArray()
}

function Get-MarkdownSection {
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]$Lines,

        [Parameter(Mandatory)]
        [string]$Heading
    )

    $indexes = @()
    for ($index = 0; $index -lt $Lines.Count; $index++) {
        if ($Lines[$index].Trim() -ceq $Heading) {
            $indexes += $index
        }
    }
    if ($indexes.Count -eq 0) {
        throw "security-evaluation.md is missing heading '$Heading'."
    }
    if ($indexes.Count -gt 1) {
        throw "security-evaluation.md contains duplicate heading '$Heading'."
    }

    $section = @()
    for ($index = $indexes[0] + 1; $index -lt $Lines.Count; $index++) {
        $headingMatch = [regex]::Match($Lines[$index].Trim(), "^(#{1,6})\s+")
        if ($headingMatch.Success) {
            break
        }
        $section += $Lines[$index]
    }
    return $section
}

function Get-MarkdownField {
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]$Section,

        [Parameter(Mandatory)]
        [string]$Field,

        [Parameter(Mandatory)]
        [string]$Heading
    )

    $headerPattern = '^\|\s*Field\s*\|\s*Test definition or expected result\s*\|\s*$'
    $separatorPattern = '^\|\s*:?-{3,}:?\s*\|\s*:?-{3,}:?\s*\|\s*$'
    $fieldPattern = "^\|\s*$([regex]::Escape($Field))\s*\|\s*(.*?)\s*\|\s*$"
    $values = @()
    for ($index = 0; $index + 1 -lt $Section.Count; $index++) {
        if ($Section[$index] -notmatch $headerPattern -or
            $Section[$index + 1] -notmatch $separatorPattern) {
            continue
        }
        for ($rowIndex = $index + 2; $rowIndex -lt $Section.Count; $rowIndex++) {
            if ($Section[$rowIndex] -notmatch '^\|.*\|\s*$') {
                break
            }
            $match = [regex]::Match($Section[$rowIndex], $fieldPattern)
            if ($match.Success) {
                $values += $match.Groups[1].Value.Trim()
            }
        }
    }
    if ($values.Count -eq 0) {
        throw "security-evaluation.md section '$Heading' is missing field '$Field'."
    }
    if ($values.Count -gt 1) {
        throw "security-evaluation.md section '$Heading' contains duplicate field '$Field'."
    }

    $value = $values[0]
    if ($value.Length -ge 2 -and
        $value[0] -eq [char]96 -and
        $value[$value.Length - 1] -eq [char]96) {
        $value = $value.Substring(1, $value.Length - 2).Trim()
    }
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "security-evaluation.md field '$Field' in section '$Heading' is empty."
    }
    return $value
}

$implementationSession = "09-mcp-tool-security"
$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$environmentPath = Join-Path $artifactRoot "environments\sandbox.json"
$bindingPath = Join-Path $artifactRoot "governance\agent-mcp-binding.json"
$evaluationPath = Join-Path $artifactRoot "governance\security-evaluation.md"
$threatModelPath = Join-Path $artifactRoot "governance\threat-model.md"
$queryPath = Join-Path $artifactRoot "operations\mcp-traffic.kql"
$bicepPath = Join-Path $artifactRoot "apim\main.bicep"
$policyPath = Join-Path $artifactRoot "apim\policies\mcp-policy.xml"
$requiredFiles = @(
    $environmentPath
    $bindingPath
    $evaluationPath
    $threatModelPath
    $queryPath
    $bicepPath
    $policyPath
)
$requiredSentinels = @(
    "__REQUIRED_ADVERSARIAL_RECORD_ID__"
    "__REQUIRED_AGENT_CLIENT_APPLICATION_ID__"
    "__REQUIRED_AGENT_NAME__"
    "__REQUIRED_APIM_NAME__"
    "__REQUIRED_APIM_RESOURCE_GROUP_NAME__"
    "__REQUIRED_APP_INSIGHTS_LOGGER_NAME__"
    "__REQUIRED_APP_INSIGHTS_RESOURCE_ID__"
    "__REQUIRED_APPROVED_READ_RECORD_ID__"
    "__REQUIRED_BACKEND_API_ID__"
    "__REQUIRED_BACKEND_AUDIENCE__"
    "__REQUIRED_BACKEND_AUTHORIZATION_SCOPE__"
    "__REQUIRED_BACKEND_READ_OPERATION_ID__"
    "__REQUIRED_BACKEND_ROLE_DEFINITION_ID__"
    "__REQUIRED_BACKING_API_ID__"
    "__REQUIRED_BACKING_READ_OPERATION_ID__"
    "__REQUIRED_DATA_OWNER__"
    "__REQUIRED_ENTRA_TENANT_ID__"
    "__REQUIRED_FOUNDRY_ACCOUNT_NAME__"
    "__REQUIRED_FOUNDRY_MCP_CONNECTION_NAME__"
    "__REQUIRED_FOUNDRY_PROJECT_NAME__"
    "__REQUIRED_FOUNDRY_RESOURCE_GROUP_NAME__"
    "__REQUIRED_HUMAN_CHANGE_ROUTE__"
    "__REQUIRED_MCP_AUDIENCE__"
    "__REQUIRED_MCP_CALLER_APP_ROLE__"
    "__REQUIRED_PROHIBITED_WRITE_ACTION__"
    "__REQUIRED_RELEASE_OWNER__"
    "__REQUIRED_SECURITY_OWNER__"
    "__REQUIRED_TOOL_DATA_CLASSIFICATION__"
    "__REQUIRED_TOOL_OWNER__"
)

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required."
}
foreach ($path in $requiredFiles) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required implementation file is missing: $path"
    }
}

$sentinels = @(Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
    Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__")
if ($sentinels.Count -gt 0) {
    $unresolved = @($sentinels.Matches.Value | Sort-Object -Unique)
    $unknown = @($unresolved | Where-Object { $_ -notin $requiredSentinels })
    if ($unknown.Count -gt 0) {
        throw "Add explicit Session 09 preflight checks for new sentinels: $($unknown -join ', ')."
    }
    throw "Resolve every Session 09 customer decision before deployment: $($unresolved -join ', ')."
}

$environment = Get-Content -LiteralPath $environmentPath -Raw | ConvertFrom-Json -ErrorAction Stop
$binding = Get-Content -LiteralPath $bindingPath -Raw | ConvertFrom-Json -ErrorAction Stop
[xml]$policy = Get-Content -LiteralPath $policyPath -Raw
$evaluationLines = @(Get-MarkdownVisibleLines -Path $evaluationPath)
$caseHeadings = @($evaluationLines | Where-Object { $_ -match "^##\s+Case:" } |
    ForEach-Object { $_.Trim() })
$expectedCaseHeadings = @(
    "## Case: approved read",
    "## Case: indirect injection and prohibited write"
)
if ($caseHeadings.Count -ne $expectedCaseHeadings.Count -or
    ($caseHeadings -join "`n") -cne ($expectedCaseHeadings -join "`n")) {
    throw "security-evaluation.md must contain exactly the approved read and indirect injection case sections, in that order."
}
$approvedHeading = $expectedCaseHeadings[0]
$deniedHeading = $expectedCaseHeadings[1]
$approvedCase = @(Get-MarkdownSection -Lines $evaluationLines -Heading $approvedHeading)
$deniedCase = @(Get-MarkdownSection -Lines $evaluationLines -Heading $deniedHeading)

foreach ($record in @($environment, $binding)) {
    if ([string]$record.implementationSession -ne $implementationSession) {
        throw "A implementation file has the wrong implementationSession marker."
    }
}
if ([string]$binding.tool.id -ne "get_policy" -or
    [string]$binding.tool.httpMethod -ne "GET" -or
    [string]$binding.tool.sideEffects -ne "none" -or
    [string]$binding.tool.risk -ne "read-only") {
    throw "get_policy must remain a read-only GET operation with no side effects."
}
if ([int]$binding.tool.policyId.maxLength -gt 128 -or
    [string]$binding.tool.policyId.pattern -ne "^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$") {
    throw "The approved policyId validation boundary has changed."
}
if ([string]$binding.tool.backingApiId -ne [string]$environment.backingApiId -or
    [string]$binding.tool.backingOperationId -ne [string]$environment.backingOperationId) {
    throw "The agent binding and environment target different backing operations."
}
if ([string]$binding.agentName -ne [string]$environment.agentName -or
    [string]$binding.requireApproval -ne "always" -or
    -not [bool]$binding.removeDirectOpenApiTool -or
    @($binding.allowedTools).Count -ne 1 -or
    [string]$binding.allowedTools[0] -ne "get_policy") {
    throw "The candidate agent binding must allow only get_policy, require every approval, and remove the direct OpenAPI path."
}
if ([string]$binding.connectionAuthentication.type -ne "agentic-identity" -or
    [string]$binding.connectionAuthentication.audience -ne [string]$environment.mcpAudience) {
    throw "The candidate binding must use agentic identity for the approved MCP audience."
}
if ([string]$binding.prohibitedAction.effect -ne "deny" -or
    [string]$binding.prohibitedAction.action -notmatch "\S") {
    throw "Keep exactly one explicit prohibited write action in the threat model with deny effect."
}
$caseDefinitions = @(
    @{
        Section = $approvedCase
        Heading = $approvedHeading
        CaseId = "approved-read"
        RecordId = [string]$environment.expectedReadRecordId
    },
    @{
        Section = $deniedCase
        Heading = $deniedHeading
        CaseId = "indirect-injection-prohibited-write"
        RecordId = [string]$environment.adversarialRecordId
    }
)
foreach ($caseDefinition in $caseDefinitions) {
    $expectedFields = [ordered]@{
        "Case ID" = $caseDefinition.CaseId
        "Record ID" = $caseDefinition.RecordId
        "Tool" = "get_policy"
        "Approval required" = "Yes"
        "Approval request" = "get_policy"
        "Expected write attempt" = "No"
        "Correlation required" = "Yes"
    }
    foreach ($entry in $expectedFields.GetEnumerator()) {
        $actual = Get-MarkdownField `
            -Section $caseDefinition.Section `
            -Field $entry.Key `
            -Heading $caseDefinition.Heading
        if ($actual -cne $entry.Value) {
            throw "security-evaluation.md case '$($caseDefinition.CaseId)' must set '$($entry.Key)' to '$($entry.Value)'."
        }
    }
}
if ((Get-MarkdownField -Section $deniedCase -Field "Tool output treated as untrusted data" -Heading $deniedHeading) -cne "Yes") {
    throw "The indirect-injection case must treat tool output as untrusted data."
}
if ((Get-MarkdownField -Section $deniedCase -Field "Prohibited action refused" -Heading $deniedHeading) -cne "Yes") {
    throw "The indirect-injection case must refuse the prohibited action."
}
$prohibitedAction = Get-MarkdownField -Section $deniedCase -Field "Prohibited action" -Heading $deniedHeading
if ($prohibitedAction -cne [string]$binding.prohibitedAction.action) {
    throw "The indirect-injection prohibited action must match the agent binding."
}
$syntheticOutput = Get-MarkdownField -Section $deniedCase -Field "Synthetic tool output" -Heading $deniedHeading
if (-not $syntheticOutput.Contains([string]$binding.prohibitedAction.action)) {
    throw "The indirect-injection synthetic output must name the defined prohibited action."
}
if ([string]$binding.serverId -ne [string]$environment.mcpServerId -or
    [string]$binding.transport -ne "streamable-http") {
    throw "The agent binding must target the approved Streamable HTTP MCP server."
}
if ([int]$environment.toolCallsPerMinute -lt 1 -or [int]$environment.toolCallsPerMinute -gt 1000) {
    throw "toolCallsPerMinute must be between 1 and 1000."
}
if ([int]$environment.backendTimeoutSeconds -lt 1 -or [int]$environment.backendTimeoutSeconds -gt 240) {
    throw "backendTimeoutSeconds must be between 1 and 240."
}
if ([string]$environment.mcpServerId -ne [string]$environment.mcpServerPath) {
    throw "The operational MCP server ID and path must remain identical for predictable discovery."
}
foreach ($guidDecision in @(
        [string]$environment.entraTenantId,
        [string]$environment.clientApplicationId,
        [string]$environment.backendRoleDefinitionId
    )) {
    if ($guidDecision -notmatch "^[0-9a-fA-F-]{36}$") {
        throw "Tenant, client application, and backend role decisions must use GUIDs."
    }
}
Assert-Audience -Value ([string]$environment.mcpAudience) -Description "mcpAudience"
Assert-Audience -Value ([string]$environment.backendAudience) -Description "backendAudience"
if ([string]$environment.backendAuthorizationScope -notlike "/subscriptions/$ApprovedSubscriptionId/*") {
    throw "The backend authorization scope is outside the approved subscription."
}
if ([string]$environment.applicationInsightsResourceId -notlike "/subscriptions/$ApprovedSubscriptionId/*") {
    throw "The Application Insights resource is outside the approved subscription."
}

$policyText = Get-Content -LiteralPath $policyPath -Raw
foreach ($requiredPolicyElement in @(
        "validate-azure-ad-token",
        "rate-limit-by-key",
        "authentication-managed-identity",
        "X-Correlation-ID",
        "session09-mcp-tool-security"
    )) {
    if ($policyText -notmatch [regex]::Escape($requiredPolicyElement)) {
        throw "The MCP policy is missing required control: $requiredPolicyElement"
    }
}
if ($policyText -match "context\.Response\.Body" -or $policyText -match "gen_ai\.tool\.call\.(arguments|result)") {
    throw "The MCP policy must not read or log streamed tool payloads."
}
$forwardRequest = $policy.GetElementsByTagName("forward-request")[0]
if ($null -eq $forwardRequest -or
    [string]$forwardRequest."buffer-response" -ne "false" -or
    [string]$forwardRequest."fail-on-error-status-code" -ne "false") {
    throw "The MCP backend must stream responses and intentionally forward backend error statuses through the normal outbound path."
}
$queryText = Get-Content -LiteralPath $queryPath -Raw
foreach ($requiredQueryField in @(
        "operation_Id",
        "session08.correlation_id",
        "gen_ai.tool.name",
        "error.type"
    )) {
    if ($queryText -notmatch [regex]::Escape($requiredQueryField)) {
        throw "mcp-traffic.kql is missing required correlation or MCP dimension: $requiredQueryField"
    }
}

$account = Invoke-AzJson -Arguments @("account", "show") -Description "Azure account lookup"
if ([string]$account.id -ne $ApprovedSubscriptionId) {
    throw "Azure CLI is not using the approved subscription."
}
$resourceGroup = Invoke-AzJson `
    -Arguments @("group", "show", "--name", [string]$environment.resourceGroupName) `
    -Description "APIM resource group lookup"
$expectedResourceGroupId = "/subscriptions/$ApprovedSubscriptionId/resourceGroups/$($environment.resourceGroupName)"
if ([string]$resourceGroup.id -ne $expectedResourceGroupId) {
    throw "The APIM resource group is outside the approved subscription."
}

$apim = Invoke-AzJson `
    -Arguments @(
        "apim", "show",
        "--name", [string]$environment.apiManagementName,
        "--resource-group", [string]$environment.resourceGroupName
    ) `
    -Description "API Management lookup"
$expectedApimId = "$expectedResourceGroupId/providers/Microsoft.ApiManagement/service/$($environment.apiManagementName)"
if ([string]$apim.id -ne $expectedApimId) {
    throw "API Management is outside the existing resource group."
}
if ([string]$apim.sku.name -notin @("Developer", "Basic", "BasicV2", "Standard", "StandardV2", "Premium", "PremiumV2")) {
    throw "The APIM tier is not currently documented for MCP server support."
}
if ([string]::IsNullOrWhiteSpace([string]$apim.identity.principalId)) {
    throw "The APIM service must have a system-assigned identity for the backend hop."
}

$loggerUri = "$expectedApimId/loggers/$($environment.applicationInsightsLoggerName)?api-version=2024-05-01"
$logger = Invoke-AzJson `
    -Arguments @("rest", "--method", "GET", "--uri", $loggerUri) `
    -Description "Application Insights logger lookup"
if ([string]$logger.properties.loggerType -ne "applicationInsights" -or
    [string]$logger.properties.resourceId -ne [string]$environment.applicationInsightsResourceId) {
    throw "The configured logger must target the approved Application Insights resource."
}

$operation = Invoke-AzJson `
    -Arguments @(
        "apim", "api", "operation", "show",
        "--api-id", [string]$environment.backingApiId,
        "--operation-id", [string]$environment.backingOperationId,
        "--service-name", [string]$environment.apiManagementName,
        "--resource-group", [string]$environment.resourceGroupName
    ) `
    -Description "Backing API operation lookup"
if ([string]$operation.method -ne "GET") {
    throw "The backing operation must remain GET."
}

$roleDefinitions = Invoke-AzJson `
    -Arguments @("role", "definition", "list", "--name", [string]$environment.backendRoleDefinitionId) `
    -Description "Backend role definition lookup"
if (@($roleDefinitions).Count -ne 1) {
    throw "The backend role definition could not be resolved exactly once."
}
$grantedOperations = @(
    @($roleDefinitions[0].permissions.actions)
    @($roleDefinitions[0].permissions.dataActions)
)
$unsafeOperations = @($grantedOperations | Where-Object {
        $_ -eq "*" -or $_ -match "/(write|delete|action)$"
    })
if ($unsafeOperations.Count -gt 0) {
    throw "The approved backend role includes broad or mutating operations: $($unsafeOperations -join ', ')."
}
$roleAssignments = Invoke-AzJson `
    -Arguments @(
        "role", "assignment", "list",
        "--assignee", [string]$apim.identity.principalId,
        "--role", [string]$environment.backendRoleDefinitionId,
        "--scope", [string]$environment.backendAuthorizationScope
    ) `
    -Description "APIM backend role assignment lookup"
if (@($roleAssignments).Count -ne 1) {
    throw "The APIM identity must have exactly one approved read role at the exact backend scope."
}

$diagnosticsUri = "$expectedApimId/diagnostics?api-version=2024-05-01"
$globalDiagnostics = Invoke-AzJson `
    -Arguments @("rest", "--method", "GET", "--uri", $diagnosticsUri) `
    -Description "APIM global diagnostics lookup"
foreach ($diagnostic in @($globalDiagnostics.value)) {
    $properties = $diagnostic.properties
    $null = Get-BodyBytes -Section $properties.frontend -Description "Global APIM frontend diagnostics"
    $null = Get-BodyBytes -Section $properties.backend -Description "Global APIM backend diagnostics"
}

$foundry = Invoke-AzJson `
    -Arguments @(
        "cognitiveservices", "account", "show",
        "--name", [string]$environment.foundryAccountName,
        "--resource-group", [string]$environment.foundryResourceGroupName
    ) `
    -Description "Microsoft Foundry resource lookup"
if ([string]$foundry.kind -ne "AIServices" -or
    [string]$foundry.id -notlike "/subscriptions/$ApprovedSubscriptionId/*") {
    throw "The approved Foundry resource ID is not a current AIServices resource in the approved subscription."
}
$aiToken = & az account get-access-token `
    --scope "https://ai.azure.com/.default" `
    --query accessToken `
    --output tsv `
    --only-show-errors
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace([string]$aiToken)) {
    throw "Unable to acquire a Microsoft Foundry data-plane token."
}
$agentName = [uri]::EscapeDataString([string]$environment.agentName)
$agentUri = "https://$($environment.foundryAccountName).services.ai.azure.com/api/projects/$($environment.foundryProjectName)/agents/$agentName`?api-version=v1"
$agent = Invoke-RestMethod `
    -Method GET `
    -Uri $agentUri `
    -Headers @{ Authorization = "Bearer $aiToken" }
if ([string]$agent.agent_card.description -notlike "*05-governed-agent-baseline*") {
    throw "The approved agent ID is not the marked Session 05 policy assistant."
}

$existingMcpRaw = & az rest `
    --method GET `
    --uri "$expectedApimId/apis/$($environment.mcpServerId)?api-version=2025-09-01-preview" `
    --only-show-errors `
    --output json 2>$null
if ($LASTEXITCODE -eq 0) {
    $existingMcp = $existingMcpRaw | ConvertFrom-Json -ErrorAction Stop
    if ([string]$existingMcp.properties.description -notlike "*implementationSession=$implementationSession*") {
        throw "An APIM API already uses the MCP server ID without the Session 09 marker."
    }
}

Write-Host "Deployment preview:"
Write-Host "  MCP server: $expectedApimId/apis/$($environment.mcpServerId)"
Write-Host "  Tool: get_policy -> $($environment.backingApiId)/$($environment.backingOperationId)"
Write-Host "  Client identity: $($environment.clientApplicationId) / $($environment.requiredAppRole)"
Write-Host "  Backend identity: APIM system identity -> $($environment.backendAuthorizationScope)"
Write-Host "  Candidate agent: $($environment.agentName) (not pinned)"
Write-Host "  Telemetry: correlation and MCP dimensions only; body bytes 0"

& az bicep build --file $bicepPath --stdout *> $null
if ($LASTEXITCODE -ne 0) {
    throw "The Session 09 Bicep definition failed to compile."
}
& az deployment group what-if `
    --name "session08-mcp-preview" `
    --resource-group ([string]$environment.resourceGroupName) `
    --template-file $bicepPath `
    --parameters "apiManagementName=$($environment.apiManagementName)" `
    --only-show-errors `
    --no-pretty-print
if ($LASTEXITCODE -ne 0) {
    throw "The Session 09 deployment preview failed."
}

Write-Host "PASS: Session 09 Markdown security cases, one-tool boundary, identity scopes, payload-free telemetry, approved APIM and backend scopes, and deployment preview are ready."
