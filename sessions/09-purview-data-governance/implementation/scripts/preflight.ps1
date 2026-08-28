[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")]
    [string]$ApprovedTenantId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

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
            throw "coverage-handoff.md contains raw HTML outside fenced code."
        }
        $visible.Add($line)
    }

    if ($inFence) {
        throw "coverage-handoff.md contains an unclosed fenced code block."
    }
    if ([regex]::IsMatch(($visible -join "`n"), $htmlTagPattern)) {
        throw "coverage-handoff.md contains raw HTML outside fenced code."
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
        throw "coverage-handoff.md is missing heading '$Heading'."
    }
    if ($indexes.Count -gt 1) {
        throw "coverage-handoff.md contains duplicate heading '$Heading'."
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

    $headerFirst = "Field"
    $headerSecond = "Decision"
    if ($Heading -ceq "## Purview entitlements") {
        $headerFirst = "Capability"
        $headerSecond = "Status"
    }
    $headerPattern = "^\|\s*$([regex]::Escape($headerFirst))\s*\|\s*$([regex]::Escape($headerSecond))\s*\|\s*$"
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
        throw "coverage-handoff.md section '$Heading' is missing field '$Field'."
    }
    if ($values.Count -gt 1) {
        throw "coverage-handoff.md section '$Heading' contains duplicate field '$Field'."
    }

    $value = $values[0]
    if ($value.Length -ge 2 -and
        $value[0] -eq [char]96 -and
        $value[$value.Length - 1] -eq [char]96) {
        $value = $value.Substring(1, $value.Length - 2).Trim()
    }
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "coverage-handoff.md field '$Field' in section '$Heading' is empty."
    }
    return $value
}

function Assert-MarkdownValue {
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]]$Section,
        [Parameter(Mandatory)][string]$Field,
        [Parameter(Mandatory)][string]$Expected,
        [Parameter(Mandatory)][string]$Heading
    )

    $actual = Get-MarkdownField -Section $Section -Field $Field -Heading $Heading
    if ($actual -cne $Expected) {
        throw "coverage-handoff.md field '$Field' in section '$Heading' must be '$Expected', not '$actual'."
    }
}

function Assert-MarkdownDate {
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]]$Section,
        [Parameter(Mandatory)][string]$Field,
        [Parameter(Mandatory)][string]$Heading
    )

    $value = Get-MarkdownField -Section $Section -Field $Field -Heading $Heading
    $parsed = [datetime]::MinValue
    if (-not [datetime]::TryParseExact(
            $value,
            "yyyy-MM-dd",
            [Globalization.CultureInfo]::InvariantCulture,
            [Globalization.DateTimeStyles]::None,
            [ref]$parsed
        )) {
        throw "coverage-handoff.md field '$Field' in section '$Heading' must be a real yyyy-mm-dd date."
    }
}

$artifactRoot = Join-Path $PSScriptRoot "..\artifacts"
$coverageHandoffPath = Join-Path $artifactRoot "governance\coverage-handoff.md"
$auditPath = Join-Path $artifactRoot "operations\agent-activity-audit-query.json"

$requiredPaths = @(
    $coverageHandoffPath,
    $auditPath
)
foreach ($path in $requiredPaths) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required implementation artifact is missing: $path"
    }
}

