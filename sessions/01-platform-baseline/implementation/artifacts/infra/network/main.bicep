targetScope = 'resourceGroup'

@description('Approved Azure region for the dedicated BYO VNet foundation.')
param location string = resourceGroup().location

@description('Dedicated virtual network name.')
param virtualNetworkName string

@description('Nonoverlapping RFC 1918 address space for the virtual network.')
param virtualNetworkAddressPrefix string

@description('Dedicated /27-or-larger subnet for Foundry Agent Service network injection.')
param agentSubnetPrefix string

@description('Dedicated subnet reserved for Session 03 private endpoints.')
param privateEndpointSubnetPrefix string

@description('Private IP of the customer-approved firewall next hop.')
param firewallPrivateIp string

@description('Expiry date for the nonproduction implementation in YYYY-MM-DD form.')
param expiryDate string

var implementationSession = '01-platform-baseline'
var agentSubnetName = 'snet-foundry-agent'
var privateEndpointSubnetName = 'snet-private-endpoints'

resource routeTable 'Microsoft.Network/routeTables@2024-05-01' = {
  name: 'rt-${virtualNetworkName}-controlled-egress'
  location: location
  tags: {
    implementationSession: implementationSession
    environment: 'sandbox'
    expiryDate: expiryDate
  }
  properties: {
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
  tags: {
    implementationSession: implementationSession
    environment: 'sandbox'
    expiryDate: expiryDate
  }
  properties: {
    addressSpace: {
      addressPrefixes: [virtualNetworkAddressPrefix]
    }
    subnets: [
      {
        name: agentSubnetName
        properties: {
          addressPrefix: agentSubnetPrefix
          routeTable: { id: routeTable.id }
          delegations: [
            {
              name: 'foundry-agent-service'
              properties: { serviceName: 'Microsoft.App/environments' }
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

output agentSubnetResourceId string = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, agentSubnetName)
output privateEndpointSubnetResourceId string = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, privateEndpointSubnetName)
