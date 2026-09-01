[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovedSubscriptionId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$CutoverChangeReference,

    [Parameter()]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$ParameterPath = (Join-Path $PSScriptRoot "..\artifacts\environments\sandbox.bicepparam"),

    [Parameter(Mandatory)]
    [switch]$ConfirmPriorStateRecorded,

    [Parameter()]
    [ValidateRange(2, 30)]
    [int]$TimeoutSeconds = 8
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$marker = "02-private-networking-dns"

function Invoke-AzJson {
    param(
        [Parameter(Mandatory)][string[]]$Arguments,
        [Parameter(Mandatory)][string]$Description
    )

    $raw = & az @Arguments --only-show-errors --output json 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "$Description failed.`n$($raw | Out-String)"
    }
    return (($raw | Out-String) | ConvertFrom-Json -ErrorAction Stop)
}

function Get-ParameterValue {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$Name
    )

    $matches = [regex]::Matches(
        $Text,
        "(?m)^\s*param\s+$([regex]::Escape($Name))\s*=\s*'([^']+)'\s*$"
    )
    if ($matches.Count -ne 1) {
        throw "Parameter '$Name' must contain exactly one quoted resource ID."
    }
    return $matches[0].Groups[1].Value.Trim().TrimEnd("/")
}

function Set-PublicNetworkAccess {
    param(
        [Parameter(Mandatory)][string]$Alias,
        [Parameter(Mandatory)][object]$Resource
    )

    $arguments = switch ($Alias) {
        "foundry" { @("resource", "update", "--ids", [string]$Resource.id, "--set", "properties.publicNetworkAccess=Disabled") }
        "storage" { @("storage", "account", "update", "--ids", [string]$Resource.id, "--public-network-access", "Disabled") }
        "ai-search" { @("search", "service", "update", "--ids", [string]$Resource.id, "--public-network-access", "disabled") }
        "cosmos" { @("cosmosdb", "update", "--ids", [string]$Resource.id, "--public-network-access", "Disabled") }
        "key-vault" {
            @(
                "keyvault", "update",
                "--name", [string]$Resource.name,
                "--resource-group", $ResourceGroupName,
                "--subscription", $ApprovedSubscriptionId,
                "--public-network-access", "Disabled"
            )
        }
        default { throw "Unsupported cutover alias: $Alias" }
    }

    $raw = & az @arguments --only-show-errors --output none 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Public-access update failed for $Alias.`n$($raw | Out-String)"
    }
}

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required and was not found on PATH."
}

$parameterText = Get-Content -LiteralPath $ParameterPath -Raw
$targets = @(
    [ordered]@{ Alias = "foundry"; Parameter = "foundryResourceId"; Type = "Microsoft.CognitiveServices/accounts" }
    [ordered]@{ Alias = "storage"; Parameter = "storageResourceId"; Type = "Microsoft.Storage/storageAccounts" }
    [ordered]@{ Alias = "ai-search"; Parameter = "searchResourceId"; Type = "Microsoft.Search/searchServices" }
    [ordered]@{ Alias = "cosmos"; Parameter = "cosmosResourceId"; Type = "Microsoft.DocumentDB/databaseAccounts" }
    [ordered]@{ Alias = "key-vault"; Parameter = "keyVaultResourceId"; Type = "Microsoft.KeyVault/vaults" }
)
$resources = @()
$seenIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($target in $targets) {
    $resourceId = Get-ParameterValue -Text $parameterText -Name $target.Parameter
    $resource = Invoke-AzJson -Arguments @("resource", "show", "--ids", $resourceId) -Description "$($target.Alias) lookup"
    $expectedPrefix = "/subscriptions/$ApprovedSubscriptionId/resourceGroups/$ResourceGroupName/providers/"
    if (
        -not ([string]$resource.id).StartsWith($expectedPrefix, [System.StringComparison]::OrdinalIgnoreCase) -or
        [string]$resource.type -ine [string]$target.Type -or
        -not $seenIds.Add([string]$resource.id)
    ) {
        throw "$($target.Alias) is outside the approved scope, has the wrong type, or duplicates another target."
    }
    $priorState = [string]$resource.properties.publicNetworkAccess
    if ([string]::IsNullOrWhiteSpace($priorState)) {
        throw "$($target.Alias) does not expose properties.publicNetworkAccess through the current API."
    }
    $resources += [pscustomobject]@{
        Alias = $target.Alias
        Resource = $resource
        PriorState = $priorState
    }
}

& (Join-Path $PSScriptRoot "connectivity-check.ps1") `
    -ParameterPath $ParameterPath `
    -TimeoutSeconds $TimeoutSeconds

Write-Host "Cutover scope: five approved nonproduction services."
Write-Host "Change record: $CutoverChangeReference"
$resources | Select-Object Alias, PriorState, @{ Name = "RequestedState"; Expression = { "Disabled" } } |
    Format-Table -AutoSize | Out-Host

if (-not $ConfirmPriorStateRecorded) {
    throw "Copy the displayed prior states into change record '$CutoverChangeReference' through the approved change process, then rerun with -ConfirmPriorStateRecorded."
}
if (-not $PSCmdlet.ShouldProcess(
    "five approved nonproduction services",
    "Add networkControlSession=$marker and disable public network access"
)) {
    Write-Host "No public-access changes were applied."
    return
}

foreach ($item in $resources) {
    $tagOutput = & az tag update `
        --resource-id $item.Resource.id `
        --operation Merge `
        --tags "networkControlSession=$marker" `
        --only-show-errors 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Tag update failed for $($item.Alias).`n$($tagOutput | Out-String)"
    }
    Set-PublicNetworkAccess -Alias $item.Alias -Resource $item.Resource
}

Write-Host "Cutover complete. The change record holds the prior states for the approved restore path."
