#Requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$MiddleTierEndpoint,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$PermittedTokenFile,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$DeniedTokenFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-CanonicalPath {
    param(
        [Parameter(Mandatory)]
        [string]$PathValue
    )

    return (Resolve-Path -LiteralPath $PathValue -ErrorAction Stop).Path
}

function Assert-OutsideRepository {
    param(
        [Parameter(Mandatory)]
        [string]$PathValue,

        [Parameter(Mandatory)]
        [string]$Label,

        [Parameter(Mandatory)]
        [string]$RepositoryRoot
    )

    $normalizedPath = [System.IO.Path]::GetFullPath($PathValue)
    $normalizedRoot = [System.IO.Path]::GetFullPath($RepositoryRoot)
    if ($normalizedPath -eq $normalizedRoot -or $normalizedPath.StartsWith($normalizedRoot + [System.IO.Path]::DirectorySeparatorChar)) {
        throw "$Label must be outside the repository: $normalizedPath"
    }
}

function Read-BearerToken {
    param(
        [Parameter(Mandatory)]
        [string]$PathValue,

        [Parameter(Mandatory)]
        [string]$Label
    )

    $token = (Get-Content -LiteralPath $PathValue -Raw -ErrorAction Stop).Trim()
    if ([string]::IsNullOrWhiteSpace($token)) {
        throw "$Label is empty: $PathValue"
    }
    return $token
}

function Invoke-OboCheck {
    param(
        [Parameter(Mandatory)]
        [string]$Endpoint,

        [Parameter(Mandatory)]
        [string]$Token
    )

    $headers = @{ Authorization = "Bearer $Token" }
    try {
        $response = Invoke-WebRequest -Uri $Endpoint -Method Get -Headers $headers -SkipHttpErrorCheck -ErrorAction Stop
    }
    catch {
        throw "HTTPS request failed: $($_.Exception.Message)"
    }

    $correlationId = [string]($response.Headers['x-correlation-id'])
    return [pscustomobject]@{
        StatusCode            = [int]$response.StatusCode
        CorrelationId         = $correlationId
        AuthorizationDecision = [string]($response.Headers['x-authorization-decision'])
    }
}

$uri = [Uri]$MiddleTierEndpoint
if (-not $uri.IsAbsoluteUri -or $uri.Scheme -ne 'https') {
    throw 'The middle-tier endpoint must be an absolute HTTPS URL.'
}

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
$permittedPath = Resolve-CanonicalPath -PathValue $PermittedTokenFile
$deniedPath = Resolve-CanonicalPath -PathValue $DeniedTokenFile

Assert-OutsideRepository -PathValue $permittedPath -Label 'The permitted token file' -RepositoryRoot $repositoryRoot
Assert-OutsideRepository -PathValue $deniedPath -Label 'The denied token file' -RepositoryRoot $repositoryRoot

$permittedResult = Invoke-OboCheck -Endpoint $MiddleTierEndpoint -Token (Read-BearerToken -PathValue $permittedPath -Label 'Permitted token file')
$deniedResult = Invoke-OboCheck -Endpoint $MiddleTierEndpoint -Token (Read-BearerToken -PathValue $deniedPath -Label 'Denied token file')

if ($permittedResult.StatusCode -lt 200 -or $permittedResult.StatusCode -gt 299) {
    throw "Permitted-path verification failed. Expected 2xx, received $($permittedResult.StatusCode)."
}
if ($deniedResult.StatusCode -notin @(401, 403)) {
    throw "Denied-path verification failed. Expected 401 or 403, received $($deniedResult.StatusCode)."
}
if ([string]::IsNullOrWhiteSpace($permittedResult.CorrelationId)) {
    throw 'Permitted-path verification did not return an x-correlation-id header.'
}
if ([string]::IsNullOrWhiteSpace($deniedResult.CorrelationId)) {
    throw 'Denied-path verification did not return an x-correlation-id header.'
}
if ($permittedResult.AuthorizationDecision -ne 'downstream-authorized') {
    throw 'Permitted-path verification did not reach downstream authorization.'
}
if ($deniedResult.AuthorizationDecision -ne 'downstream-denied') {
    throw 'Denied-path verification did not prove a downstream authorization denial.'
}

Write-Host "Permitted path: HTTP $($permittedResult.StatusCode) (x-correlation-id=$($permittedResult.CorrelationId))."
Write-Host "Denied path: HTTP $($deniedResult.StatusCode) (x-correlation-id=$($deniedResult.CorrelationId))."
