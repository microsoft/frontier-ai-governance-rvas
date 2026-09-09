targetScope = 'subscription'

@minLength(3)
@maxLength(64)
@description('Stable customer-owned name for the AI landing-zone initiative.')
param initiativeName string

@minLength(1)
@description('Full resource ID of the current Allowed locations built-in resolved during delivery preparation.')
param allowedLocationsDefinitionId string

@minLength(1)
@description('Full resource ID of the current Require a tag on resources built-in resolved during delivery preparation.')
param requireTagDefinitionId string

@minLength(1)
@description('Required resource tag names.')
param requiredTagNames array

var requiredTagPolicies = [
  for (tagName, index) in requiredTagNames: {
    policyDefinitionId: requireTagDefinitionId
    policyDefinitionReferenceId: 'require-tag-${index}'
    parameters: {
      tagName: {
        value: '[parameters(\'requiredTagNames\')[${index}]]'
      }
    }
  }
]

resource initiative 'Microsoft.Authorization/policySetDefinitions@2025-03-01' = {
  name: initiativeName
  properties: {
    displayName: 'RVAS AI landing-zone guardrails'
    description: 'Restricts deployment regions and requires operating tags for in-scope AI platform resources.'
    policyType: 'Custom'
    version: '1.0.0'
    metadata: {
      category: 'AI Governance'
      owner: 'Cloud platform team'
      implementationSession: '01-platform-baseline'
    }
    parameters: {
      allowedLocations: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed locations'
          description: 'Azure regions approved for the assigned environment.'
          strongType: 'location'
        }
      }
      requiredTagNames: {
        type: 'Array'
        metadata: {
          displayName: 'Required resource tags'
          description: 'Resource tag names required at the assigned scope.'
        }
      }
    }
    policyDefinitions: concat([
      {
        policyDefinitionId: allowedLocationsDefinitionId
        policyDefinitionReferenceId: 'allowed-locations'
        parameters: {
          listOfAllowedLocations: {
            value: '[parameters(\'allowedLocations\')]'
          }
        }
      }
    ], requiredTagPolicies)
  }
}

output initiativeDefinitionId string = initiative.id
output policyDefinitionReferenceIds array = map(initiative.properties.policyDefinitions, item => item.policyDefinitionReferenceId)
