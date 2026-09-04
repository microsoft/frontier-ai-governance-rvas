using '../policy/assignment.bicep'

var settings = loadJsonContent('../policy/guardrail-settings.json')

// Preflight blocks deployment until the customer implementation team resolves these regions.
param initiativeDefinitionId = readEnvironmentVariable('RVAS_INITIATIVE_DEFINITION_ID')
param enforcementMode = 'DoNotEnforce'
param allowedLocations = [
  '__REQUIRED_PRIMARY_REGION__'
  '__REQUIRED_SECONDARY_REGION__'
]
param requiredTagNames = settings.requiredTagNames
