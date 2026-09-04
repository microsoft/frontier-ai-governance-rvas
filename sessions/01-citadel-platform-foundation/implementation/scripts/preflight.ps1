[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$DeploymentName = "rvas-s01-baseline",

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$DeploymentLocation,

    [switch]$ConfirmInheritedPolicyReview,

    [Parameter()]
    [string]$ArtifactsPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$implementationSession = "01-platform-baseline"
if ([string]::IsNullOrWhiteSpace($ArtifactsPath)) {
    $ArtifactsPath = Join-Path $PSScriptRoot "..\artifacts"
}

if (-not (Test-Path -LiteralPath $ArtifactsPath -PathType Container)) {
    throw "Implementation artifacts folder is missing: $ArtifactsPath"
}
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required. Install it through the customer-managed tool process."
}

$requiredFiles = @(
    "infra\foundry\main.bicep"
    "infra\network\main.bicep"
    "environments\sandbox.bicepparam"
    "environments\network-foundation.bicepparam"
    "policy\initiative.bicep"
    "policy\assignment.bicep"
    "policy\guardrail-settings.json"
    "environments\initiative.bicepparam"
    "environments\policy-assignment.bicepparam"
)
$requiredSentinels = @(
    "__REQUIRED_AZURE_REGION__"
    "__REQUIRED_NETWORK_PATTERN__"
    "__REQUIRED_VNET_NAME__"
    "__REQUIRED_VNET_CIDR__"
    "__REQUIRED_AGENT_SUBNET_CIDR__"
    "__REQUIRED_PRIVATE_ENDPOINT_SUBNET_CIDR__"
    "__REQUIRED_FIREWALL_PRIVATE_IP__"
    "__REQUIRED_BUSINESS_OWNER__"
    "__REQUIRED_TECHNICAL_OWNER__"
    "__REQUIRED_DATA_CLASSIFICATION__"
    "__REQUIRED_CRITICALITY__"
    "__REQUIRED_COST_CENTER__"
    "__REQUIRED_EXPIRY_DATE__"
    "__REQUIRED_PRIMARY_REGION__"
    "__REQUIRED_SECONDARY_REGION__"
)

function Assert-WhatIfChanges {
    param(
        [Parameter(Mandatory)][object]$WhatIf,
        [Parameter(Mandatory)][ValidateSet("baseline", "initiative", "assignment", "network")][string]$Preview,
        [Parameter(Mandatory)][string]$ScopeId,
        [string]$NamePrefix,
        [string]$ProjectName
    )

    $scope = [regex]::Escape($ScopeId.TrimEnd("/"))
    switch ($Preview) {
        "baseline" {
            $prefix = [regex]::Escape($NamePrefix)
            $project = [regex]::Escape($ProjectName)
            $allowedPatterns = @(
                "^$scope/providers/Microsoft\.CognitiveServices/accounts/$prefix-[^/]+$"
                "^$scope/providers/Microsoft\.CognitiveServices/accounts/$prefix-[^/]+/projects/$project$"
                "^$scope/providers/Microsoft\.CognitiveServices/accounts/$prefix-[^/]+/projects/$project/connections/applicationinsights$"
                "^$scope/providers/Microsoft\.OperationalInsights/workspaces/log-$prefix-[^/]+$"
                "^$scope/providers/Microsoft\.Insights/components/appi-$prefix-[^/]+$"
            )
        }
        "initiative" {
            $allowedPatterns = @(
                "^$scope/providers/Microsoft\.Authorization/policySetDefinitions/$([regex]::Escape($NamePrefix))$"
            )
        }
        "assignment" {
            $allowedPatterns = @(
                "^$scope/providers/Microsoft\.Authorization/policyAssignments/$([regex]::Escape($NamePrefix))$"
            )
        }
        "network" {
            $network = [regex]::Escape($NamePrefix)
            $allowedPatterns = @(
                "^$scope/providers/Microsoft\.Network/routeTables/rt-$network-controlled-egress$"
                "^$scope/providers/Microsoft\.Network/virtualNetworks/$network$"
                "^$scope/providers/Microsoft\.Network/virtualNetworks/$network/subnets/snet-foundry-agent$"
                "^$scope/providers/Microsoft\.Network/virtualNetworks/$network/subnets/snet-private-endpoints$"
            )
        }
    }

    foreach ($change in @($WhatIf.changes)) {
        $resourceId = ([string]$change.resourceId).TrimEnd("/")
        if (
            [string]::IsNullOrWhiteSpace($resourceId) -or
            -not @($allowedPatterns | Where-Object {
                $resourceId -match $_
            })
        ) {
            throw "What-if includes an unrelated resource: $($resourceId ?? '<missing resource ID>')"
        }

        $allowedChanges = @("Create", "NoChange")
        if ($resourceId.EndsWith("/connections/applicationinsights", [System.StringComparison]::OrdinalIgnoreCase)) {
            $allowedChanges += @("Modify", "Deploy")
        }
        elseif ($Preview -in @("initiative", "assignment")) {
            $allowedChanges += "Modify"
        }
        if ([string]$change.changeType -notin $allowedChanges) {
            throw "What-if change $($change.changeType) is not allowed for $resourceId."
        }
    }
}

