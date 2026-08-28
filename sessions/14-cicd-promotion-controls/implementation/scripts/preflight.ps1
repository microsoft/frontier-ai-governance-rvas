[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet("Decisions", "Ready")]
    [string]$Phase = "Ready",

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovedNonproductionScope,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovedProductionScope,

    [Parameter(Mandatory)]
    [ValidatePattern("^[0-9a-f]{40}$")]
    [string]$ApprovedReleaseSha,

    [Parameter()]
    [string]$BaselineRecordPath,

    [Parameter()]
    [string]$CandidateRecordPath,

    [Parameter()]
    [string]$SecurityReleaseAttestationPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$sessionRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$repoRoot = Resolve-Path (Join-Path $sessionRoot "..\..")
$artifactRoot = Join-Path $sessionRoot "implementation\artifacts"
$controlPath = Join-Path $artifactRoot "control-definition.json"
$validatorPath = Join-Path $artifactRoot "pipeline\validate-release.ps1"
$nonproductionParametersPath = Join-Path $artifactRoot "environments\nonproduction.parameters.json"
$productionParametersPath = Join-Path $artifactRoot "environments\production.parameters.json"

$coveredDecisionSentinels = @(
    "__REQUIRED_ACTIONS_CHECKOUT_FULL_SHA__",
    "__REQUIRED_ACTIONS_SETUP_PYTHON_FULL_SHA__",
    "__REQUIRED_ADMIN_BYPASS_DISABLED_TRUE__",
    "__REQUIRED_AGENT_NAME_OR_ID__",
    "__REQUIRED_AGENT_VERSION__",
    "__REQUIRED_APIM_POLICY_PATH__",
    "__REQUIRED_APIM_POLICY_VERSION__",
    "__REQUIRED_APPROVED_RELEASE_STORE__",
    "__REQUIRED_AZURE_LOGIN_FULL_SHA__",
    "__REQUIRED_AZURE_TENANT_ID__",
    "__REQUIRED_BICEP_ENTRYPOINT_PATH__",
    "__REQUIRED_CANDIDATE_ROUTING_SELECTOR__",
    "__REQUIRED_EVALUATION_RUN_ID__",
    "__REQUIRED_EVALUATION_THRESHOLD_POLICY_SHA256__",
    "__REQUIRED_EVALUATION_THRESHOLD_POLICY_VERSION__",
    "__REQUIRED_EXISTING_ROUTING_SUPPORT_CONFIRMED_TRUE_OR_FALSE__",
    "__REQUIRED_GITHUB_OWNER__",
    "__REQUIRED_GITHUB_REPOSITORY__",
    "__REQUIRED_MODEL_DEPLOYMENT_VERSION_ALIAS__",
    "__REQUIRED_NONPRODUCTION_FEDERATED_CREDENTIAL_NAME__",
    "__REQUIRED_NONPRODUCTION_EXACT_OIDC_SUBJECT__",
    "__REQUIRED_NONPRODUCTION_PREVIEW_FEDERATED_CREDENTIAL_NAME__",
    "__REQUIRED_NONPRODUCTION_PREVIEW_EXACT_OIDC_SUBJECT__",
    "__REQUIRED_NONPRODUCTION_PREVENT_SELF_REVIEW_TRUE__",
    "__REQUIRED_NONPRODUCTION_REVIEWER_TEAM_SLUG__",
    "__REQUIRED_NONPRODUCTION_AZURE_CLIENT_ID__",
    "__REQUIRED_NONPRODUCTION_RESOURCE_GROUP__",
    "__REQUIRED_NONPRODUCTION_SUBSCRIPTION_ID__",
    "__REQUIRED_PREVENT_SELF_REVIEW_TRUE__",
    "__REQUIRED_PRODUCTION_BRANCH_OR_TAG_RESTRICTION__",
    "__REQUIRED_PRODUCTION_AZURE_CLIENT_ID__",
    "__REQUIRED_PRODUCTION_ENVIRONMENT_PLAN_SUPPORT_CONFIRMED_TRUE__",
    "__REQUIRED_PRODUCTION_FEDERATED_CREDENTIAL_NAME__",
    "__REQUIRED_PRODUCTION_EXACT_OIDC_SUBJECT__",
    "__REQUIRED_PRODUCTION_PREVIEW_FEDERATED_CREDENTIAL_NAME__",
    "__REQUIRED_PRODUCTION_PREVIEW_EXACT_OIDC_SUBJECT__",
    "__REQUIRED_PRODUCTION_REVIEWER_TEAM_SLUG__",
    "__REQUIRED_PRODUCTION_RESOURCE_GROUP__",
    "__REQUIRED_PRODUCTION_REVIEWER_ROLE__",
    "__REQUIRED_PRODUCTION_SUBSCRIPTION_ID__",
    "__REQUIRED_PROMPT_VERSION__",
    "__REQUIRED_PROTECTED_DEFAULT_BRANCH__",
    "__REQUIRED_RELEASE_STORE_SCRIPT_PATH__",
    "__REQUIRED_ROUTING_CONTROL_SCRIPT_PATH__",
    "__REQUIRED_ROUTING_STRATEGY_CANARY_OR_BLUE_GREEN__",
    "__REQUIRED_STABLE_ROUTING_SELECTOR__",
    "__REQUIRED_UNIT_TEST_SCRIPT_PATH__"
)

