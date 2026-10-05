#Requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$TargetScope,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$BaselineFile = (Join-Path $PSScriptRoot '..\artifacts\fabric\tenant-settings-baseline.json')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Required command is unavailable: az"
}
if ($TargetScope -ne "one-approved-fabric-ai-grounding-lakehouse") {
    throw "TargetScope must be 'one-approved-fabric-ai-grounding-lakehouse'."
}
if (-not (Test-Path -LiteralPath $BaselineFile -PathType Leaf)) {
    throw "Tenant settings baseline file is missing: $BaselineFile"
}

$unresolved = @(Select-String -LiteralPath $BaselineFile -Pattern "__REQUIRED_[A-Z0-9_]+__" -AllMatches |
    ForEach-Object { $_.Matches.Value } |
    Sort-Object -Unique)
if ($unresolved.Count -gt 0) {
    throw "Resolve these tenant baseline decisions before reading Fabric settings: $($unresolved -join ', ')"
}

$baseline = Get-Content -LiteralPath $BaselineFile -Raw | ConvertFrom-Json -Depth 100
if ($baseline.implementationSession -ne "optional-module-fabric-purview-ai-data-governance") {
    throw "The baseline file has the wrong implementationSession marker."
}
if ($baseline.targetScope -ne $TargetScope) {
    throw "The baseline targetScope does not match the approved target scope."
}

$token = az account get-access-token --resource "https://api.fabric.microsoft.com" --query accessToken --output tsv --only-show-errors
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($token)) {
    throw "Could not get a Fabric API access token with Azure CLI."
}

$headers = @{ Authorization = "Bearer $token" }
$uri = "https://api.fabric.microsoft.com/v1/admin/tenantsettings"
$settings = @()
do {
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
    $settings += @($response.value)
    $continuationProperty = $response.PSObject.Properties["continuationUri"]
    $uri = if ($null -ne $continuationProperty) { [string]$continuationProperty.Value } else { $null }
} while (-not [string]::IsNullOrWhiteSpace($uri))

$settingsByTitle = @{}
foreach ($setting in $settings) {
    $settingsByTitle[[string]$setting.title] = $setting
}

$drift = @()
foreach ($expected in @($baseline.watchList)) {
    if (-not $settingsByTitle.ContainsKey([string]$expected.title)) {
        $drift += "Missing setting: $($expected.title)"
        continue
    }
    $actual = $settingsByTitle[[string]$expected.title]
    if ([bool]$actual.enabled -ne [bool]$expected.expectedEnabled) {
        $drift += "Enabled drift: $($expected.title)"
    }
    $expectedGroups = @($expected.expectedSecurityGroups | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object)
    $enabledGroupsProperty = $actual.PSObject.Properties["enabledSecurityGroups"]
    $actualGroups = @()
    if ($null -ne $enabledGroupsProperty -and $null -ne $enabledGroupsProperty.Value) {
        $actualGroups = @(
            $enabledGroupsProperty.Value |
                ForEach-Object { [string]$_.name } |
                Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
                Sort-Object -Unique
        )
    }

    $expectedScope = [string]$expected.expectedScope
    if ($expectedScope -eq "specific-security-groups") {
        $missingGroups = @($expectedGroups | Where-Object { $actualGroups -notcontains $_ })
        $extraGroups = @($actualGroups | Where-Object { $expectedGroups -notcontains $_ })
        if ($missingGroups.Count -gt 0 -or $extraGroups.Count -gt 0) {
            $drift += "Group scope drift: $($expected.title)"
        }
    }
    elseif ($expectedScope -eq "tenant") {
        if ($actualGroups.Count -gt 0) {
            $drift += "Tenant scope drift: $($expected.title)"
        }
    }
    else {
        $drift += "Unknown expectedScope '$expectedScope': $($expected.title)"
    }
}

if ($drift.Count -gt 0) {
    Write-Host "DRIFT: $($drift.Count) Copilot and AI tenant setting difference(s) found."
    foreach ($item in $drift) {
        Write-Host "- $item"
    }
    exit 2
}

Write-Host "PASS: Copilot and AI tenant settings match the recorded baseline."
