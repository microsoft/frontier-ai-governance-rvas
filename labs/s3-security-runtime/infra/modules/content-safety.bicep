targetScope = 'resourceGroup'

@description('Azure AI Content Safety account name.')
param accountName string

@description('Azure region for the Content Safety account.')
param location string = resourceGroup().location

@description('Content Safety SKU.')
@allowed([
  'F0'
  'S0'
])
param skuName string = 'S0'

@description('Disable local key authentication. Set true when Entra-only access is ready.')
param disableLocalAuth bool = false

@description('Tags applied to the Content Safety account.')
param tags object = {}

resource contentSafety 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: accountName
  location: location
  kind: 'ContentSafety'
  sku: {
    name: skuName
  }
  tags: tags
  properties: {
    customSubDomainName: accountName
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: disableLocalAuth
  }
}

output endpoint string = contentSafety.properties.endpoint
output resourceId string = contentSafety.id
