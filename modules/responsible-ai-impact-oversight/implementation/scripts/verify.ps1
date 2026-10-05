#Requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovalGateEndpoint,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovedPayloadFile,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$RejectedPayloadFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-CanonicalPath {
    param([Parameter(Mandatory)][string]$PathValue)
    return (Resolve-Path -LiteralPath $PathValue -ErrorAction Stop).Path
}

function Assert-OutsideRepository {
    param(
        [Parameter(Mandatory)][string]$PathValue,
        [Parameter(Mandatory)][string]$Label,
        [Parameter(Mandatory)][string]$RepositoryRoot
    )
    $normalizedPath = [System.IO.Path]::GetFullPath($PathValue)
    $normalizedRoot = [System.IO.Path]::GetFullPath($RepositoryRoot)
    if ($normalizedPath -eq $normalizedRoot -or $normalizedPath.StartsWith($normalizedRoot + [System.IO.Path]::DirectorySeparatorChar)) {
        throw "$Label must be outside the repository: $normalizedPath"
    }
}

function Invoke-JsonPost {
    param(
        [Parameter(Mandatory)][string]$Uri,
        [Parameter(Mandatory)][object]$Body,
        [Parameter(Mandatory)][string]$BearerToken
    )
    $headers = @{ Accept = "application/json" }
    $headers.Authorization = "Bearer $BearerToken"
    $response = Invoke-WebRequest `
        -Uri $Uri `
        -Method Post `
        -Headers $headers `
        -ContentType "application/json" `
        -Body ($Body | ConvertTo-Json -Depth 50) `
        -SkipHttpErrorCheck `
        -ErrorAction Stop
    $content = if ([string]::IsNullOrWhiteSpace($response.Content)) {
        [pscustomobject]@{}
    }
    else {
        $response.Content | ConvertFrom-Json -ErrorAction Stop
    }
    return [pscustomobject]@{
        StatusCode = [int]$response.StatusCode
        Headers = $response.Headers
        Body = $content
    }
}

function Get-Decision {
    param([Parameter(Mandatory)][object]$Result)
    $header = [string]($Result.Headers["x-oversight-decision"])
    if (-not [string]::IsNullOrWhiteSpace($header)) {
        return $header
    }
    return [string]$Result.Body.oversightDecision
}

$endpoint = [Uri]$ApprovalGateEndpoint
if (-not $endpoint.IsAbsoluteUri -or $endpoint.Scheme -ne "https") {
    throw "ApprovalGateEndpoint must be an absolute HTTPS URL."
}
$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$approvedPayloadPath = Resolve-CanonicalPath -PathValue $ApprovedPayloadFile
$rejectedPayloadPath = Resolve-CanonicalPath -PathValue $RejectedPayloadFile
Assert-OutsideRepository -PathValue $approvedPayloadPath -Label "Approved payload file" -RepositoryRoot $repositoryRoot
Assert-OutsideRepository -PathValue $rejectedPayloadPath -Label "Rejected payload file" -RepositoryRoot $repositoryRoot

$approvedPayload = Get-Content -LiteralPath $approvedPayloadPath -Raw | ConvertFrom-Json -ErrorAction Stop
$rejectedPayload = Get-Content -LiteralPath $rejectedPayloadPath -Raw | ConvertFrom-Json -ErrorAction Stop
$requesterToken = [Environment]::GetEnvironmentVariable("OVERSIGHT_VERIFY_REQUESTER_BEARER_TOKEN")
$approverToken = [Environment]::GetEnvironmentVariable("OVERSIGHT_VERIFY_APPROVER_BEARER_TOKEN")
if ([string]::IsNullOrWhiteSpace($requesterToken)) {
    throw "Set OVERSIGHT_VERIFY_REQUESTER_BEARER_TOKEN for the authenticated requester."
}
if ([string]::IsNullOrWhiteSpace($approverToken)) {
    throw "Set OVERSIGHT_VERIFY_APPROVER_BEARER_TOKEN for the authenticated approver."
}
if ($requesterToken -eq $approverToken) {
    throw "Requester and approver tokens must be distinct so the check cannot pass through self-approval."
}
$baseUri = $endpoint.AbsoluteUri.TrimEnd("/")
$startUri = "$baseUri/approval/start"
$resumeUri = "$baseUri/approval/resume"

$approvedStart = Invoke-JsonPost -Uri $startUri -Body $approvedPayload -BearerToken $requesterToken
if ($approvedStart.StatusCode -notin @(200, 202) -or $approvedStart.Body.status -ne "awaiting_approval") {
    throw "Approved-path start did not return awaiting_approval."
}
$approvedResume = Invoke-JsonPost -Uri $resumeUri -Body @{
    taskId = [string]$approvedStart.Body.taskId
    decision = "approved"
} -BearerToken $approverToken
if ($approvedResume.StatusCode -lt 200 -or $approvedResume.StatusCode -gt 299) {
    throw "Approved-path resume failed with HTTP $($approvedResume.StatusCode)."
}
if (-not [bool]$approvedResume.Body.toolExecuted -or (Get-Decision -Result $approvedResume) -ne "approved-executed") {
    throw "Approved-path verification did not execute the tool."
}
if ([string]::IsNullOrWhiteSpace([string]$approvedResume.Body.correlationId)) {
    throw "Approved-path verification did not return a correlation ID."
}

$rejectedStart = Invoke-JsonPost -Uri $startUri -Body $rejectedPayload -BearerToken $requesterToken
if ($rejectedStart.StatusCode -notin @(200, 202) -or $rejectedStart.Body.status -ne "awaiting_approval") {
    throw "Rejected-path start did not return awaiting_approval."
}
$rejectedResume = Invoke-JsonPost -Uri $resumeUri -Body @{
    taskId = [string]$rejectedStart.Body.taskId
    decision = "rejected"
} -BearerToken $approverToken
if ($rejectedResume.StatusCode -lt 200 -or $rejectedResume.StatusCode -gt 299) {
    throw "Rejected-path resume failed with HTTP $($rejectedResume.StatusCode)."
}
if ([bool]$rejectedResume.Body.toolExecuted -or (Get-Decision -Result $rejectedResume) -ne "rejected-not-executed") {
    throw "Rejected-path verification executed the tool or returned the wrong decision."
}
if ([string]::IsNullOrWhiteSpace([string]$rejectedResume.Body.correlationId)) {
    throw "Rejected-path verification did not return a correlation ID."
}

Write-Host "Approved path: tool executed after approval (correlationId=$($approvedResume.Body.correlationId))."
Write-Host "Rejected path: tool did not execute after rejection (correlationId=$($rejectedResume.Body.correlationId))."