function Read-JsonObject {
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required JSON file is missing: $Path"
    }
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -ErrorAction Stop
}

function Get-TrustedGitHubRemote {
    param(
        [Parameter(Mandatory)][string]$RemoteUrl,
        [Parameter(Mandatory)][string]$HostName,
        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][string]$RepositoryName
    )

    if ($HostName -cne "github.com" -or
        $Owner -notmatch "^[A-Za-z0-9_.-]+$" -or
        $RepositoryName -notmatch "^[A-Za-z0-9_.-]+$") {
        throw "The approved GitHub host, owner, or repository name is invalid."
    }
    $expectedPath = "$Owner/$RepositoryName"
    $uri = $null
    if ([uri]::TryCreate($RemoteUrl, [UriKind]::Absolute, [ref]$uri) -and
        [string]$uri.Scheme -ceq "https") {
        $path = $uri.AbsolutePath.TrimStart("/")
        if (-not $RemoteUrl.StartsWith(
                "https://$HostName/",
                [StringComparison]::OrdinalIgnoreCase
            ) -or
            [string]$uri.Host -ine $HostName -or
            [string]$uri.Authority -ine $HostName -or
            -not [string]::IsNullOrEmpty($uri.UserInfo) -or
            -not [string]::IsNullOrEmpty($uri.Query) -or
            -not [string]::IsNullOrEmpty($uri.Fragment) -or
            ($path -ine $expectedPath -and $path -ine "$expectedPath.git")) {
            throw "Repository origin must use the exact approved GitHub HTTPS host and path."
        }
        return "https://$HostName/$Owner/$RepositoryName.git"
    }
    $sshMatch = [regex]::Match(
        $RemoteUrl,
        "^git@$([regex]::Escape($HostName)):(?<owner>[^/:\s]+)/(?<repository>[^/\s]+)$",
        [Text.RegularExpressions.RegexOptions]::IgnoreCase
    )
    if (-not $sshMatch.Success) {
        throw "Repository origin must use the documented GitHub HTTPS or SSH form."
    }
    $sshRepository = [string]$sshMatch.Groups["repository"].Value
    if ($sshRepository.EndsWith(".git", [StringComparison]::OrdinalIgnoreCase)) {
        $sshRepository = $sshRepository.Substring(0, $sshRepository.Length - 4)
    }
    if ([string]$sshMatch.Groups["owner"].Value -ine $Owner -or
        $sshRepository -ine $RepositoryName) {
        throw "Repository origin must use the exact approved GitHub SSH host and path."
    }
    return "git@$HostName`:$Owner/$RepositoryName.git"
}