$requiredDecisionSentinels = @(
    "__REQUIRED_AGENT365_LICENSE_STATUS__",
    "__REQUIRED_AGENT_INSTANCE_ALIAS__",
    "__REQUIRED_AGENT_INSTANCE_ID__",
    "__REQUIRED_AGENT_LABEL_RIGHTS_STATUS__",
    "__REQUIRED_AGENT_OWNER_ROLE__",
    "__REQUIRED_AUDIT_ENTITLEMENT__",
    "__REQUIRED_AUDIT_OWNER_ROLE__",
    "__REQUIRED_COVERAGE_REVIEW_DATE__",
    "__REQUIRED_DATA_CLASSIFICATION__",
    "__REQUIRED_DATA_OWNER_ROLE__",
    "__REQUIRED_DLP_ACTION__",
    "__REQUIRED_DLP_ENTITLEMENT__",
    "__REQUIRED_DLP_INCIDENT_OWNER_ROLE__",
    "__REQUIRED_DLP_NOTIFICATION_DECISION__",
    "__REQUIRED_DLP_NAME_AVAILABILITY_STATUS__",
    "__REQUIRED_DLP_NAME_VERIFIED_DATE__",
    "__REQUIRED_DLP_POLICY_NAME__",
    "__REQUIRED_DLP_PROPAGATION_HOURS__",
    "__REQUIRED_DSPM_ENTITLEMENT__",
    "__REQUIRED_E5_STATUS__",
    "__REQUIRED_EDISCOVERY_ENTITLEMENT__",
    "__REQUIRED_FINDINGS_DATE__",
    "__REQUIRED_FOUNDRY_AUDIT_STATUS__",
    "__REQUIRED_FOUNDRY_ENABLEMENT_ROUTE__",
    "__REQUIRED_FOUNDRY_PURVIEW_STATUS__",
    "__REQUIRED_FOUNDRY_SUBSCRIPTION_ALIAS__",
    "__REQUIRED_FOUNDRY_USER_CONTEXT_STATUS__",
    "__REQUIRED_GENERATED_CONTENT_COMPENSATING_CONTROL__",
    "__REQUIRED_GENERATED_CONTENT_DECISION__",
    "__REQUIRED_GENERATED_CONTENT_LABEL_OBSERVATION__",
    "__REQUIRED_GENERATED_CONTENT_SUMMARY__",
    "__REQUIRED_INFORMATION_PROTECTION_OWNER_ROLE__",
    "__REQUIRED_LABELLED_SYNTHETIC_ITEM_ALIAS__",
    "__REQUIRED_LABEL_ENCRYPTION_DECISION__",
    "__REQUIRED_LABEL_IDENTITY_STATUS__",
    "__REQUIRED_LABEL_IDENTITY_VERIFIED_DATE__",
    "__REQUIRED_LABEL_POLICY_SCOPE_ALIAS__",
    "__REQUIRED_OVERSHARING_DECISION__",
    "__REQUIRED_OVERSHARING_SUMMARY__",
    "__REQUIRED_PURVIEW_OPERATOR_ROLE__",
    "__REQUIRED_PURVIEW_PAYG_STATUS__",
    "__REQUIRED_SENSITIVE_GROUNDING_DECISION__",
    "__REQUIRED_SENSITIVE_GROUNDING_SUMMARY__",
    "__REQUIRED_SENSITIVITY_LABEL_ID__",
    "__REQUIRED_SENSITIVITY_LABEL_NAME__",
    "__REQUIRED_SHAREPOINT_LABEL_SUPPORT_STATUS__",
    "__REQUIRED_SOURCE_EXPIRY_DATE__",
    "__REQUIRED_SOURCE_REVIEW_DATE__",
    "__REQUIRED_SYNTHETIC_SOURCE_ALIAS__",
    "__REQUIRED_TEST_GROUP_ALIAS__"
)
$sentinels = @(Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
    Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__"
)
if ($sentinels.Count -gt 0) {
    $unresolved = @($sentinels.Matches.Value | Sort-Object -Unique)
    $unknown = @($unresolved | Where-Object { $_ -notin $requiredDecisionSentinels })
    if ($unknown.Count -gt 0) {
        throw "Add explicit Session 09 preflight checks for new sentinels: $($unknown -join ', ')."
    }
    $locations = $sentinels |
        ForEach-Object { "$($_.Path):$($_.LineNumber) $($_.Matches.Value)" } |
        Sort-Object -Unique
    throw "Resolve every required customer decision before tenant changes:`n$($locations -join "`n")"
}

function Read-JsonArtifact {
    param([Parameter(Mandatory)][string]$Path)

    return Get-Content -LiteralPath $Path -Raw |
        ConvertFrom-Json -ErrorAction Stop
}

$audit = Read-JsonArtifact -Path $auditPath

$summaryHeading = "# Purview coverage handoff"
$verificationHeading = "## Verification boundary"
$agentHeading = "### Microsoft Agent 365"
$foundryHeading = "### Microsoft Foundry"
$entitlementsHeading = "## Purview entitlements"
$labelHeading = "## Sensitivity label"
$sourceHeading = "## Source access"
$dlpHeading = "## DLP policy"

$coverageLines = @(Get-MarkdownVisibleLines -Path $coverageHandoffPath)
$summary = @(Get-MarkdownSection -Lines $coverageLines -Heading $summaryHeading)
$verification = @(Get-MarkdownSection -Lines $coverageLines -Heading $verificationHeading)
$agent = @(Get-MarkdownSection -Lines $coverageLines -Heading $agentHeading)
$foundry = @(Get-MarkdownSection -Lines $coverageLines -Heading $foundryHeading)
$entitlements = @(Get-MarkdownSection -Lines $coverageLines -Heading $entitlementsHeading)
$label = @(Get-MarkdownSection -Lines $coverageLines -Heading $labelHeading)
$source = @(Get-MarkdownSection -Lines $coverageLines -Heading $sourceHeading)
$dlp = @(Get-MarkdownSection -Lines $coverageLines -Heading $dlpHeading)

Assert-MarkdownValue -Section $summary -Field "Target scope" `
    -Expected "Approved nonproduction Microsoft 365 tenant" -Heading $summaryHeading
Assert-MarkdownValue -Section $agent -Field "Qualifying license" `
    -Expected "Confirmed" -Heading $agentHeading
$e5Status = Get-MarkdownField -Section $agent -Field "E5 prerequisite" -Heading $agentHeading
if (@("Confirmed", "ExceptionApproved") -cnotcontains $e5Status) {
    throw "The E5 prerequisite must be Confirmed or ExceptionApproved."
}
Assert-MarkdownValue -Section $foundry -Field "Purview Data Security status" `
    -Expected "Enabled" -Heading $foundryHeading
$enablementRoute = Get-MarkdownField -Section $foundry -Field "Enablement route" -Heading $foundryHeading
if (@("FoundryControlPlane", "DefenderForCloud") -cnotcontains $enablementRoute) {
    throw "The Foundry enablement route must be FoundryControlPlane or DefenderForCloud."
}
Assert-MarkdownValue -Section $foundry -Field "Pay-as-you-go policy billing" `
    -Expected "Approved" -Heading $foundryHeading
Assert-MarkdownValue -Section $foundry -Field "Audit license status" `
    -Expected "Confirmed" -Heading $foundryHeading
$userContext = Get-MarkdownField -Section $foundry -Field "User context status" -Heading $foundryHeading
if (@("Implemented", "DocumentedGap") -cnotcontains $userContext) {
    throw "The Foundry user context status must be Implemented or DocumentedGap."
}
foreach ($entitlement in @("DSPM", "Data Loss Prevention", "Audit", "eDiscovery")) {
    Assert-MarkdownValue -Section $entitlements -Field $entitlement `
        -Expected "Confirmed" -Heading $entitlementsHeading
}

$labelId = Get-MarkdownField -Section $label -Field "Label ID" -Heading $labelHeading
if ($labelId -notmatch "^[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$") {
    throw "The sensitivity label ID must be a GUID."
}
Assert-MarkdownValue -Section $label -Field "SharePoint and OneDrive label support" `
    -Expected "Enabled" -Heading $labelHeading
$encryption = Get-MarkdownField -Section $label -Field "Encryption decision" -Heading $labelHeading
if (@("Encrypted", "NotEncrypted") -cnotcontains $encryption) {
    throw "The label encryption decision must be Encrypted or NotEncrypted."
}
$rights = Get-MarkdownField -Section $label `
    -Field "Agent instance VIEW and EXTRACT rights" -Heading $labelHeading
if ($encryption -eq "Encrypted" -and $rights -cne "Confirmed") {
    throw "An encrypted label requires Confirmed VIEW and EXTRACT rights."
}
if ($encryption -ceq "NotEncrypted" -and @("Confirmed", "NotApplicable") -cnotcontains $rights) {
    throw "A non-encrypted label requires VIEW and EXTRACT rights to be Confirmed or NotApplicable."
}
Assert-MarkdownValue -Section $label -Field "Generated content inherits the source label" `
    -Expected "No" -Heading $labelHeading
$null = Get-MarkdownField -Section $label -Field "Generated-content observation" -Heading $labelHeading
$null = Get-MarkdownField -Section $label -Field "Compensating control" -Heading $labelHeading

Assert-MarkdownValue -Section $verification -Field "Label identity status" `
    -Expected "Confirmed" -Heading $verificationHeading
Assert-MarkdownDate -Section $verification -Field "Label identity verified on" -Heading $verificationHeading
Assert-MarkdownValue -Section $verification -Field "DLP policy name availability status" `
    -Expected "Available" -Heading $verificationHeading
Assert-MarkdownDate -Section $verification -Field "DLP policy name verified on" -Heading $verificationHeading

Assert-MarkdownValue -Section $source -Field "Synthetic only" -Expected "Yes" -Heading $sourceHeading
$agentAlias = Get-MarkdownField -Section $agent -Field "Agent instance alias" -Heading $agentHeading
$sourceAgentAlias = Get-MarkdownField -Section $source -Field "Agent instance alias" -Heading $sourceHeading
$dlpAgentAlias = Get-MarkdownField -Section $dlp -Field "Agent instance alias" -Heading $dlpHeading
if ($agentAlias -cne $sourceAgentAlias -or $agentAlias -cne $dlpAgentAlias) {
    throw "The Microsoft Agent 365, Source access, and DLP policy sections must use the same agent instance alias."
}
$sourceLabelId = Get-MarkdownField -Section $source -Field "Sensitivity label ID" -Heading $sourceHeading
if ($sourceLabelId -cne $labelId) {
    throw "The source and sensitivity-label sections must use the same label ID."
}

Assert-MarkdownValue -Section $dlp -Field "Environment" -Expected "Nonproduction" -Heading $dlpHeading
Assert-MarkdownValue -Section $dlp -Field "Description" `
    -Expected "implementationSession=09-purview-data-governance" -Heading $dlpHeading
Assert-MarkdownValue -Section $dlp -Field "Initial mode" `
    -Expected "TestWithNotifications" -Heading $dlpHeading
Assert-MarkdownValue -Section $dlp -Field "Final mode" -Expected "Enable" -Heading $dlpHeading
$dlpAction = Get-MarkdownField -Section $dlp -Field "Action" -Heading $dlpHeading
if (@("Block", "Audit") -cnotcontains $dlpAction) {
    throw "The DLP action must be Block or Audit."
}
$propagationText = Get-MarkdownField -Section $dlp `
    -Field "Propagation allowance in hours" -Heading $dlpHeading
$propagation = 0
if (-not [int]::TryParse($propagationText, [ref]$propagation) -or
    $propagation -lt 1 -or $propagation -gt 24) {
    throw "The DLP propagation allowance must be an integer from 1 through 24 hours."
}
$directions = @((Get-MarkdownField -Section $dlp `
    -Field "Supported interaction directions" -Heading $dlpHeading).Split(";") |
    ForEach-Object { $_.Trim() })
