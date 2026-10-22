targetScope = 'subscription'

@description('Exact subscription scope approved for AI FinOps cost-allocation policy. Preflight checks this value against the operator input.')
param targetScope string

@description('Azure region used for policy assignment managed identities.')
param assignmentIdentityLocation string

@description('Cost-allocation tag names required on resource groups and inherited by resources.')
@minLength(1)
param requiredTags array

@description('Prefix used for policy assignment names. Keep it stable for remediation and restore.')
param assignmentNamePrefix string

var implementationSession = 'optional-module-ai-finops-token-chargeback'
var requireResourceGroupTagPolicyDefinitionId = '/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025'
var inheritTagPolicyDefinitionId = '/providers/Microsoft.Authorization/policyDefinitions/cd3aa116-8754-49c9-a813-ad46512ece54'
var contributorRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

resource requireResourceGroupTagAssignments 'Microsoft.Authorization/policyAssignments@2025-03-01' = [for tagName in requiredTags: {
  name: '${assignmentNamePrefix}-rg-${toLower(replace(tagName, ' ', '-'))}'
  location: assignmentIdentityLocation
  properties: {
    displayName: 'Stage ${tagName} tag requirement on resource groups'
    description: 'Stages the ${tagName} cost-allocation tag requirement on resource groups in the approved AI FinOps subscription.'
    policyDefinitionId: requireResourceGroupTagPolicyDefinitionId
    enforcementMode: 'DoNotEnforce'
    parameters: {
      tagName: {
        value: tagName
      }
    }
    metadata: {
      implementationSession: implementationSession
      targetScope: targetScope
      control: 'ai-finops-resource-group-tag-requirement'
      promotion: 'Promote to Default only after current policy findings, exemptions, and subscription-wide effect are approved.'
    }
  }
}]

resource inheritTagAssignments 'Microsoft.Authorization/policyAssignments@2025-03-01' = [for tagName in requiredTags: {
  name: '${assignmentNamePrefix}-inherit-${toLower(replace(tagName, ' ', '-'))}'
  location: assignmentIdentityLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: 'Inherit ${tagName} tag from resource group'
    description: 'Adds or replaces the ${tagName} tag on AI resources with the value from the parent resource group.'
    policyDefinitionId: inheritTagPolicyDefinitionId
    enforcementMode: 'Default'
    parameters: {
      tagName: {
        value: tagName
      }
    }
    metadata: {
      implementationSession: implementationSession
      targetScope: targetScope
      control: 'ai-finops-resource-tag-inheritance'
      remediation: 'Create a remediation task after assignment review for existing AI resources.'
    }
  }
}]

resource inheritTagContributorAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (tagName, index) in requiredTags: {
  name: guid(subscription().id, inheritTagAssignments[index].name, contributorRoleDefinitionId)
  properties: {
    roleDefinitionId: contributorRoleDefinitionId
    principalId: inheritTagAssignments[index].identity.principalId
    principalType: 'ServicePrincipal'
  }
}]

output requiredResourceGroupTagAssignmentIds array = [for (tagName, index) in requiredTags: requireResourceGroupTagAssignments[index].id]
output inheritTagAssignmentIds array = [for (tagName, index) in requiredTags: inheritTagAssignments[index].id]
