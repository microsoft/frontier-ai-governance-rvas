using none

param apim = {
  subscriptionId: '__REQUIRED_SUBSCRIPTION_ID__'
  resourceGroupName: '__REQUIRED_HUB_RESOURCE_GROUP__'
  name: '__REQUIRED_APIM_NAME__'
}

param useTargetAzureKeyVault = true
param keyVault = {
  subscriptionId: '__REQUIRED_SUBSCRIPTION_ID__'
  resourceGroupName: '__REQUIRED_SPOKE_RESOURCE_GROUP__'
  name: '__REQUIRED_KEY_VAULT_NAME__'
}

param useCase = {
  businessUnit: '__REQUIRED_BUSINESS_UNIT__'
  useCaseName: 'PolicyAssistant'
  environment: 'NONPROD'
}

param apiNameMapping = {
  MULTI: [
    'universal-llm-api'
    'policy-read-tool'
  ]
}

param services = [
  {
    code: 'MULTI'
    apiKeySecretName: 'POLICY_ASSISTANT_GATEWAY_KEY'
    foundryApiName: 'universal-llm-api'
    publishAllAssetEndpoints: true
    policyXml: ''
  }
]
