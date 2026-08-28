targetScope = 'resourceGroup'

@description('Azure region shared by the spoke virtual network and Foundry resource.')
param location string = resourceGroup().location

@description('Dedicated Session 03 spoke virtual network name.')
param virtualNetworkName string

@description('Nonoverlapping RFC 1918 address space for the spoke.')
param virtualNetworkAddressPrefix string

@description('Dedicated /27-or-larger subnet for Foundry Agent Service network injection.')
param agentSubnetPrefix string

@description('Dedicated subnet for private endpoints.')
param privateEndpointSubnetPrefix string

@description('Private IP of the customer-approved firewall next hop.')
param firewallPrivateIp string

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

var implementationSession = '03-private-networking-dns'
var tags = {
  environment: 'sandbox'
  implementationSession: implementationSession
  expiryDate: expiryDate
}
var agentSubnetName = 'snet-foundry-agent'
var privateEndpointSubnetName = 'snet-private-endpoints'
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

resource routeTable 'Microsoft.Network/routeTables@2024-05-01' = {
  name: 'rt-${virtualNetworkName}-controlled-egress'
  location: location
  tags: tags
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'default-via-customer-firewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIp
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefix
      ]
    }
    subnets: [
      {
        name: agentSubnetName
        properties: {
          addressPrefix: agentSubnetPrefix
          routeTable: {
            id: routeTable.id
          }
          delegations: [
            {
              name: 'foundry-agent-service'
              properties: {
                serviceName: 'Microsoft.App/environments'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
      {
        name: privateEndpointSubnetName
        properties: {
          addressPrefix: privateEndpointSubnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2024-06-01' = [for zoneName in dnsZoneNames: {
  name: zoneName
  location: 'global'
  tags: tags
}]

resource privateDnsZoneLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = [for (zoneName, index) in dnsZoneNames: {
  parent: privateDnsZones[index]
  name: 'link-${virtualNetworkName}'
  location: 'global'
  tags: tags
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}]

resource privateEndpoints 'Microsoft.Network/privateEndpoints@2024-05-01' = [for endpoint in endpointSpecs: {
  name: endpoint.name
  location: location
  tags: tags
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, privateEndpointSubnetName)
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
output virtualNetworkName string = virtualNetwork.name
output agentSubnetName string = agentSubnetName
output privateEndpointSubnetName string = privateEndpointSubnetName
output privateEndpointAliases array = [for endpoint in endpointSpecs: endpoint.name]
output privateDnsZoneNames array = dnsZoneNames
