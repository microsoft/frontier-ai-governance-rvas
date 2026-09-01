targetScope = 'resourceGroup'

@description('Azure region for the Session 02 private endpoints and private DNS resources.')
param location string = resourceGroup().location

@description('Resource ID of the Session 01-owned virtual network that private DNS zones link to.')
param virtualNetworkResourceId string

@description('Resource ID of the Session 01-owned private-endpoint subnet.')
param privateEndpointSubnetResourceId string

@description('Existing Microsoft Foundry resource ID.')
param foundryResourceId string

@description('Existing Storage account resource ID.')
param storageResourceId string

@description('Existing Azure AI Search resource ID.')
param searchResourceId string

@description('Existing Azure Cosmos DB account resource ID.')
param cosmosResourceId string

@description('Existing Azure Key Vault resource ID.')
param keyVaultResourceId string

@description('Expiry date for the nonproduction implementation in YYYY-MM-DD form.')
param expiryDate string

var implementationSession = '02-private-networking-dns'
var tags = {
  environment: 'sandbox'
  implementationSession: implementationSession
  expiryDate: expiryDate
}
var dnsZoneNames = [
  'privatelink.cognitiveservices.azure.com'
  'privatelink.openai.azure.com'
  'privatelink.services.ai.azure.com'
  'privatelink.blob.core.windows.net'
  'privatelink.search.windows.net'
  'privatelink.documents.azure.com'
  'privatelink.vaultcore.azure.net'
]
var endpointSpecs = [
  {
    name: 'pe-foundry'
    resourceId: foundryResourceId
    groupId: 'account'
    dnsZoneIndexes: [
      0
      1
      2
    ]
  }
  {
    name: 'pe-storage-blob'
    resourceId: storageResourceId
    groupId: 'blob'
    dnsZoneIndexes: [
      3
    ]
  }
  {
    name: 'pe-ai-search'
    resourceId: searchResourceId
    groupId: 'searchService'
    dnsZoneIndexes: [
      4
    ]
  }
  {
    name: 'pe-cosmos-sql'
    resourceId: cosmosResourceId
    groupId: 'Sql'
    dnsZoneIndexes: [
      5
    ]
  }
  {
    name: 'pe-key-vault'
    resourceId: keyVaultResourceId
    groupId: 'vault'
    dnsZoneIndexes: [
      6
    ]
  }
]

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2024-06-01' = [for zoneName in dnsZoneNames: {
  name: zoneName
  location: 'global'
  tags: tags
}]

resource privateDnsZoneLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = [for (zoneName, index) in dnsZoneNames: {
  parent: privateDnsZones[index]
  name: 'link-session01-vnet'
  location: 'global'
  tags: tags
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkResourceId
    }
  }
}]

resource privateEndpoints 'Microsoft.Network/privateEndpoints@2024-05-01' = [for endpoint in endpointSpecs: {
  name: endpoint.name
  location: location
  tags: tags
  properties: {
    subnet: {
      id: privateEndpointSubnetResourceId
    }
    privateLinkServiceConnections: [
      {
        name: '${endpoint.name}-connection'
        properties: {
          privateLinkServiceId: endpoint.resourceId
          groupIds: [
            endpoint.groupId
          ]
        }
      }
    ]
  }
  dependsOn: [
    privateDnsZoneLinks
  ]
}]

resource privateEndpointDnsZoneGroups 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = [for (endpoint, endpointIndex) in endpointSpecs: {
  parent: privateEndpoints[endpointIndex]
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [for zoneIndex in endpoint.dnsZoneIndexes: {
      name: replace(dnsZoneNames[zoneIndex], '.', '-')
      properties: {
        privateDnsZoneId: privateDnsZones[zoneIndex].id
      }
    }]
  }
}]

output implementationSession string = implementationSession
output virtualNetworkResourceId string = virtualNetworkResourceId
output privateEndpointSubnetResourceId string = privateEndpointSubnetResourceId
output privateEndpointAliases array = [for endpoint in endpointSpecs: endpoint.name]
output privateDnsZoneNames array = dnsZoneNames
