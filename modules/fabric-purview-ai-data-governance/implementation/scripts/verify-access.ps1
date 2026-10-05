#Requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$TargetScope,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$RoleFile = (Join-Path $PSScriptRoot '..\artifacts\fabric\onelake-ai-consumer-role.json')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Required command is unavailable: az"
}
if ($TargetScope -ne "one-approved-fabric-ai-grounding-lakehouse") {
    throw "TargetScope must be 'one-approved-fabric-ai-grounding-lakehouse'."
}
if (-not (Test-Path -LiteralPath $RoleFile -PathType Leaf)) {
    throw "OneLake role file is missing: $RoleFile"
}

$unresolved = @(Select-String -LiteralPath $RoleFile -Pattern "__REQUIRED_[A-Z0-9_]+__" -AllMatches |
    ForEach-Object { $_.Matches.Value } |
    Sort-Object -Unique)
if ($unresolved.Count -gt 0) {
    throw "Resolve these OneLake decisions before reading live roles: $($unresolved -join ', ')"
}

$record = Get-Content -LiteralPath $RoleFile -Raw | ConvertFrom-Json -Depth 100
$workspaceId = [string]$record.fabric.workspaceId
$itemId = [string]$record.fabric.lakehouseItemId
$expectedGroup = [string]$record.accessBoundary.aiConsumerGroupObjectId
$restrictedGroup = [string]$record.accessBoundary.restrictedConsumerGroupObjectId

$token = az account get-access-token --resource "https://api.fabric.microsoft.com" --query accessToken --output tsv --only-show-errors
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($token)) {
    throw "Could not get a Fabric API access token with Azure CLI."
}

$headers = @{ Authorization = "Bearer $token" }
$uri = "https://api.fabric.microsoft.com/v1/workspaces/$workspaceId/items/$itemId/dataAccessRoles"
$roles = @()
do {
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
    $roles += @($response.value)
    $continuationProperty = $response.PSObject.Properties["continuationUri"]
    $uri = if ($null -ne $continuationProperty) { [string]$continuationProperty.Value } else { $null }
} while (-not [string]::IsNullOrWhiteSpace($uri))

$role = $roles | Where-Object { $_.name -eq "AiGroundingConsumerRead" } | Select-Object -First 1
if ($null -eq $role) {
    throw "Live OneLake role AiGroundingConsumerRead was not found."
}

$membersProperty = $role.members.PSObject.Properties["microsoftEntraMembers"]
$members = @()
if ($null -ne $membersProperty -and $null -ne $membersProperty.Value) {
    $members = @($membersProperty.Value)
}
if (-not ($members | Where-Object { $_.objectId -eq $expectedGroup -and $_.objectType -eq "Group" })) {
    throw "Live OneLake role does not include the approved AI consumer group."
}
if ($members | Where-Object { $_.objectId -eq $restrictedGroup }) {
    throw "Restricted consumer group is a member of the AI grounding role."
}
if (@($record.accessBoundary.restrictedPrincipalsRemovedFromDefaultReader) -notcontains $restrictedGroup) {
    throw "The DefaultReader review does not record removal of the restricted consumer group."
}

Write-Host "PASS: live OneLake role includes the approved AI consumer group and excludes the restricted group."
Write-Host "NEXT: run the intended-path and blocked-path identity checks in access-check-plan.json with the delivery owner present."
