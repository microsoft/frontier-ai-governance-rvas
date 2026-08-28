[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet("Decisions", "Ready")]
    [string]$Phase = "Ready",

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovedScope
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$sessionRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$repoRoot = Resolve-Path (Join-Path $sessionRoot "..\..")
$approvedTargetScope = $ApprovedScope
$artifactRoot = Join-Path $sessionRoot "implementation\artifacts"
$controlPath = Join-Path $artifactRoot "control-definition.json"
$inventoryPath = Join-Path $artifactRoot "fleet\agent-inventory.md"
$parametersPath = Join-Path $artifactRoot "regional\region.parameters.json"

$coveredDecisionSentinels = @(
    "__REQUIRED_AGENT_365_REGISTRY_ID__",
    "__REQUIRED_AGENT_365_VISIBILITY_STATUS__",
    "__REQUIRED_AGENT_IDENTITY_ID__",
    "__REQUIRED_AGENT_OWNER__",
    "__REQUIRED_AGENT_VERSION__",
    "__REQUIRED_APPLICATION_INSIGHTS_NAME__",
    "__REQUIRED_BUSINESS_SERVICE_NAME__",
    "__REQUIRED_CUSTOMER_BICEP_ENTRYPOINT_PATH__",
    "__REQUIRED_CUSTOMER_HEALTH_CHECK_BASH_PATH__",
    "__REQUIRED_CUSTOMER_HEALTH_CHECK_POWERSHELL_PATH__",
    "__REQUIRED_CUSTOMER_ROUTING_CONTROL_BASH_PATH__",
    "__REQUIRED_CUSTOMER_ROUTING_CONTROL_POWERSHELL_PATH__",
    "__REQUIRED_DEFENDER_VISIBILITY_STATUS__",
    "__REQUIRED_DELIVERY_OWNER__",
    "__REQUIRED_FOUNDRY_ACCOUNT_NAME__",
    "__REQUIRED_FOUNDRY_AGENT_NAME__",
    "__REQUIRED_FOUNDRY_CONTROL_PLANE_VISIBILITY_STATUS__",
    "__REQUIRED_FOUNDRY_PROJECT_NAME__",
    "__REQUIRED_GATEWAY_PATTERN_MULTI_REGION_OR_SEPARATE__",
    "__REQUIRED_GATEWAY_POLICY_VERSION__",
    "__REQUIRED_INVENTORY_SNAPSHOT_DATE__",
    "__REQUIRED_MANAGEMENT_PLANE_LIMIT_ACCEPTED_TRUE__",
    "__REQUIRED_MCP_OWNER__",
    "__REQUIRED_MCP_SERVER_INVENTORY_ID__",
    "__REQUIRED_OPERATIONAL_RECORD_STORE__",
    "__REQUIRED_PLATFORM_OWNER__",
    "__REQUIRED_PRIMARY_APIM_SERVICE_NAME__",
    "__REQUIRED_PRIMARY_APIM_TIER__",
    "__REQUIRED_PRIMARY_BACKEND_URL__",
    "__REQUIRED_PRIMARY_GATEWAY_URL__",
    "__REQUIRED_PRIMARY_REGION__",
    "__REQUIRED_PRIMARY_ROUTING_SELECTOR__",
    "__REQUIRED_PURVIEW_VISIBILITY_STATUS__",
    "__REQUIRED_REGIONAL_RATE_COUNTER_LIMIT_ACCEPTED_TRUE__",
    "__REQUIRED_RESOURCE_GROUP__",
    "__REQUIRED_ROUTING_MODE_EXTERNAL_OR_INTERNAL__",
    "__REQUIRED_SECONDARY_APIM_RESOURCE_ID__",
    "__REQUIRED_SECONDARY_APIM_TIER__",
    "__REQUIRED_SECONDARY_BACKEND_URL__",
    "__REQUIRED_SECONDARY_GATEWAY_URL__",
    "__REQUIRED_SECONDARY_REGION__",
    "__REQUIRED_SECONDARY_ROUTING_SELECTOR__",
    "__REQUIRED_SECURITY_OWNER__",
    "__REQUIRED_SERVICE_OWNER__",
    "__REQUIRED_SUBSCRIPTION_ID__"
)