foreach ($relative in $requiredFiles) {
    if (-not (Test-Path (Join-Path $ArtifactsPath $relative) -PathType Leaf)) {
        throw "Required implementation file is missing: $relative"
    }
}

foreach ($name in @("RVAS_ALLOWED_LOCATIONS_POLICY_ID", "RVAS_REQUIRE_TAG_POLICY_ID")) {
    if ([string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($name))) {
        throw "Set $name from resolve-builtins.ps1 output before deployment."
    }
}

$matches = @(
    Get-ChildItem -LiteralPath $ArtifactsPath -Recurse -File |
        Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__"
)
$unresolved = @($matches.Matches.Value | Sort-Object -Unique)
$foundryParametersFile = Join-Path $ArtifactsPath "environments\sandbox.bicepparam"
$foundryParametersText = Get-Content -LiteralPath $foundryParametersFile -Raw
$preflightPatternMatch = [regex]::Match(
    $foundryParametersText,
    "(?m)^\s*param\s+networkPattern\s*=\s*'([^']+)'\s*$"
)
if ($preflightPatternMatch.Success -and $preflightPatternMatch.Groups[1].Value -ne "byo-vnet") {
    $unresolved = @($unresolved | Where-Object {
        $_ -notin @(
            "__REQUIRED_VNET_NAME__"
            "__REQUIRED_VNET_CIDR__"
            "__REQUIRED_AGENT_SUBNET_CIDR__"
            "__REQUIRED_PRIVATE_ENDPOINT_SUBNET_CIDR__"
            "__REQUIRED_FIREWALL_PRIVATE_IP__"
        )
    })
}
if ($unresolved.Count -gt 0) {
    $unknown = @($unresolved | Where-Object { $_ -notin $requiredSentinels })
    $message = "Resolve customer decisions before deployment: $($unresolved -join ', ')."
    if ($unknown.Count -gt 0) {
        $message += " Add checks for new sentinels: $($unknown -join ', ')."
    }
    throw $message
}

$expiryMatch = [regex]::Match(
    $foundryParametersText,
    "(?m)^\s*param\s+expiryDate\s*=\s*'([^']+)'\s*$"
)
if (-not $expiryMatch.Success) {
    throw "sandbox.bicepparam must assign expiryDate as a quoted ISO date."
}

$parsedExpiry = [datetime]::MinValue
if (-not [datetime]::TryParseExact(
    $expiryMatch.Groups[1].Value,
    "yyyy-MM-dd",
    [System.Globalization.CultureInfo]::InvariantCulture,
    [System.Globalization.DateTimeStyles]::None,
    [ref]$parsedExpiry
)) {
    throw "expiryDate must use ISO yyyy-MM-dd format."
}

$networkMatch = [regex]::Match(
    $foundryParametersText,
    "(?m)^\s*param\s+publicNetworkAccess\s*=\s*'([^']+)'\s*$"
)
if (-not $networkMatch.Success -or $networkMatch.Groups[1].Value -notin @("Enabled", "Disabled")) {
    throw "publicNetworkAccess must be either Enabled or Disabled."
}

