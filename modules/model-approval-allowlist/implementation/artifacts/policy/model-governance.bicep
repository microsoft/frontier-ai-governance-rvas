targetScope = 'resourceGroup'

@minLength(1)
@description('Full definition ID of the built-in "Foundry model deployments should only use approved models" policy.')
param approvedModelsPolicyDefinitionId string

@minLength(1)
@description('Full definition ID of the built-in "Foundry model deployments should meet eligibility requirements" policy.')
param eligibilityPolicyDefinitionId string

@allowed([
  'Audit'
  'Deny'
])
@description('Start in Audit. Move to Deny through the approved change path once compliance is reviewed.')
param assignmentEffect string = 'Audit'

@minLength(1)
@description('Publisher names copied from the approved model cards.')
param allowedPublishers array

@minLength(1)
@description('Model asset IDs from the approval register. Use a trailing slash to stop prefix matches on longer model names.')
param allowedAssetIds array

@description('Deny models that are not sold by Azure.')
param onlyAllowDirectFromAzure bool = true

@description('Deny models whose lifecycle status is Preview.')
param denyPreviewModels bool = true

param approvedModelsAssignmentName string = 'rvas-mod-approved-models'
param eligibilityAssignmentName string = 'rvas-mod-model-eligibility'

resource approvedModels 'Microsoft.Authorization/policyAssignments@2025-03-01' = {
  name: approvedModelsAssignmentName
  properties: {
    displayName: 'RVAS approved Foundry models'
    description: 'Restricts Foundry model deployments to the publishers and model asset IDs in the approval register.'
    policyDefinitionId: approvedModelsPolicyDefinitionId
    parameters: {
      effect: {
        value: assignmentEffect
      }
      allowedPublishers: {
        value: allowedPublishers
      }
      allowedAssetIds: {
        value: allowedAssetIds
      }
    }
    metadata: {
      assignedBy: 'RVAS model approval module'
      implementationSession: 'model-approval-allowlist'
    }
    nonComplianceMessages: [
      {
        message: 'This model is not in the approved model register. Ask the platform owner to run the model approval review.'
      }
    ]
  }
}

resource eligibility 'Microsoft.Authorization/policyAssignments@2025-03-01' = {
  name: eligibilityAssignmentName
  properties: {
    displayName: 'RVAS Foundry model eligibility'
    description: 'Restricts Foundry model deployments by model source and lifecycle status.'
    policyDefinitionId: eligibilityPolicyDefinitionId
    parameters: {
      effect: {
        value: assignmentEffect
      }
      onlyAllowDirectFromAzure: {
        value: onlyAllowDirectFromAzure
      }
      denyPreviewModels: {
        value: denyPreviewModels
      }
    }
    metadata: {
      assignedBy: 'RVAS model approval module'
      implementationSession: 'model-approval-allowlist'
    }
    nonComplianceMessages: [
      {
        message: 'This model does not meet the approved source and lifecycle requirements for this scope.'
      }
    ]
  }
}

output approvedModelsAssignmentId string = approvedModels.id
output eligibilityAssignmentId string = eligibility.id
output effect string = assignmentEffect
