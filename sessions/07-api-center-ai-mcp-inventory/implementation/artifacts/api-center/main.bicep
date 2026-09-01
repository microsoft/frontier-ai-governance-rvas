targetScope = 'resourceGroup'

@description('Existing Session 07 API Management resource group.')
param apiManagementResourceGroupName string

@description('Existing Session 07 API Management service name.')
param apiManagementName string

@description('API Center service name.')
param apiCenterName string

@description('Approved API Center region.')
param location string

@description('Runtime URL for the Session 04 agent endpoint. Do not commit it.')
param session04AgentBaseUrl string

var environment = loadJsonContent('../environments/sandbox.json')
var agentDeploymentConfig = loadJsonContent('agent-api-definition.json')
var agentRecord = agentDeploymentConfig.api
var metadataDefinitions = loadJsonContent('metadata-schemas.json')

resource apiCenter 'Microsoft.ApiCenter/services@2024-03-01' = {
  name: apiCenterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: environment.tags
  properties: {}
}

resource metadataSchemas 'Microsoft.ApiCenter/services/metadataSchemas@2024-03-01' = [
  for definition in metadataDefinitions: {
    parent: apiCenter
    name: definition.name
    properties: {
      assignedTo: [
        {
          deprecated: false
          entity: 'api'
          required: definition.required
        }
      ]
      schema: definition.schema
    }
  }
]

resource workspace 'Microsoft.ApiCenter/services/workspaces@2024-03-01' = {
  parent: apiCenter
  name: 'default'
  properties: {
    title: 'Governed AI inventory'
    description: 'Design-time inventory for governed AI APIs, agent endpoints, and MCP servers.'
  }
}

resource foundryEnvironment 'Microsoft.ApiCenter/services/workspaces/environments@2024-03-01' = {
  parent: workspace
  name: 'foundry-nonproduction'
  properties: {
    title: 'Microsoft Foundry nonproduction'
    description: 'Approved Session 04 Microsoft Foundry agent runtime.'
    kind: 'testing'
  }
}

resource agentApi 'Microsoft.ApiCenter/services/workspaces/apis@2024-03-01' = {
  parent: workspace
  name: agentRecord.apiId
  properties: {
    title: agentRecord.title
    summary: agentRecord.summary
    description: agentRecord.description
    kind: agentRecord.kind
    customProperties: agentRecord.customProperties
  }
  dependsOn: [
    metadataSchemas
  ]
}

resource agentVersion 'Microsoft.ApiCenter/services/workspaces/apis/versions@2024-03-01' = {
  parent: agentApi
  name: agentRecord.versionId
  properties: {
    title: agentRecord.versionTitle
    lifecycleStage: agentRecord.lifecycleStage
  }
}

resource agentDefinition 'Microsoft.ApiCenter/services/workspaces/apis/versions/definitions@2024-03-01' = {
  parent: agentVersion
  name: agentRecord.definitionId
  properties: {
    title: 'OpenAPI'
    description: 'Session 04 policy assistant Responses API contract.'
  }
}

resource agentDeployment 'Microsoft.ApiCenter/services/workspaces/apis/deployments@2024-03-01' = {
  parent: agentApi
  name: agentRecord.deploymentId
  properties: {
    title: 'Foundry nonproduction'
    description: 'Pinned Session 04 agent endpoint.'
    definitionId: agentDefinition.id
    environmentId: foundryEnvironment.id
    server: {
      runtimeUri: [
        session04AgentBaseUrl
      ]
    }
    state: 'active'
  }
}

module apiManagementReader 'apim-reader.bicep' = {
  name: 'session08-apim-reader'
  scope: resourceGroup(apiManagementResourceGroupName)
  params: {
    apiManagementName: apiManagementName
    apiCenterPrincipalId: apiCenter.identity.principalId
    apiCenterResourceId: apiCenter.id
  }
}

output apiCenterId string = apiCenter.id
output apiCenterPrincipalId string = apiCenter.identity.principalId
output agentApiId string = agentApi.id
output agentDefinitionId string = agentDefinition.id
output apiManagementReaderAssignmentId string = apiManagementReader.outputs.roleAssignmentId
