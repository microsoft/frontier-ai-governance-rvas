[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required and was not found on PATH."
}

function Get-BuiltInDefinition {
    param(
        [Parameter(Mandatory)]
        [string]$DisplayName,

        [Parameter(Mandatory)]
        [string]$RequiredParameterName
    )

    $query = "[?policyType=='BuiltIn' && displayName=='$DisplayName'].{id:id,name:name,displayName:displayName,version:version,metadata:metadata,parameters:parameters,policyRule:policyRule}"
    $raw = & az policy definition list --query $query --output json --only-show-errors 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to resolve built-in '$DisplayName'.`n$($raw | Out-String)"
    }

    $matches = @($raw | ConvertFrom-Json -ErrorAction Stop)
    if ($matches.Count -ne 1) {
        throw "Expected one current built-in named '$DisplayName'; found $($matches.Count). Confirm the display name before implementation."
    }

    $definition = $matches[0]
    $deprecated = $definition.metadata.PSObject.Properties["deprecated"]
    if ($null -ne $deprecated -and [string]$deprecated.Value -ieq "true") {
        throw "Built-in '$DisplayName' is deprecated. Select and inspect a replacement before implementation."
    }

    $effectExpression = [string]$definition.policyRule.then.effect
    $effectiveEffect = $effectExpression
    $effectParameterName = $null
    if ($effectExpression -ine "deny") {
        $effectParameterMatch = [regex]::Match(
            $effectExpression,
            '^\[parameters\(''([^'']+)''\)\]$'
        )
        if (-not $effectParameterMatch.Success) {
            $effectParameterMatch = [regex]::Match(
                $effectExpression,
                '^\[parameters\("([^"]+)"\)\]$'
            )
        }
        if (-not $effectParameterMatch.Success) {
            throw "Built-in '$DisplayName' now uses effect '$effectExpression'; the deployed initiative expects Deny."
        }

        $effectParameterName = $effectParameterMatch.Groups[1].Value
        $effectParameterProperty = $definition.parameters.PSObject.Properties[$effectParameterName]
        if ($null -eq $effectParameterProperty) {
            throw "Built-in '$DisplayName' references missing effect parameter '$effectParameterName'."
        }
        $effectParameter = $effectParameterProperty.Value
        $defaultValueProperty = $effectParameter.PSObject.Properties["defaultValue"]
        if ($null -eq $defaultValueProperty -or [string]$defaultValueProperty.Value -ine "deny") {
            throw "Built-in '$DisplayName' no longer defaults '$effectParameterName' to Deny."
        }
        $allowedValuesProperty = $effectParameter.PSObject.Properties["allowedValues"]
        $allowedValues = if ($null -eq $allowedValuesProperty) {
            @()
        }
        else {
            @($allowedValuesProperty.Value | ForEach-Object { [string]$_ })
        }
        if ($allowedValues.Count -gt 0 -and "Deny" -notin $allowedValues) {
            throw "Built-in '$DisplayName' no longer permits Deny through '$effectParameterName'."
        }
        $effectiveEffect = [string]$defaultValueProperty.Value
    }

    $parameterNames = @($definition.parameters.PSObject.Properties.Name)
    if ($RequiredParameterName -notin $parameterNames) {
        throw "Built-in '$DisplayName' no longer exposes required parameter '$RequiredParameterName'."
    }

    $version = ""
    $definitionVersion = $definition.PSObject.Properties["version"]
    $metadataVersion = $definition.metadata.PSObject.Properties["version"]
    if ($null -ne $definitionVersion) {
        $version = [string]$definitionVersion.Value
    }
    elseif ($null -ne $metadataVersion) {
        $version = [string]$metadataVersion.Value
    }

    return [ordered]@{
        id = [string]$definition.id
        name = [string]$definition.name
        displayName = [string]$definition.displayName
        version = $version
        effect = $effectiveEffect
        effectExpression = $effectExpression
        effectParameter = $effectParameterName
        parameterNames = $parameterNames
    }
}

$resolved = [ordered]@{
    allowedLocations = (
        Get-BuiltInDefinition `
            -DisplayName "Allowed locations" `
            -RequiredParameterName "listOfAllowedLocations"
    )
    requireTag = (
        Get-BuiltInDefinition `
            -DisplayName "Require a tag on resources" `
            -RequiredParameterName "tagName"
    )
}

$resolved | ConvertTo-Json -Depth 10
