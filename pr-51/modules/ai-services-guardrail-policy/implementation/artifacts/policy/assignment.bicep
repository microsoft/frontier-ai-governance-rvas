targetScope = 'subscription'

@minLength(3)
@maxLength(64)
@description('Policy initiative name deployed by policy/initiative.bicep.')
param initiativeName string

@minLength(3)
@maxLength(64)
@description('Stable assignment name. Keep the same name when promoting effects.')
param assignmentName string

@description('Azure region used for the policy assignment managed identity and deployment metadata.')
param location string

@minLength(1)
@description('Exact approved assignment scope: subscription or resource group resource ID.')
param targetScopeResourceId string

@allowed([
  'Default'
  'DoNotEnforce'
])
@description('Start with DoNotEnforce. Promote the same assignment to Default after owner review.')
param enforcementMode string = 'DoNotEnforce'

@allowed([
  'Audit'
  'Deny'
  'Disabled'
])
param networkAccessEffect string = 'Audit'

@allowed([
  'Audit'
  'Deny'
  'Disabled'
])
param localAuthenticationEffect string = 'Audit'

@allowed([
  'Audit'
  'Deny'
  'Disabled'
])
param deploymentSkuEffect string = 'Audit'

@allowed([
  'Audit'
  'Disabled'
])
param contentFilterEffect string = 'Audit'

@allowed([
  'AuditIfNotExists'
  'DeployIfNotExists'
  'Disabled'
])
param diagnosticLogsEffect string = 'AuditIfNotExists'

param disallowedDeploymentSkus array
param allowedSeveritiesForPrompt array
param allowedEnabledForPrompt array
param allowedBlockingForPrompt array
param allowedSeveritiesForCompletion array
param allowedEnabledForCompletion array
param allowedBlockingForCompletion array
param diagnosticSettingName string
param diagnosticCategoryGroup string
param diagnosticResourceLocationList array
param logAnalyticsWorkspaceResourceId string

var initiativeDefinitionId = subscriptionResourceId('Microsoft.Authorization/policySetDefinitions', initiativeName)
var assignmentProperties = {
  displayName: 'Azure Policy guardrails for Microsoft Foundry AI services'
  description: 'Optional module assignment for staged Foundry and Azure AI services guardrails.'
  enforcementMode: enforcementMode
  policyDefinitionId: initiativeDefinitionId
  parameters: {
    networkAccessEffect: {
      value: networkAccessEffect
    }
    localAuthenticationEffect: {
      value: localAuthenticationEffect
    }
    deploymentSkuEffect: {
      value: deploymentSkuEffect
    }
    disallowedDeploymentSkus: {
      value: disallowedDeploymentSkus
    }
    contentFilterEffect: {
      value: contentFilterEffect
    }
    allowedSeveritiesForPrompt: {
      value: allowedSeveritiesForPrompt
    }
    allowedEnabledForPrompt: {
      value: allowedEnabledForPrompt
    }
    allowedBlockingForPrompt: {
      value: allowedBlockingForPrompt
    }
    allowedSeveritiesForCompletion: {
      value: allowedSeveritiesForCompletion
    }
    allowedEnabledForCompletion: {
      value: allowedEnabledForCompletion
    }
    allowedBlockingForCompletion: {
      value: allowedBlockingForCompletion
    }
    diagnosticLogsEffect: {
      value: diagnosticLogsEffect
    }
    diagnosticSettingName: {
      value: diagnosticSettingName
    }
    diagnosticCategoryGroup: {
      value: diagnosticCategoryGroup
    }
    diagnosticResourceLocationList: {
      value: diagnosticResourceLocationList
    }
    logAnalyticsWorkspaceResourceId: {
      value: logAnalyticsWorkspaceResourceId
    }
  }
  metadata: {
    assignedBy: 'AI platform policy owner'
    implementationSession: 'optional-module-ai-services-guardrail-policy'
    targetScopeResourceId: targetScopeResourceId
  }
  nonComplianceMessages: [
    {
      message: 'The resource does not match the approved Foundry and Azure AI services guardrail policy.'
    }
  ]
}

resource assignment 'Microsoft.Authorization/policyAssignments@2025-03-01' = {
  name: assignmentName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: assignmentProperties
}

output assignmentId string = assignment.id
output assignmentPrincipalId string = assignment.identity.principalId
output assignmentEnforcementMode string = enforcementMode
