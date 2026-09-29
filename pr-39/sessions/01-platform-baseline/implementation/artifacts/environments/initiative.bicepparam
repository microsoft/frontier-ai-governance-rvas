using '../policy/initiative.bicep'

var settings = loadJsonContent('../policy/guardrail-settings.json')

param initiativeName = 'rvas-ai-landing-zone'
param allowedLocationsDefinitionId = readEnvironmentVariable('RVAS_ALLOWED_LOCATIONS_POLICY_ID')
param requireTagDefinitionId = readEnvironmentVariable('RVAS_REQUIRE_TAG_POLICY_ID')
param requiredTagNames = settings.requiredTagNames

// Set both environment variables from resolve-builtins.ps1 output before build or deployment.
