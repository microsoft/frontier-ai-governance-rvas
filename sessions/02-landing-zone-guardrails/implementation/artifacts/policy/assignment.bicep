targetScope = 'resourceGroup'

@minLength(1)
@description('Full resource ID of the deployed initiative.')
param initiativeDefinitionId string

@allowed([
  'DoNotEnforce'
  'Default'
])
param enforcementMode string = 'DoNotEnforce'

@minLength(1)
param allowedLocations array

@minLength(1)
param requiredTagNames array

param assignmentName string = 'rvas-s02-guardrails'

resource assignment 'Microsoft.Authorization/policyAssignments@2025-03-01' = {
  name: assignmentName
  properties: {
    displayName: 'RVAS Session 02 AI landing-zone guardrails'
    description: 'Implementation assignment for staged location and required-tag controls.'
    enforcementMode: enforcementMode
    policyDefinitionId: initiativeDefinitionId
    parameters: {
      allowedLocations: {
        value: allowedLocations
      }
      requiredTagNames: {
        value: requiredTagNames
      }
    }
    metadata: {
      assignedBy: 'RVAS Session 02'
      implementationSession: '02-landing-zone-guardrails'
    }
    nonComplianceMessages: [
      {
        message: 'This resource does not meet the approved AI landing-zone location or tag contract.'
      }
    ]
  }
}

output assignmentId string = assignment.id
output assignmentEnforcementMode string = enforcementMode