$networkPatternMatch = [regex]::Match(
    $foundryParametersText,
    "(?m)^\s*param\s+networkPattern\s*=\s*'([^']+)'\s*$"
)
if (-not $networkPatternMatch.Success -or $networkPatternMatch.Groups[1].Value -notin @("public", "public-private-inbound", "byo-vnet")) {
    throw "networkPattern must be public, public-private-inbound, or byo-vnet."
}
if ($networkPatternMatch.Groups[1].Value -eq "byo-vnet") {
    $subnetMatch = [regex]::Match(
        $foundryParametersText,
        "(?m)^\s*param\s+agentSubnetResourceId\s*=\s*'([^']+)'\s*$"
    )
    if (-not $subnetMatch.Success -or [string]::IsNullOrWhiteSpace($subnetMatch.Groups[1].Value)) {
        throw "byo-vnet requires agentSubnetResourceId from the approved delegated subnet."
    }

    $cutoverAccountsRaw = & az resource list `
        --resource-group $ResourceGroupName `
        --resource-type "Microsoft.CognitiveServices/accounts" `
        --query "[?tags.implementationSession=='$implementationSession'].{id:id,networkControlSession:tags.networkControlSession}" `
        --only-show-errors `
        --output json 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Foundry cutover-marker lookup failed.`n$($cutoverAccountsRaw | Out-String)"
    }
    $cutoverAccounts = @(($cutoverAccountsRaw | Out-String) | ConvertFrom-Json -ErrorAction Stop)
    if (
        $networkMatch.Groups[1].Value -eq "Enabled" -and
        @($cutoverAccounts | Where-Object { $_.networkControlSession -eq "02-private-networking-dns" }).Count -gt 0
    ) {
        throw "publicNetworkAccess cannot be Enabled after Session 02 records networkControlSession=02-private-networking-dns on the Session 01 Foundry account."
    }
}

$settingsPath = Join-Path $ArtifactsPath "policy\guardrail-settings.json"
$settings = Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json -ErrorAction Stop
$requiredTags = @($settings.requiredTagNames | ForEach-Object { ([string]$_).Trim() })
if (
    $settings.implementationSession -ne $implementationSession -or
    $requiredTags.Count -eq 0 -or
    @($requiredTags | Where-Object { [string]::IsNullOrWhiteSpace($_) }).Count -gt 0 -or
    @($requiredTags | Sort-Object -Unique).Count -ne $requiredTags.Count
) {
    throw "policy\guardrail-settings.json must contain one nonempty, unique requiredTagNames list and the $implementationSession marker."
}
foreach ($relative in @("environments\initiative.bicepparam", "environments\policy-assignment.bicepparam")) {
    $text = Get-Content -LiteralPath (Join-Path $ArtifactsPath $relative) -Raw
    if (
        $text -notmatch "loadJsonContent\('\.\./policy/guardrail-settings\.json'\)" -or
        $text -notmatch "(?m)^\s*param\s+requiredTagNames\s*=\s*settings\.requiredTagNames\s*$"
    ) {
        throw "$relative must load requiredTagNames from policy\guardrail-settings.json."
    }
}

$accountJson = & az account show --only-show-errors --output json 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Azure account lookup failed.`n$($accountJson | Out-String)"
}
$account = ($accountJson | Out-String) | ConvertFrom-Json

$groupJson = & az group show `
    --name $ResourceGroupName `
    --query "{id:id,location:location,marker:tags.implementationSession}" `
    --only-show-errors `
    --output json 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "The approved sandbox resource group lookup failed.`n$($groupJson | Out-String)"
}
$targetGroup = ($groupJson | Out-String) | ConvertFrom-Json
if ([string]$targetGroup.marker -ne $implementationSession) {
    throw "Resource group '$ResourceGroupName' must have implementationSession=$implementationSession."
}
$namePrefixMatch = [regex]::Match(
    $foundryParametersText,
    "(?m)^\s*param\s+namePrefix\s*=\s*'([^']+)'\s*$"
)
$projectNameMatch = [regex]::Match(
    $foundryParametersText,
    "(?m)^\s*param\s+projectName\s*=\s*'([^']+)'\s*$"
)
if (-not $namePrefixMatch.Success -or -not $projectNameMatch.Success) {
    throw "sandbox.bicepparam must assign namePrefix and projectName as quoted values."
}
$networkFoundationParametersFile = Join-Path $ArtifactsPath "environments\network-foundation.bicepparam"
$networkNameMatch = [regex]::Match(
    (Get-Content -LiteralPath $networkFoundationParametersFile -Raw),
    "(?m)^\s*param\s+virtualNetworkName\s*=\s*'([^']+)'\s*$"
)
if ($networkPatternMatch.Groups[1].Value -eq "byo-vnet" -and -not $networkNameMatch.Success) {
    throw "network-foundation.bicepparam must assign virtualNetworkName as a quoted value."
}

