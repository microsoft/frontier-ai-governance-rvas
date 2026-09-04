using none

param apim = {
  subscriptionId: '__REQUIRED_SUBSCRIPTION_ID__'
  resourceGroupName: '__REQUIRED_HUB_RESOURCE_GROUP__'
  name: '__REQUIRED_APIM_NAME__'
}

param apimManagedIdentity = {
  subscriptionId: '__REQUIRED_SUBSCRIPTION_ID__'
  resourceGroupName: '__REQUIRED_HUB_RESOURCE_GROUP__'
  name: '__REQUIRED_APIM_IDENTITY_NAME__'
}

param llmBackendConfig = [
  {
    backendId: 'policy-assistant-primary'
    backendType: 'ai-foundry'
    endpoint: '__REQUIRED_FOUNDRY_ENDPOINT__'
    authType: 'managed-identity'
    supportedModels: [
      {
        name: '__REQUIRED_MODEL_DEPLOYMENT_NAME__'
        sku: '__REQUIRED_MODEL_SKU__'
        capacity: 1
        modelFormat: 'OpenAI'
        modelVersion: '__REQUIRED_MODEL_VERSION__'
      }
    ]
    priority: 1
    weight: 100
  }
]

param configureCircuitBreaker = true
param deployUniversalLlmApi = true
