[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,

    [Parameter()]
    [string]$ArtifactsPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
if ([string]::IsNullOrWhiteSpace($ArtifactsPath)) {
    $ArtifactsPath = Join-Path $PSScriptRoot "..\artifacts"
}

$requiredFiles = @(
    "identity\human-role-assignments.bicep"
    "identity\workload-identity.bicep"
    "identity\role-definitions.json"
    "identity\role-to-task-matrix.md"
    "pim\pim-change-reference.md"
)
$requiredSentinels = @(
    "__REQUIRED_GITHUB_ENVIRONMENT__"
    "__REQUIRED_PIM_CHANGE_REFERENCE__"
    "__REQUIRED_PIM_OWNER__"
    "__REQUIRED_PLATFORM_ADMINISTRATOR_GROUP_REFERENCE__"
)
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required. Install it through the customer-managed tool process."
}
foreach ($relative in $requiredFiles) {
    if (-not (Test-Path (Join-Path $ArtifactsPath $relative) -PathType Leaf)) {
        throw "Required implementation file is missing: $relative"
    }
}
$matches = @(Get-ChildItem $ArtifactsPath -Recurse -File | Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__")
if ($matches.Count -gt 0) {
    $unresolved = @($matches.Matches.Value | Sort-Object -Unique)
    $unknown = @($unresolved | Where-Object { $_ -notin $requiredSentinels })
    $message = "Resolve identity decisions before deployment: $($unresolved -join ', ')."
    if ($unknown.Count -gt 0) { $message += " Add checks for new sentinels: $($unknown -join ', ')." }
    throw $message
}
$accountRaw = & az account show `
    --query "{subscriptionId:id,subscriptionName:name,tenantId:tenantId}" `
    --output json `
    --only-show-errors 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Azure account lookup failed.`n$($accountRaw | Out-String)"
}
$account = ($accountRaw | Out-String) | ConvertFrom-Json -ErrorAction Stop

$groupRaw = & az group show `
    --name $ResourceGroupName `
    --query "{id:id,location:location}" `
    --output json `
    --only-show-errors 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "The approved nonproduction resource group lookup failed for '$ResourceGroupName'.`n$($groupRaw | Out-String)"
}
$group = ($groupRaw | Out-String) | ConvertFrom-Json -ErrorAction Stop

Write-Host "Implementation target:"
Write-Host "  Subscription:   $($account.subscriptionName) ($($account.subscriptionId))"
Write-Host "  Resource group: $($group.id)"
Write-Host "  Location:       $($group.location)"

$roleDefinitionsPath = Join-Path $ArtifactsPath "identity\role-definitions.json"
$roleDocument = Get-Content -LiteralPath $roleDefinitionsPath -Raw |
    ConvertFrom-Json -ErrorAction Stop
$requiredRoleKeys = @(
    "foundryUser"
    "foundryProjectManager"
    "foundryAccountOwner"
    "reader"
    "cognitiveServicesUser"
    "storageBlobDataReader"
)
$expectedRoles = @{
    foundryUser = @{
        id = "53ca6127-db72-4b80-b1b0-d745d6d5456d"
        names = @("Foundry User", "Azure AI User")
    }
    foundryProjectManager = @{
        id = "eadc314b-1a2d-4efa-be10-5d325db5065e"
        names = @("Foundry Project Manager", "Azure AI Project Manager")
    }
    foundryAccountOwner = @{
        id = "e47c6f54-e4a2-4754-9501-8e0985b135e1"
        names = @("Foundry Account Owner", "Azure AI Account Owner")
    }
    reader = @{
        id = "acdd72a7-3385-48ef-bd42-f606fba81ae7"
        names = @("Reader")
    }
    cognitiveServicesUser = @{
        id = "a97b65f3-24c7-4388-baec-2e87135dc908"
        names = @("Cognitive Services User")
    }
    storageBlobDataReader = @{
        id = "2a2b9908-6ea1-4ae2-8e65-a410df84e7d1"
        names = @("Storage Blob Data Reader")
    }
}
if ($roleDocument.implementationSession -ne "02-identity-privileged-access") {
    throw "role-definitions.json has the wrong implementation marker."
}
$actualRoleKeys = @($roleDocument.roles.PSObject.Properties.Name)
if (
    $actualRoleKeys.Count -ne $requiredRoleKeys.Count -or
    @($requiredRoleKeys | Where-Object { $_ -notin $actualRoleKeys }).Count -gt 0
) {
    throw "role-definitions.json must contain the six documented role keys."
}

Write-Host "Role resolution:"
foreach ($key in $requiredRoleKeys) {
    $roleId = [string]$roleDocument.roles.$key.id
    $parsedRoleId = [guid]::Empty
    if (-not [guid]::TryParse($roleId, [ref]$parsedRoleId)) {
        throw "Role '$key' has an invalid ID in role-definitions.json."
    }
    if ($roleId -ine [string]$expectedRoles[$key].id) {
        throw "Role '$key' must use built-in role ID '$($expectedRoles[$key].id)', not '$roleId'."
    }
    $roleRaw = & az role definition list `
        --name $roleId `
        --query "[0].{id:name,displayName:roleName,roleType:roleType}" `
        --output json `
        --only-show-errors 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Role lookup failed for '$key'.`n$($roleRaw | Out-String)"
    }
    $role = ($roleRaw | Out-String) | ConvertFrom-Json -ErrorAction Stop
    if ($null -eq $role -or [string]$role.id -ne $roleId) {
        throw "Role '$key' did not resolve to the configured ID."
    }
    if ([string]$role.roleType -ine "BuiltInRole") {
        throw "Role '$key' must resolve to role type 'BuiltInRole', not '$($role.roleType)'."
    }
    if ([string]$role.displayName -notin @($expectedRoles[$key].names)) {
        throw "Role '$key' resolved to '$($role.displayName)'; expected '$($expectedRoles[$key].names -join "' or '")'."
    }
    Write-Host "  $key -> $($role.displayName) ($roleId, BuiltInRole)"
}

foreach ($file in @("human-role-assignments.bicep", "workload-identity.bicep")) {
    & az bicep build --file (Join-Path $ArtifactsPath "identity\$file") --stdout | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Bicep build failed: identity\$file" }
}
Write-Host "PASS: Session 02 tools, files, decisions, approved nonproduction resource group, role definitions, and Bicep syntax are ready."