$policyAssignmentsRaw = & az policy assignment list `
    --scope $targetGroup.id `
    --disable-scope-strict-match true `
    --query "[].{name:name,displayName:displayName,scope:scope,enforcementMode:enforcementMode,policyDefinitionId:policyDefinitionId}" `
    --only-show-errors `
    --output json 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Applicable policy-assignment lookup failed.`n$($policyAssignmentsRaw | Out-String)"
}
$policyAssignments = @(($policyAssignmentsRaw | Out-String) | ConvertFrom-Json -ErrorAction Stop)
$inheritedAssignments = @(
    $policyAssignments | Where-Object {
        $assignmentScope = ([string]$_.scope).TrimEnd("/")
        -not [string]::IsNullOrWhiteSpace($assignmentScope) -and
        -not $assignmentScope.Equals([string]$targetGroup.id, [System.StringComparison]::OrdinalIgnoreCase) -and
        -not ($assignmentScope.StartsWith(
            "$([string]$targetGroup.id)/",
            [System.StringComparison]::OrdinalIgnoreCase
        ))
    }
)
if ($inheritedAssignments.Count -gt 0) {
    Write-Host "Inherited policy assignments:"
    $inheritedAssignments |
        Select-Object displayName, name, scope, enforcementMode, policyDefinitionId |
        Format-Table -AutoSize |
        Out-Host
    if (-not $ConfirmInheritedPolicyReview) {
        throw "Inherited policy assignments apply to the sandbox resource group. Review their effects and exemptions with the cloud platform owner, then rerun with -ConfirmInheritedPolicyReview."
    }
}