function Parse-ResourceGroupScope {
    param(
        [Parameter(Mandatory)][string]$Scope,
        [Parameter(Mandatory)][string]$Name
    )

    $match = [regex]::Match(
        $Scope,
        "^/subscriptions/([0-9a-fA-F-]{36})/resourceGroups/([^/]+)$",
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )
    if (-not $match.Success) {
        throw "$Name must be an exact Azure resource-group resource ID."
    }
    return @{
        SubscriptionId = $match.Groups[1].Value
        ResourceGroupName = $match.Groups[2].Value
    }
}

function Assert-CommandSucceeded {
    param([Parameter(Mandatory)][string]$Message)
    if ($LASTEXITCODE -ne 0) {
        throw $Message
    }
}

function Get-GitHubJson {
    param([Parameter(Mandatory)][string]$Path)

    $json = gh api $Path
    Assert-CommandSucceeded "GitHub API path '$Path' is unavailable; verify plan, permissions, and authentication."
    return $json | ConvertFrom-Json -ErrorAction Stop
}

function Assert-WorkloadIdentity {
    param(
        [Parameter(Mandatory)][string]$ClientId,
        [Parameter(Mandatory)][string]$CredentialName,
        [Parameter(Mandatory)][string]$ExpectedSubject,
        [Parameter(Mandatory)][string]$RoleName,
        [Parameter(Mandatory)][string]$Scope,
        [Parameter(Mandatory)][string]$EnvironmentName
    )

    if ($ClientId -notmatch "^[0-9a-fA-F-]{36}$") {
        throw "$EnvironmentName Azure client ID environment value is not a GUID."
    }
    $credentials = az ad app federated-credential list --id $ClientId -o json |
        ConvertFrom-Json -ErrorAction Stop
    Assert-CommandSucceeded "Could not inspect $EnvironmentName federated credentials."
    $credential = @($credentials) |
        Where-Object { [string]$_.name -ceq $CredentialName } |
        Select-Object -First 1
    if ($null -eq $credential -or
        [string]$credential.issuer -ne "https://token.actions.githubusercontent.com" -or
        [string]$credential.subject -cne $ExpectedSubject -or
        "api://AzureADTokenExchange" -notin @($credential.audiences)) {
        throw "$EnvironmentName OIDC credential does not match the environment-scoped GitHub subject."
    }

    $servicePrincipalObjectId = az ad sp show --id $ClientId --query id -o tsv
    Assert-CommandSucceeded "Could not resolve the $EnvironmentName workload service principal."
    $assignments = az role assignment list `
        --assignee-object-id $servicePrincipalObjectId `
        --scope $Scope `
        --include-inherited `
        -o json | ConvertFrom-Json -ErrorAction Stop
    Assert-CommandSucceeded "Could not inspect $EnvironmentName Azure role assignments."
    $expectedAssignments = @($assignments) | Where-Object {
        [string]$_.roleDefinitionName -ceq $RoleName -and
        [string]$_.scope -ieq $Scope
    }
    if ($expectedAssignments.Count -ne 1) {
        throw "$EnvironmentName built-in role '$RoleName' is not assigned at the exact resource-group scope."
    }
    $unexpectedAssignments = @($assignments) | Where-Object {
        [string]$_.roleDefinitionName -cne $RoleName -or
        [string]$_.scope -ine $Scope
    }
    if ($unexpectedAssignments.Count -gt 0) {
        throw "$EnvironmentName workload identity has an additional or inherited Azure role assignment; only Contributor at the exact resource-group scope is allowed."
    }
}

if (-not (Test-Path -LiteralPath $artifactRoot -PathType Container)) {
    throw "Required implementation artifact tree is missing: $artifactRoot"
}

