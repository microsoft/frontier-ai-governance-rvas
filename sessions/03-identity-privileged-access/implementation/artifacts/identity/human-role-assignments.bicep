targetScope = 'resourceGroup'

var roleDefinitions = loadJsonContent('role-definitions.json')

@description('Existing Microsoft Foundry resource name.')
param foundryAccountName string

@description('Existing Microsoft Foundry project name.')
param foundryProjectName string

@description('Object ID of the project-manager security group.')
param projectManagerGroupObjectId string

@description('Object ID of the developer security group.')
param developerGroupObjectId string

@description('Object ID of the auditor security group.')
param auditorGroupObjectId string

resource foundryAccount 'Microsoft.CognitiveServices/accounts@2026-05-01' existing = {
  name: foundryAccountName
}

resource foundryProject 'Microsoft.CognitiveServices/accounts/projects@2026-05-01' existing = {
  parent: foundryAccount
  name: foundryProjectName
}

resource foundryProjectManager 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: roleDefinitions.roles.foundryProjectManager.id
}

resource foundryUser 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: roleDefinitions.roles.foundryUser.id
}

resource reader 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: roleDefinitions.roles.reader.id
}

resource projectManagerAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: foundryAccount
  name: guid(foundryAccount.id, projectManagerGroupObjectId, foundryProjectManager.id)
  properties: {
    roleDefinitionId: foundryProjectManager.id
    principalId: projectManagerGroupObjectId
    principalType: 'Group'
  }
}

resource developerAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: foundryProject
  name: guid(foundryProject.id, developerGroupObjectId, foundryUser.id)
  properties: {
    roleDefinitionId: foundryUser.id
    principalId: developerGroupObjectId
    principalType: 'Group'
  }
}

resource auditorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: foundryAccount
  name: guid(foundryAccount.id, auditorGroupObjectId, reader.id)
  properties: {
    roleDefinitionId: reader.id
    principalId: auditorGroupObjectId
    principalType: 'Group'
  }
}

output assignmentCount int = 3
output platformAdministratorInstruction string = 'Create Foundry Account Owner eligibility through PIM; do not add a permanent assignment in this template.'
