targetScope = 'resourceGroup'

@description('Short lowercase prefix used in implementation resource names.')
@minLength(3)
@maxLength(20)
param namePrefix string = 'rvas01'

@description('Foundry child-project name.')
@minLength(2)
@maxLength(64)
param projectName string = 'platform-baseline'

@description('Approved Azure region for the implementation baseline.')
param location string = resourceGroup().location

@description('Approved account network pattern. This input has no implicit default.')
@allowed([
  'public'
  'public-private-inbound'
  'byo-vnet'
])
param networkPattern string

@description('Canonical desired public-access state. Session 03 records its private-network cutover before later Session 01 reconciliations.')
param publicNetworkAccess string = 'Enabled'

@description('Resource ID of the dedicated Microsoft.App/environments delegated subnet. Required for byo-vnet.')
param agentSubnetResourceId string = ''

@description('Business owner team alias. Do not use a personal email address.')
param businessOwner string

@description('Technical owner team alias.')
param technicalOwner string

@description('Approved classification for synthetic implementation data.')
param dataClassification string

@description('Implementation service criticality.')
param criticality string

@description('Sandbox cost allocation code.')
param costCenter string

@description('ISO date when the sandbox owner must decide whether to keep or remove the resources.')
@minLength(10)
@maxLength(32)
param expiryDate string

var resourceSuffix = uniqueString(subscription().subscriptionId, resourceGroup().id)
var foundryName = take(toLower('${namePrefix}-${resourceSuffix}'), 64)
var logAnalyticsName = take(toLower('log-${namePrefix}-${resourceSuffix}'), 63)
var applicationInsightsName = take(toLower('appi-${namePrefix}-${resourceSuffix}'), 255)

var commonTags = {
  implementationSession: '01-platform-baseline'
  environment: 'sandbox'
  businessOwner: businessOwner
  technicalOwner: technicalOwner
  dataClassification: dataClassification
  criticality: criticality
  costCenter: costCenter
  expiryDate: expiryDate
}

resource foundry 'Microsoft.CognitiveServices/accounts@2026-05-01' = {
  name: foundryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'AIServices'
  sku: {
    name: 'S0'
  }
  tags: commonTags
  properties: {
    allowProjectManagement: true
    customSubDomainName: foundryName
    disableLocalAuth: true
    publicNetworkAccess: publicNetworkAccess
    restrictOutboundNetworkAccess: networkPattern == 'byo-vnet'
    networkInjections: networkPattern == 'byo-vnet' ? [
      {
        scenario: 'agent'
        subnetArmId: agentSubnetResourceId
        useMicrosoftManagedNetwork: false
      }
    ] : []
  }
}

resource project 'Microsoft.CognitiveServices/accounts/projects@2026-05-01' = {
  name: projectName
  parent: foundry
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: commonTags
  properties: {
    displayName: 'RVAS Session 01 platform baseline'
    description: 'Governed sandbox baseline for the AI governance implementation series.'
  }
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
  tags: commonTags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  tags: commonTags
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource applicationInsightsConnection 'Microsoft.CognitiveServices/accounts/projects/connections@2026-05-01' = {
  name: 'applicationinsights'
  parent: project
  properties: {
    category: 'AppInsights'
    target: applicationInsights.id
    // Stable baseline path. ProjectManagedIdentity trace ingestion remains a preview upgrade decision.
    authType: 'ApiKey'
    isSharedToAll: true
    credentials: {
      key: applicationInsights.properties.ConnectionString
    }
    metadata: {
      ApiType: 'Azure'
      ResourceId: applicationInsights.id
    }
  }
}

output foundryName string = foundry.name
output foundryResourceId string = foundry.id
output foundryPrincipalId string = foundry.identity.principalId
output projectName string = project.name
output projectResourceId string = project.id
output projectPrincipalId string = project.identity.principalId
output logAnalyticsResourceId string = logAnalytics.id
output applicationInsightsResourceId string = applicationInsights.id
output applicationInsightsConnectionId string = applicationInsightsConnection.id