$requiredFiles = @(
    $controlPath,
    $validatorPath,
    $nonproductionParametersPath,
    $productionParametersPath,
    (Join-Path $artifactRoot "github\promotion.yml"),
    (Join-Path $artifactRoot "github\restore-previous-release.yml"),
    (Join-Path $artifactRoot "pipeline\release-manifest.template.json")
)
foreach ($path in $requiredFiles) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required implementation file is missing: $path"
    }
}

$artifactFiles = Get-ChildItem -LiteralPath $artifactRoot -File -Recurse
$sentinelMatches = @($artifactFiles | Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__" -AllMatches)
$uncovered = @()
$unresolvedLocations = @()
foreach ($matchInfo in $sentinelMatches) {
    foreach ($match in $matchInfo.Matches) {
        $name = $match.Value
        if ($name -notin $coveredDecisionSentinels) {
            $uncovered += $name
        }
        $relativePath = [System.IO.Path]::GetRelativePath($repoRoot, $matchInfo.Path)
        $unresolvedLocations += "$name at $relativePath`:$($matchInfo.LineNumber)"
    }
}
if ($uncovered.Count -gt 0) {
    throw "Preflight has no named coverage for these sentinels: $(@($uncovered | Sort-Object -Unique) -join ', ')"
}
if ($unresolvedLocations.Count -gt 0) {
    throw "Resolve every named customer decision before any state change:`n$($unresolvedLocations -join "`n")"
}

foreach ($jsonFile in Get-ChildItem -LiteralPath $artifactRoot -File -Recurse -Filter "*.json") {
    $null = Get-Content -LiteralPath $jsonFile.FullName -Raw |
        ConvertFrom-Json -ErrorAction Stop
}

$control = Read-JsonObject $controlPath
if ([string]$control.targetScopes.nonproduction -ine $ApprovedNonproductionScope) {
    throw "Nonproduction target does not match the exact approved scope."
}
if ([string]$control.targetScopes.production -ine $ApprovedProductionScope) {
    throw "Production target does not match the exact approved scope."
}
$nonproductionScope = Parse-ResourceGroupScope $ApprovedNonproductionScope "ApprovedNonproductionScope"
$productionScope = Parse-ResourceGroupScope $ApprovedProductionScope "ApprovedProductionScope"

if ($control.githubEnvironments.production.planSupportsRequiredProtection -ne $true -or
    $control.githubEnvironments.production.preventSelfReview -ne $true -or
    $control.githubEnvironments.production.adminBypassDisabled -ne $true) {
    throw "Production plan support, prevent self-review, and disabled administrator bypass must be explicitly true."
}
if ([string]::IsNullOrWhiteSpace([string]$control.githubEnvironments.production.branchOrTagRestriction) -or
    [string]::IsNullOrWhiteSpace([string]$control.githubEnvironments.production.requiredReviewerRole)) {
    throw "Production branch or tag restriction and reviewer role are required."
}
if ($control.azure.clientSecretAllowed -ne $false) {
    throw "Client secrets are prohibited; use environment-scoped workload identity federation."
}
if ([string]$control.azure.nonproductionRoleAssignment -cne "Contributor" -or
    [string]$control.azure.productionRoleAssignment -cne "Contributor") {
    throw "Both workload identities require the built-in Contributor role at their exact resource-group scopes."
}
if ([string]$control.githubEnvironments.nonproductionPreview.oidcSubject -notmatch ":environment:nonproduction-preview$" -or
    [string]$control.githubEnvironments.nonproduction.oidcSubject -notmatch ":environment:nonproduction$" -or
    [string]$control.githubEnvironments.productionPreview.oidcSubject -notmatch ":environment:production-preview$" -or
    [string]$control.githubEnvironments.production.oidcSubject -notmatch ":environment:production$") {
    throw "Each approved OIDC subject must end with its exact GitHub environment name."
}
if ($control.githubEnvironments.nonproduction.preventSelfReview -ne $true) {
    throw "Nonproduction apply approval must prevent self-review."
}

foreach ($command in @("git", "gh", "az", "python")) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "Required command is unavailable: $command"
    }
}
$remoteUrl = [string](git -C $repoRoot config --get remote.origin.url)
Assert-CommandSucceeded "Could not read the repository origin."
$expectedRepository = "$($control.repository.owner)/$($control.repository.name)"
$trustedFetchUrl = Get-TrustedGitHubRemote `
    -RemoteUrl $remoteUrl `
    -HostName ([string]$control.repository.host) `
    -Owner ([string]$control.repository.owner) `
    -RepositoryName ([string]$control.repository.name)
$approvedBranch = [string]$control.repository.defaultBranch
git -C $repoRoot check-ref-format "refs/heads/$approvedBranch"
Assert-CommandSucceeded "The configured protected release branch is not a valid Git branch."
$fetchArguments = @(
    "-C", [string]$repoRoot,
    "fetch",
    "--no-tags",
    "--prune"
)
$isShallow = [string](git -C $repoRoot rev-parse --is-shallow-repository)
Assert-CommandSucceeded "Could not inspect the repository history depth."
if ($isShallow -ceq "true") {
    $fetchArguments += "--unshallow"
}
$fetchArguments += @(
    $trustedFetchUrl,
    "+refs/heads/${approvedBranch}:refs/remotes/trusted-release/$approvedBranch"
)
& git @fetchArguments
Assert-CommandSucceeded "Could not fetch the full protected release-branch history."
git -C $repoRoot cat-file -e "$ApprovedReleaseSha^{commit}"
Assert-CommandSucceeded "ApprovedReleaseSha is not available after fetching the protected release branch."
git -C $repoRoot merge-base --is-ancestor `
    $ApprovedReleaseSha `
    "refs/remotes/trusted-release/$approvedBranch"
Assert-CommandSucceeded "ApprovedReleaseSha is not reachable from the protected release branch."

& $validatorPath -Mode Static -ReleaseSha $ApprovedReleaseSha
if (-not $?) {
    throw "Release validation failed."
}

$bicepPath = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $control.sourcePaths.bicepEntrypoint))
az bicep version | Out-Null
Assert-CommandSucceeded "Azure CLI Bicep support is required."
az bicep lint --file $bicepPath
Assert-CommandSucceeded "Bicep lint failed."
az bicep build --file $bicepPath --stdout | Out-Null
Assert-CommandSucceeded "Bicep build failed."

if ($Phase -eq "Decisions") {
    Write-Host "PASS: named decisions, files, exact scopes, repository metadata, immutable versions, workflow enforcement, action pins, and Bicep lint/build are ready before administrative state changes."
    return
}

$repository = Get-GitHubJson "repos/$expectedRepository"
if ([string]$repository.default_branch -cne [string]$control.repository.defaultBranch) {
    throw "Protected default branch decision does not match the GitHub repository."
}
$encodedApprovedBranch = [uri]::EscapeDataString($approvedBranch)
$releaseBranch = Get-GitHubJson `
    "repos/$expectedRepository/branches/$encodedApprovedBranch"
if ($releaseBranch.protected -isnot [bool] -or
    $releaseBranch.protected -ne $true) {
    throw "The approved default release branch is not protected."
}
if ($null -eq $repository.security_and_analysis -or
    [string]$repository.security_and_analysis.secret_scanning.status -ne "enabled" -or
    [string]$repository.security_and_analysis.secret_scanning_push_protection.status -ne "enabled") {
    throw "Native secret scanning and push protection must be available, accessible, and enabled."
}
$openSecretAlerts = @(Get-GitHubJson "repos/$expectedRepository/secret-scanning/alerts?state=open&per_page=100")
if ($openSecretAlerts.Count -gt 0) {
    throw "Resolve all open GitHub secret-scanning alerts before promotion."
}

$nonproductionPreviewEnvironment = Get-GitHubJson "repos/$expectedRepository/environments/nonproduction-preview"
$nonproductionEnvironment = Get-GitHubJson "repos/$expectedRepository/environments/nonproduction"
$productionPreviewEnvironment = Get-GitHubJson "repos/$expectedRepository/environments/production-preview"
$productionEnvironment = Get-GitHubJson "repos/$expectedRepository/environments/production"
if ([string]$nonproductionPreviewEnvironment.name -cne "nonproduction-preview" -or
    [string]$nonproductionEnvironment.name -cne "nonproduction" -or
    [string]$productionPreviewEnvironment.name -cne "production-preview" -or
    [string]$productionEnvironment.name -cne "production") {
    throw "The four configured GitHub environments are missing or renamed."
}
$nonproductionReviewerRule = @($nonproductionEnvironment.protection_rules) |
    Where-Object { [string]$_.type -eq "required_reviewers" } |
    Select-Object -First 1
if ($null -eq $nonproductionReviewerRule -or
    @($nonproductionReviewerRule.reviewers).Count -ne 1 -or
    [string]$nonproductionReviewerRule.reviewers[0].reviewer.slug -cne
        [string]$control.githubEnvironments.nonproduction.requiredReviewerTeamSlug -or
    $nonproductionReviewerRule.prevent_self_review -ne $true) {
    throw "Nonproduction apply requires the approved reviewer team and prevent-self-review."
}
$reviewerRule = @($productionEnvironment.protection_rules) |
    Where-Object { [string]$_.type -eq "required_reviewers" } |
    Select-Object -First 1
if ($null -eq $reviewerRule -or @($reviewerRule.reviewers).Count -lt 1) {
    throw "Production environment requires at least one configured reviewer."
}
$configuredReviewerTeamSlugs = @($reviewerRule.reviewers | ForEach-Object {
    [string]$_.reviewer.slug
} | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
if (@($reviewerRule.reviewers).Count -ne 1 -or
    $configuredReviewerTeamSlugs.Count -ne 1 -or
    [string]$control.githubEnvironments.production.requiredReviewerTeamSlug -cne
        [string]$configuredReviewerTeamSlugs[0]) {
    throw "Production must use only the one approved reviewer team."
}
if ($reviewerRule.prevent_self_review -ne $true) {
    throw "Production environment must prevent self-review."
}
if ($productionEnvironment.can_admins_bypass -ne $false) {
    throw "Production environment administrator bypass must be disabled."
}
$branchPolicy = $productionEnvironment.deployment_branch_policy
if ($null -eq $branchPolicy -or
    ($branchPolicy.protected_branches -ne $true -and
     $branchPolicy.custom_branch_policies -ne $true)) {
    throw "Production environment needs a protected-branch or custom branch/tag deployment policy."
}
if ($branchPolicy.protected_branches -eq $true) {
    if ([string]$control.githubEnvironments.production.branchOrTagRestriction -cne "protected-branches-only") {
        throw "The approved branch decision must be 'protected-branches-only' when GitHub uses protected branches."
    }
}
else {
    $deploymentPolicies = Get-GitHubJson "repos/$expectedRepository/environments/production/deployment-branch-policies?per_page=100"
    $configuredPatterns = @($deploymentPolicies.branch_policies | ForEach-Object { [string]$_.name })
    if ($configuredPatterns.Count -ne 1 -or
        [string]$control.githubEnvironments.production.branchOrTagRestriction -cne
            [string]$configuredPatterns[0]) {
        throw "Production must use only the one exact approved branch or tag pattern."
    }
}

function Get-EnvironmentVariableMap {
    param([Parameter(Mandatory)][string]$EnvironmentName)

    $response = Get-GitHubJson "repos/$expectedRepository/environments/$EnvironmentName/variables?per_page=100"
    $map = @{}
    foreach ($variable in @($response.variables)) {
        $map[[string]$variable.name] = [string]$variable.value
    }
    return $map
}

function Get-EnvironmentSecretNames {
    param([Parameter(Mandatory)][string]$EnvironmentName)

    $response = Get-GitHubJson "repos/$expectedRepository/environments/$EnvironmentName/secrets?per_page=100"
    return @($response.secrets | ForEach-Object { [string]$_.name })
}

$nonproductionPreviewVariables = Get-EnvironmentVariableMap "nonproduction-preview"
$nonproductionVariables = Get-EnvironmentVariableMap "nonproduction"
$productionPreviewVariables = Get-EnvironmentVariableMap "production-preview"
$productionVariables = Get-EnvironmentVariableMap "production"
$nonproductionSecretNames = Get-EnvironmentSecretNames "nonproduction"
foreach ($requiredName in @(
    "SESSION12_SMOKE_URL",
    "SESSION12_SMOKE_FAILURE_URL",
    "SESSION12_AI_RESOURCE_ID",
    "SESSION12_LOG_ANALYTICS_WORKSPACE_ID"
)) {
    if (-not $nonproductionVariables.ContainsKey($requiredName) -or
        [string]::IsNullOrWhiteSpace([string]$nonproductionVariables[$requiredName])) {
        throw "nonproduction GitHub environment variable $requiredName is required for the Session 13 smoke."
    }
}
$pollTimeout = 180
$pollRetry = 15
$pollTimeoutValue = [string]$nonproductionVariables["SESSION12_SMOKE_TIMEOUT_SECONDS"]
$pollRetryValue = [string]$nonproductionVariables["SESSION12_SMOKE_RETRY_SECONDS"]
if ((-not [string]::IsNullOrWhiteSpace($pollTimeoutValue) -and
        -not [int]::TryParse($pollTimeoutValue, [ref]$pollTimeout)) -or
    (-not [string]::IsNullOrWhiteSpace($pollRetryValue) -and
        -not [int]::TryParse($pollRetryValue, [ref]$pollRetry)) -or
    $pollTimeout -lt 30 -or $pollTimeout -gt 600 -or
    $pollRetry -lt 5 -or $pollRetry -gt 60 -or
    $pollRetry -gt $pollTimeout) {
    throw "Session 13 telemetry polling must use timeout 30-600 seconds and retry 5-60 seconds."
}
if (@($nonproductionSecretNames) -cnotcontains "SESSION12_SMOKE_BEARER_TOKEN") {
    throw "nonproduction GitHub environment secret SESSION12_SMOKE_BEARER_TOKEN is required."
}
foreach ($pair in @(
    @($nonproductionPreviewVariables, $nonproductionScope, "nonproduction-preview"),
    @($nonproductionVariables, $nonproductionScope, "nonproduction"),
    @($productionPreviewVariables, $productionScope, "production-preview"),
    @($productionVariables, $productionScope, "production")
)) {
    $variables = $pair[0]
    $scope = $pair[1]
    $environmentName = $pair[2]
    $expectedClientId = if ($environmentName.StartsWith("nonproduction")) {
        [string]$control.azure.nonproductionClientId
    }
    else {
        [string]$control.azure.productionClientId
    }
    if ($variables["AZURE_CLIENT_ID"] -ine $expectedClientId -or
        $variables["AZURE_TENANT_ID"] -ine [string]$control.azure.tenantId -or
        $variables["AZURE_SUBSCRIPTION_ID"] -ine $scope.SubscriptionId -or
        $variables["AZURE_RESOURCE_GROUP"] -ine $scope.ResourceGroupName) {
        throw "$environmentName GitHub environment variables do not match the operational identity and exact approved scope."
    }
    $currentTenantId = [string](az account show --query tenantId -o tsv)
    Assert-CommandSucceeded "Could not read the current Azure CLI tenant."
    if ($currentTenantId -ine [string]$control.azure.tenantId) {
        throw "Azure CLI is not authenticated to the approved tenant."
    }
}
Assert-WorkloadIdentity `
    -ClientId $nonproductionPreviewVariables["AZURE_CLIENT_ID"] `
    -CredentialName $control.azure.nonproductionPreviewFederatedCredentialName `
    -ExpectedSubject $control.githubEnvironments.nonproductionPreview.oidcSubject `
    -RoleName $control.azure.nonproductionRoleAssignment `
    -Scope $ApprovedNonproductionScope `
    -EnvironmentName "nonproduction-preview"
Assert-WorkloadIdentity `
    -ClientId $nonproductionVariables["AZURE_CLIENT_ID"] `
    -CredentialName $control.azure.nonproductionFederatedCredentialName `
    -ExpectedSubject $control.githubEnvironments.nonproduction.oidcSubject `
    -RoleName $control.azure.nonproductionRoleAssignment `
    -Scope $ApprovedNonproductionScope `
    -EnvironmentName "nonproduction"
Assert-WorkloadIdentity `
    -ClientId $productionPreviewVariables["AZURE_CLIENT_ID"] `
    -CredentialName $control.azure.productionPreviewFederatedCredentialName `
    -ExpectedSubject $control.githubEnvironments.productionPreview.oidcSubject `
    -RoleName $control.azure.productionRoleAssignment `
    -Scope $ApprovedProductionScope `
    -EnvironmentName "production-preview"
Assert-WorkloadIdentity `
    -ClientId $productionVariables["AZURE_CLIENT_ID"] `
    -CredentialName $control.azure.productionFederatedCredentialName `
    -ExpectedSubject $control.githubEnvironments.production.oidcSubject `
    -RoleName $control.azure.productionRoleAssignment `
    -Scope $ApprovedProductionScope `
    -EnvironmentName "production"

if ([string]::IsNullOrWhiteSpace($BaselineRecordPath) -or
    [string]::IsNullOrWhiteSpace($CandidateRecordPath) -or
    [string]::IsNullOrWhiteSpace($SecurityReleaseAttestationPath)) {
    throw "-BaselineRecordPath, -CandidateRecordPath, and -SecurityReleaseAttestationPath are required for Ready preflight."
}
& $validatorPath `
    -Mode Dependencies `
    -ReleaseSha $ApprovedReleaseSha `
    -BaselineRecordPath $BaselineRecordPath `
    -CandidateRecordPath $CandidateRecordPath `
    -SecurityReleaseAttestationPath $SecurityReleaseAttestationPath
if (-not $?) {
    throw "Session 11 evaluation dependencies or the external Session 12 security-release attestation are not ready."
}

Write-Host "Preview 1 of 2: nonproduction at $ApprovedNonproductionScope"
az deployment group what-if `
    --subscription $nonproductionScope.SubscriptionId `
    --resource-group $nonproductionScope.ResourceGroupName `
    --name "s13-preflight-nonproduction" `
    --template-file $bicepPath `
    --parameters $nonproductionParametersPath `
    releaseCommitSha=$ApprovedReleaseSha `
    --no-pretty-print
Assert-CommandSucceeded "Nonproduction what-if failed."

Write-Host "Preview 2 of 2: production at $ApprovedProductionScope"
az deployment group what-if `
    --subscription $productionScope.SubscriptionId `
    --resource-group $productionScope.ResourceGroupName `
    --name "s13-preflight-production" `
    --template-file $bicepPath `
    --parameters $productionParametersPath `
    releaseCommitSha=$ApprovedReleaseSha `
    --no-pretty-print
Assert-CommandSucceeded "Production what-if failed."

Write-Host "PASS: files, exact scopes, four live environments, apply approvals, native secret controls, four OIDC credentials, Contributor assignments, workflow enforcement, immutable versions, action pins, Bicep lint/build, and both read-only previews are ready."