function Read-JsonObject {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required JSON file is missing: $Path"
    }
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -ErrorAction Stop
}

function Resolve-RepoFile {
    param(
        [Parameter(Mandatory)][string]$RelativePath,
        [Parameter(Mandatory)][string]$Name
    )
    if ([System.IO.Path]::IsPathRooted($RelativePath)) {
        throw "$Name must be repository-relative."
    }
    $candidate = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $RelativePath))
    $prefix = "$([System.IO.Path]::GetFullPath($repoRoot))$([System.IO.Path]::DirectorySeparatorChar)"
    if (-not $candidate.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase) -or
        -not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
        throw "$Name is missing or resolves outside the repository."
    }
    return $candidate
}

function Get-ParameterValue {
    param(
        [Parameter(Mandatory)][pscustomobject]$Document,
        [Parameter(Mandatory)][string]$Name
    )
    $property = $Document.parameters.PSObject.Properties[$Name]
    if ($null -eq $property) {
        throw "Regional parameter contract is missing '$Name'."
    }
    return $property.Value.value
}

function Get-MarkdownVisibleLines {
    param(
        [Parameter(Mandatory)][string]$Path
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
            throw "agent-inventory.md contains raw HTML outside fenced code."
        }
        $visible.Add($line)
    }

    if ($inFence) {
        throw "agent-inventory.md contains an unclosed fenced code block."
    }
    if ([regex]::IsMatch(($visible -join "`n"), $htmlTagPattern)) {
        throw "agent-inventory.md contains raw HTML outside fenced code."
    }
    return $visible.ToArray()
}

function Get-MarkdownSection {
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]]$Lines,
        [Parameter(Mandatory)][string]$Heading
    )

    $indexes = @()
    for ($index = 0; $index -lt $Lines.Count; $index++) {
        if ($Lines[$index].Trim() -ceq $Heading) {
            $indexes += $index
        }
    }
    if ($indexes.Count -eq 0) {
        throw "agent-inventory.md is missing heading '$Heading'."
    }
    if ($indexes.Count -gt 1) {
        throw "agent-inventory.md contains duplicate heading '$Heading'."
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
        [Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]]$Section,
        [Parameter(Mandatory)][string]$Field,
        [Parameter(Mandatory)][string]$Heading
    )

    $headerPattern = '^\|\s*Field\s*\|\s*Observation\s*\|\s*$'
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
        throw "agent-inventory.md section '$Heading' is missing field '$Field'."
    }
    if ($values.Count -gt 1) {
        throw "agent-inventory.md section '$Heading' contains duplicate field '$Field'."
    }

    $value = $values[0]
    if ($value.Length -ge 2 -and
        $value[0] -eq [char]96 -and
        $value[$value.Length - 1] -eq [char]96) {
        $value = $value.Substring(1, $value.Length - 2).Trim()
    }
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "agent-inventory.md field '$Field' in section '$Heading' is empty."
    }
    return $value
}

function Assert-HttpsUrl {
    param([string]$Value, [string]$Name)
    $uri = $null
    if (-not [Uri]::TryCreate($Value, [UriKind]::Absolute, [ref]$uri) -or
        $uri.Scheme -ne "https") {
        throw "$Name must be an absolute HTTPS URL."
    }
}

$requiredFiles = @(
    $controlPath,
    $inventoryPath,
    $parametersPath,
    (Join-Path $artifactRoot "regional\failover-runbook.md"),
    (Join-Path $artifactRoot "README.md")
)
foreach ($path in $requiredFiles) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required implementation file is missing: $path"
    }
}

