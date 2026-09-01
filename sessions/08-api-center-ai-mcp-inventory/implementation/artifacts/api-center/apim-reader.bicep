targetScope = 'resourceGroup'

@description('Existing Session 08 API Management service name.')
param apiManagementName string

@description('System-assigned principal ID of the Session 09 API Center.')
param apiCenterPrincipalId string

@description('Resource ID of the Session 09 API Center.')
param apiCenterResourceId string

var implementationSession = '09-api-center-ai-mcp-inventory'
var apiManagementServiceReaderRoleId = '71522526-b88f-4d52-b57f-d31fc3546d0d'

resource apiManagement 'Microsoft.ApiManagement/service@2024-05-01' existing = {
  name: apiManagementName
}

resource apiManagementReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(apiManagement.id, apiCenterResourceId, apiManagementServiceReaderRoleId)
  scope: apiManagement
  properties: {
    principalId: apiCenterPrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      apiManagementServiceReaderRoleId
    )
    description: 'implementationSession=${implementationSession}; API Center synchronization reader'
  }
}

output roleAssignmentId string = apiManagementReader.id