if (($directions -join "`n") -cne (@("Human-to-agent", "agent-to-human") -join "`n")) {
    throw "The DLP policy must retain both supported interaction directions."
}
$locations = @((Get-MarkdownField -Section $dlp `
    -Field "Supported locations" -Heading $dlpHeading).Split(";") |
    ForEach-Object { $_.Trim() })
if (($locations -join "`n") -cne
    (@("Microsoft Teams", "OneDrive or SharePoint", "Exchange email") -join "`n")) {
    throw "The DLP policy must retain exactly the three documented locations."
}
$ruleLabelId = Get-MarkdownField -Section $dlp -Field "Rule label ID" -Heading $dlpHeading
if ($ruleLabelId -cne $labelId) {
    throw "The DLP rule and sensitivity-label sections must use the same label ID."
}
$dlpAgentInstanceId = Get-MarkdownField -Section $dlp -Field "Agent instance ID" -Heading $dlpHeading
$null = Get-MarkdownField -Section $dlp -Field "Policy name" -Heading $dlpHeading

$marker = "09-purview-data-governance"
$requiredOperations = @("AIInvokeAgent", "AIExecuteTool", "AIInferenceCall", "AIGuardrail")
if ([int]$audit.schemaVersion -ne 1 -or
    [string]$audit.implementationSession -cne $marker -or
    [string]$audit.microsoftGraphApplicationPermission -ne "AuditLogsQuery.Read.All" -or
    [string]$audit.agentInstanceId -cne $dlpAgentInstanceId -or
    [string]::IsNullOrWhiteSpace([string]$audit.ownerRole) -or
    (@($audit.operations | Sort-Object) -join ",") -cne
        (@($requiredOperations | Sort-Object) -join ",")) {
    throw "The audit query structure, DLP agent instance binding, or required Agent 365 operations are invalid."
}
$requiredOutputFields = @("CreationDate", "Operation", "AgentId", "AgentName", "ResultStatus")
if ((@($audit.safeOutputFields | Sort-Object) -join ",") -cne
    (@($requiredOutputFields | Sort-Object) -join ",")) {
    throw "The audit query must keep the approved payload-free output fields."
}
if (@($audit.excludedContent).Count -lt 1) {
    throw "The audit query must name the content excluded from its output."
}
$lookbackHours = $audit.lookbackHours
if (($lookbackHours -isnot [int] -and $lookbackHours -isnot [long]) -or
    [long]$lookbackHours -lt 1 -or [long]$lookbackHours -gt 168) {
    throw "Audit lookbackHours must be between 1 and 168."
}
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required to acquire the Microsoft Graph application token."
}
$graphToken = & az account get-access-token `
    --tenant $ApprovedTenantId `
    --scope "https://graph.microsoft.com/.default" `
    --query accessToken `
    --output tsv `
    --only-show-errors
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($graphToken)) {
    throw "Unable to acquire the Microsoft Graph application token used for Audit Search."
}
$payloadPart = $graphToken.Split(".")[1].Replace("-", "+").Replace("_", "/")
while ($payloadPart.Length % 4 -ne 0) { $payloadPart += "=" }
$tokenPayload = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($payloadPart)) |
    ConvertFrom-Json -ErrorAction Stop
if (@($tokenPayload.roles) -notcontains "AuditLogsQuery.Read.All") {
    throw "The Microsoft Graph application token must include AuditLogsQuery.Read.All with administrator consent."
}
if ([string]$tokenPayload.tid -ne $ApprovedTenantId) {
    throw "The Microsoft Graph application token does not identify the approved tenant."
}
Write-Host "PASS: Session 09 Markdown safety decisions, DLP and audit bindings, approved tenant, and AuditLogsQuery.Read.All token are ready."
