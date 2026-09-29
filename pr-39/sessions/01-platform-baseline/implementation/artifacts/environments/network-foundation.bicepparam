using '../infra/network/main.bicep'

param location = '__REQUIRED_AZURE_REGION__'
param virtualNetworkName = '__REQUIRED_VNET_NAME__'
param virtualNetworkAddressPrefix = '__REQUIRED_VNET_CIDR__'
param agentSubnetPrefix = '__REQUIRED_AGENT_SUBNET_CIDR__'
param privateEndpointSubnetPrefix = '__REQUIRED_PRIVATE_ENDPOINT_SUBNET_CIDR__'
param firewallPrivateIp = '__REQUIRED_FIREWALL_PRIVATE_IP__'
param expiryDate = '__REQUIRED_EXPIRY_DATE__'