$matches = @(Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
    Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__" -AllMatches)
$uncovered = @()
$unresolved = @()
foreach ($matchInfo in $matches) {
    foreach ($match in $matchInfo.Matches) {
        if ($match.Value -notin $coveredDecisionSentinels) {
            $uncovered += $match.Value
        }
        $relative = [System.IO.Path]::GetRelativePath($repoRoot, $matchInfo.Path)
        $unresolved += "$($match.Value) at $relative`:$($matchInfo.LineNumber)"
    }
}
if ($uncovered.Count -gt 0) {
    throw "Preflight has no named coverage for: $(@($uncovered | Sort-Object -Unique) -join ', ')"
}
if ($unresolved.Count -gt 0) {
    throw "Resolve every named customer decision before a state change:`n$($unresolved -join "`n")"
}

$scopeMatch = [regex]::Match(
    $approvedTargetScope,
    "^/subscriptions/([0-9a-fA-F-]{36})/resourceGroups/([^/]+)$",
    [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
)
if (-not $scopeMatch.Success) {
    throw "ApprovedScope must be an exact Azure resource-group resource ID."
}
$subscriptionId = $scopeMatch.Groups[1].Value
$resourceGroup = $scopeMatch.Groups[2].Value

$control = Read-JsonObject $controlPath
$parameters = Read-JsonObject $parametersPath
if ([string]$control.implementationSession -cne "15-agent-fleet-multiregion-rehearsal" -or
    [string](Get-ParameterValue $parameters "implementationSession") -cne "15-agent-fleet-multiregion-rehearsal") {
    throw "A implementation file has the wrong implementationSession marker."
}
if ([string]$control.approvedAzureScope -ine $approvedTargetScope) {
    throw "ApprovedScope differs from the operational control."
}

$summaryHeading = "# Agent inventory operator snapshot"
$visibilityHeading = "## Operator visibility observations"
$agentHeading = "## Governed agent"
$agent365Heading = "## Microsoft Agent 365"
$mcpHeading = "## MCP server"
$inventoryLines = @(Get-MarkdownVisibleLines -Path $inventoryPath)
$summary = @(Get-MarkdownSection -Lines $inventoryLines -Heading $summaryHeading)
$visibility = @(Get-MarkdownSection -Lines $inventoryLines -Heading $visibilityHeading)
$agent = @(Get-MarkdownSection -Lines $inventoryLines -Heading $agentHeading)
$agent365 = @(Get-MarkdownSection -Lines $inventoryLines -Heading $agent365Heading)
$mcp = @(Get-MarkdownSection -Lines $inventoryLines -Heading $mcpHeading)

$snapshotDateText = Get-MarkdownField -Section $summary -Field "Snapshot date" -Heading $summaryHeading
$snapshotDate = [datetime]::MinValue
if (-not [datetime]::TryParseExact(
        $snapshotDateText,
        "yyyy-MM-dd",
        [Globalization.CultureInfo]::InvariantCulture,
        [Globalization.DateTimeStyles]::None,
        [ref]$snapshotDate
    ) -or $snapshotDate.Date -gt [datetime]::UtcNow.Date) {
    throw "agent-inventory.md Snapshot date must be a real date that is not in the future."
}
$systemOfRecord = Get-MarkdownField -Section $summary -Field "System of record" -Heading $summaryHeading
if ($systemOfRecord -cne [string]$control.records.approvedOperationalStore) {
    throw "The inventory system of record must match the approved operational store."
}
if ((Get-MarkdownField -Section $summary `
        -Field "Runtime output committed to this repository" `
        -Heading $summaryHeading) -cne "No") {
    throw "The inventory must keep runtime output out of this repository."
}
foreach ($name in @("Name", "Owner")) {
    $null = Get-MarkdownField -Section $agent -Field $name -Heading $agentHeading
}
$inventoryAgentVersion = Get-MarkdownField `
    -Section $agent `
    -Field "Immutable version" `
    -Heading $agentHeading
$null = Get-MarkdownField -Section $agent365 -Field "Registry ID" -Heading $agent365Heading
$inventoryAgentIdentityId = Get-MarkdownField `
    -Section $agent365 `
    -Field "Microsoft Entra agent identity ID" `
    -Heading $agent365Heading
foreach ($name in @("Inventory ID", "Owner")) {
    $null = Get-MarkdownField -Section $mcp -Field $name -Heading $mcpHeading
}
foreach ($name in @(
        "Foundry Control Plane agent visibility",
        "Microsoft Agent 365 registry visibility",
        "Microsoft Purview agent visibility",
        "Microsoft Defender agent visibility"
    )) {
    if ((Get-MarkdownField -Section $visibility -Field $name -Heading $visibilityHeading) -cne "Confirmed") {
        throw "agent-inventory.md field '$name' must be Confirmed."
    }
}

$primaryRegion = [string](Get-ParameterValue $parameters "primaryRegion")
$secondaryRegion = [string](Get-ParameterValue $parameters "secondaryRegion")
$gatewayPattern = [string](Get-ParameterValue $parameters "gatewayPattern")
$routingMode = [string](Get-ParameterValue $parameters "routingMode")
$primaryApimId = [string](Get-ParameterValue $parameters "primaryApimResourceId")
$secondaryApimId = [string](Get-ParameterValue $parameters "secondaryApimResourceId")
$primarySelector = [string](Get-ParameterValue $parameters "primarySelector")
$secondarySelector = [string](Get-ParameterValue $parameters "secondarySelector")
$projectResourceId = [string](Get-ParameterValue $parameters "foundryProjectResourceId")
$applicationInsightsResourceId = [string](Get-ParameterValue $parameters "applicationInsightsResourceId")
$agentVersion = [string](Get-ParameterValue $parameters "agentVersion")
$agentIdentityId = [string](Get-ParameterValue $parameters "agentIdentityId")
if ($inventoryAgentVersion -cne $agentVersion) {
    throw "The inventory immutable version must match region.parameters.json agentVersion."
}
if ($inventoryAgentIdentityId -cne $agentIdentityId) {
    throw "The inventory Microsoft Entra agent identity ID must match region.parameters.json agentIdentityId."
}
if ($primaryRegion -ieq $secondaryRegion) {
    throw "Primary and secondary regions must differ."
}
if ([string]::IsNullOrWhiteSpace($primarySelector) -or
    [string]::IsNullOrWhiteSpace($secondarySelector) -or
    $primarySelector -ieq $secondarySelector) {
    throw "Primary and secondary routing selectors must be nonempty and distinct."
}
$liveResourceIds = @($control.inventory.liveAzureResources | ForEach-Object {
    ([string]$_).ToLowerInvariant()
})
if ($liveResourceIds.Count -ne 2 -or
    $projectResourceId.ToLowerInvariant() -notin $liveResourceIds -or
    $applicationInsightsResourceId.ToLowerInvariant() -notin $liveResourceIds) {
    throw "The control definition and regional parameters use different live Azure resource IDs."
}
if ($gatewayPattern -notin @("multi-region-instance", "separate-regional-gateways")) {
    throw "gatewayPattern must be multi-region-instance or separate-regional-gateways."
}
if ($routingMode -notin @("external", "internal")) {
    throw "routingMode must be external or internal."
}
if ((Get-ParameterValue $parameters "managementPlanePrimaryRegionAccepted") -ne $true -or
    (Get-ParameterValue $parameters "regionalRateCountersAccepted") -ne $true) {
    throw "The primary management-plane and regional counter limits must be accepted."
}
$scopePrefix = "$approvedTargetScope/providers/Microsoft.ApiManagement/service/"
if (-not $primaryApimId.StartsWith($scopePrefix, [System.StringComparison]::OrdinalIgnoreCase) -or
    -not $secondaryApimId.StartsWith($scopePrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Both API Management resources must remain inside ApprovedScope."
}
foreach ($name in @("primaryGatewayUrl", "secondaryGatewayUrl", "primaryBackendUrl", "secondaryBackendUrl")) {
    Assert-HttpsUrl ([string](Get-ParameterValue $parameters $name)) $name
}

$bicepPath = Resolve-RepoFile ([string]$control.sourcePaths.bicepEntrypoint) "Customer Bicep entrypoint"
$healthScript = Resolve-RepoFile ([string]$control.sourcePaths.healthCheckPowerShell) "Customer PowerShell health script"
$routingScript = Resolve-RepoFile ([string]$control.sourcePaths.routingControlPowerShell) "Customer PowerShell routing script"
$null = Resolve-RepoFile ([string]$control.sourcePaths.healthCheckBash) "Customer Bash health script"
$null = Resolve-RepoFile ([string]$control.sourcePaths.routingControlBash) "Customer Bash routing script"
$retainedParameterPath = Resolve-RepoFile ([string]$control.sourcePaths.regionalParameters) "Regional parameter contract"
if ([string]$retainedParameterPath -cne [string][System.IO.Path]::GetFullPath($parametersPath)) {
    throw "The approved regionalParameters path must point to region.parameters.json."
}
foreach ($script in @($healthScript, $routingScript)) {
    $tokens = $null
    $errors = $null
    $null = [System.Management.Automation.Language.Parser]::ParseFile($script, [ref]$tokens, [ref]$errors)
    if (@($errors).Count -gt 0) {
        throw "Customer PowerShell script has syntax errors: $script"
    }
}
foreach ($command in @("az", "pwsh")) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "Required command is unavailable: $command"
    }
}
az bicep lint --file $bicepPath
if ($LASTEXITCODE -ne 0) { throw "Customer Bicep lint failed." }
az bicep build --file $bicepPath --stdout | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Customer Bicep build failed." }

if ($Phase -eq "Decisions") {
    Write-Host "PASS: the dated Markdown inventory, agent and MCP ownership, Confirmed visibility statuses, regional parameters, script syntax, and Bicep checks are ready."
    return
}

$account = az account show -o json | ConvertFrom-Json -ErrorAction Stop
if ($LASTEXITCODE -ne 0 -or [string]$account.id -ine $subscriptionId) {
    throw "Active Azure subscription differs from ApprovedScope."
}
foreach ($resourceId in @($control.inventory.liveAzureResources)) {
    $null = az resource show --ids ([string]$resourceId) -o json |
        ConvertFrom-Json -ErrorAction Stop
    if ($LASTEXITCODE -ne 0) {
        throw "Live Azure inventory resource is unavailable: $resourceId"
    }
}
$primaryApim = az resource show --ids $primaryApimId -o json |
    ConvertFrom-Json -ErrorAction Stop
if ($LASTEXITCODE -ne 0) { throw "Primary API Management resource is unavailable." }
$secondaryApim = if ($secondaryApimId -ieq $primaryApimId) {
    $primaryApim
}
else {
    az resource show --ids $secondaryApimId -o json |
        ConvertFrom-Json -ErrorAction Stop
}
if ($LASTEXITCODE -ne 0) { throw "Secondary API Management resource is unavailable." }

if ([string]$primaryApim.location -ine $primaryRegion -or
    [string]$primaryApim.sku.name -ine [string](Get-ParameterValue $parameters "primaryApimTier") -or
    [string]$secondaryApim.sku.name -ine [string](Get-ParameterValue $parameters "secondaryApimTier")) {
    throw "Live API Management location or tier differs from the parameter contract."
}
if ($gatewayPattern -eq "multi-region-instance") {
    if ($primaryApimId -ine $secondaryApimId -or [string]$primaryApim.sku.name -ine "Premium") {
        throw "One multi-region API Management instance must use Premium (classic) and one resource ID."
    }
    $location = @($primaryApim.properties.additionalLocations) |
        Where-Object { [string]$_.location -ieq $secondaryRegion } |
        Select-Object -First 1
    if ($null -eq $location) {
        throw "The live API Management instance lacks the configured secondary location."
    }
}
elseif ($primaryApimId -ieq $secondaryApimId -or [string]$secondaryApim.location -ine $secondaryRegion) {
    throw "Separate regional gateways require different resource IDs in their approved regions."
}

az deployment group what-if `
    --subscription $subscriptionId `
    --resource-group $resourceGroup `
    --name "s15-regional-preflight" `
    --template-file $bicepPath `
    --parameters "@$parametersPath" `
    --no-pretty-print
if ($LASTEXITCODE -ne 0) { throw "Azure deployment what-if failed." }

Write-Host "PASS: the dated Markdown inventory, stable Azure resources, API Management topology, regional parameters, customer scripts, Bicep, and read-only preview are ready."