$providers = @(
    "Microsoft.CognitiveServices"
    "Microsoft.Insights"
    "Microsoft.OperationalInsights"
    "Microsoft.PolicyInsights"
    "Microsoft.Network"
    "Microsoft.App"
)
foreach ($provider in $providers) {
    $stateOutput = & az provider show `
        --namespace $provider `
        --query registrationState `
        --only-show-errors `
        --output tsv 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Provider lookup failed for $provider.`n$($stateOutput | Out-String)"
    }

    $state = ($stateOutput | Out-String).Trim()
    if ($state -ne "Registered") {
        throw "Provider $provider is '$state'. Register it only through the customer-approved change process."
    }
}

$templateFile = Join-Path $ArtifactsPath "infra\foundry\main.bicep"
& az bicep build --file $templateFile --stdout | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Bicep build failed for the Foundry baseline."
}
$networkTemplateFile = Join-Path $ArtifactsPath "infra\network\main.bicep"
& az bicep build --file $networkTemplateFile --stdout | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Bicep build failed for the BYO VNet foundation."
}
foreach ($file in @("initiative.bicep", "assignment.bicep")) {
    $policyFile = Join-Path $ArtifactsPath "policy\$file"
    & az bicep build --file $policyFile --stdout | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Bicep build failed: policy\$file"
    }
}

Write-Host "Preflight target:"
Write-Host "  Subscription:   $($account.name) ($($account.id))"
Write-Host "  Resource group: $ResourceGroupName"
Write-Host "  Location:       $($targetGroup.location)"
Write-Host "  Marker:         implementationSession=$implementationSession"
Write-Host "  Deployment:     $DeploymentName"
Write-Host ""
if ($networkPatternMatch.Groups[1].Value -eq "byo-vnet") {
    Write-Host "BYO VNet foundation deployment preview:"
    $networkPreview = & az deployment group what-if `
        --resource-group $ResourceGroupName `
        --name rvas-s01-network-foundation-preflight `
        --parameters $networkFoundationParametersFile `
        --result-format FullResourcePayloads `
        --no-pretty-print `
        --only-show-errors `
        --output json 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Network foundation deployment preview failed.`n$($networkPreview | Out-String)"
    }
    $networkWhatIf = ($networkPreview | Out-String) | ConvertFrom-Json -ErrorAction Stop
    Assert-WhatIfChanges `
        -WhatIf $networkWhatIf `
        -Preview network `
        -ScopeId ([string]$targetGroup.id) `
        -NamePrefix $networkNameMatch.Groups[1].Value
    $networkWhatIf | ConvertTo-Json -Depth 20
    Write-Host ""
}

Write-Host "Foundry baseline deployment preview:"

$foundryPreview = & az deployment group what-if `
    --resource-group $ResourceGroupName `
    --name $DeploymentName `
    --parameters $foundryParametersFile `
    --result-format FullResourcePayloads `
    --no-pretty-print `
    --only-show-errors `
    --output json 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Foundry baseline deployment preview failed.`n$($foundryPreview | Out-String)"
}
$foundryWhatIf = ($foundryPreview | Out-String) | ConvertFrom-Json -ErrorAction Stop
Assert-WhatIfChanges `
    -WhatIf $foundryWhatIf `
    -Preview baseline `
    -ScopeId ([string]$targetGroup.id) `
    -NamePrefix $namePrefixMatch.Groups[1].Value `
    -ProjectName $projectNameMatch.Groups[1].Value
$foundryWhatIf | ConvertTo-Json -Depth 20

Write-Host ""
Write-Host "Policy initiative deployment preview:"
$initiativePreview = & az deployment sub what-if `
    --location $DeploymentLocation `
    --name rvas-s01-guardrails-initiative-preflight `
    --parameters (Join-Path $ArtifactsPath "environments\initiative.bicepparam") `
    --result-format FullResourcePayloads `
    --no-pretty-print `
    --only-show-errors `
    --output json 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Initiative preview failed.`n$($initiativePreview | Out-String)"
}
$initiativeWhatIf = ($initiativePreview | Out-String) | ConvertFrom-Json -ErrorAction Stop
Assert-WhatIfChanges `
    -WhatIf $initiativeWhatIf `
    -Preview initiative `
    -ScopeId "/subscriptions/$($account.id)" `
    -NamePrefix "rvas-ai-landing-zone"
$initiativeWhatIf | ConvertTo-Json -Depth 20

$initiativeDefinitionId = [Environment]::GetEnvironmentVariable("RVAS_INITIATIVE_DEFINITION_ID")
if ([string]::IsNullOrWhiteSpace($initiativeDefinitionId)) {
    Write-Host "Assignment preview pending. Set RVAS_INITIATIVE_DEFINITION_ID after the initiative deployment, then rerun preflight."
}
else {
    Write-Host ""
    Write-Host "Policy assignment deployment preview:"
    $assignmentPreview = & az deployment group what-if `
        --resource-group $ResourceGroupName `
        --name rvas-s01-guardrails-assignment-preflight `
        --parameters (Join-Path $ArtifactsPath "environments\policy-assignment.bicepparam") `
        --result-format FullResourcePayloads `
        --no-pretty-print `
        --only-show-errors `
        --output json 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Assignment preview failed.`n$($assignmentPreview | Out-String)"
    }
    $assignmentWhatIf = ($assignmentPreview | Out-String) | ConvertFrom-Json -ErrorAction Stop
    Assert-WhatIfChanges `
        -WhatIf $assignmentWhatIf `
        -Preview assignment `
        -ScopeId ([string]$targetGroup.id) `
        -NamePrefix "rvas-s01-guardrails"
    $assignmentWhatIf | ConvertTo-Json -Depth 20
}

Write-Host ""
Write-Host "READY: tools, files, decisions, approved sandbox subscription and resource group, inherited-policy review, provider registrations, and every available deployment preview are ready."
