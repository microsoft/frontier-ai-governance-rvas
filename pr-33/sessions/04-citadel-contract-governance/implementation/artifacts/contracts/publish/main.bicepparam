using none

param apim = {
  subscriptionId: '__REQUIRED_SUBSCRIPTION_ID__'
  resourceGroupName: '__REQUIRED_HUB_RESOURCE_GROUP__'
  name: '__REQUIRED_APIM_NAME__'
}

param apiCenter = {
  subscriptionId: '__REQUIRED_SUBSCRIPTION_ID__'
  resourceGroupName: '__REQUIRED_HUB_RESOURCE_GROUP__'
  serviceName: '__REQUIRED_API_CENTER_NAME__'
  workspaceName: 'default'
}

param publishAssets = [
  {
    assetType: 'mcp-existing'
    name: 'policy-read-tool'
    displayName: 'Policy read tool'
    description: 'Read-only policy lookup used by the governed agent.'
    path: 'policy-read-tool'
    transportType: 'streamable'
    subscriptionRequired: true
    metadata: {
      version: '1.0.0'
      owner: '__REQUIRED_TOOL_OWNER__'
      contactEmail: '__REQUIRED_TOOL_CONTACT__'
      compliance: [
        'Internal'
      ]
      classification: 'internal'
    }
    backend: {
      url: '__REQUIRED_MCP_SERVER_URL__'
      authType: 'managed-identity'
      authConfig: {
        resource: '__REQUIRED_MCP_AUDIENCE__'
      }
    }
    publishToApiCenter: true
    apiCenter: {
      environmentName: 'nonproduction'
      lifecycleStage: 'development'
      customProperties: {
        Visibility: false
        Type: 'AI Gateway'
      }
    }
  }
]
