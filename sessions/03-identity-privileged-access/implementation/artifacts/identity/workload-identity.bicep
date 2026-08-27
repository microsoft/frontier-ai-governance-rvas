targetScope = 'resourceGroup'

var roleDefinitions = loadJsonContent('role-definitions.json')

@description('Dedicated workload identity name.')
@minLength(3)
@maxLength(128)
param workloadIdentityName string = 'id-rvas-s03-workload'

@description('Azure region for the user-assigned managed identity.')
param location string = resourceGroup().location

@description('Existing Microsoft Foundry resource name.')
param foundryAccountName string

@description('Existing storage account approved as the workload data boundary.')
param storageAccountName string

@description('GitHub organization or account that owns the repository.')
param githubOwner string

@description('GitHub repository name without the owner prefix.')
param githubRepository string

@description('Protected GitHub environment trusted by this identity.')
param githubEnvironment string = '__REQUIRED_GITHUB_ENVIRONMENT__'

@description('Review date for the sandbox identity in YYYY-MM-DD format.')
param expiryDate string

var marker = '03-identity-privileged-access'
var githubSubject = 'repo:${githubOwner}/${githubRepository}:environment:${githubEnvironment}'

resource workloadIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: workloadIdentityName
  location: location
  tags: {
    implementationSession: marker
    environment: 'sandbox'
    purpose: 'secretless-model-and-blob-access'
    expiryDate: expiryDate
  }
}

resource githubFederation 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2024-11-30' = {
  parent: workloadIdentity
  name: 'github-${githubEnvironment}'
  properties: {
    audiences: [
      'api://AzureADTokenExchange'
    ]
    issuer: 'https://token.actions.githubusercontent.com'
    subject: githubSubject
  }
}

resource foundryAccount 'Microsoft.CognitiveServices/accounts@2026-05-01' existing = {
  name: foundryAccountName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-06-01' existing = {
  name: storageAccountName
}

resource cognitiveServicesUser 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: roleDefinitions.roles.cognitiveServicesUser.id
}

resource storageBlobDataReader 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: roleDefinitions.roles.storageBlobDataReader.id
}

resource modelInferenceAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: foundryAccount
  name: guid(foundryAccount.id, workloadIdentity.id, cognitiveServicesUser.id)
  properties: {
    roleDefinitionId: cognitiveServicesUser.id
    principalId: workloadIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource blobReadAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: guid(storageAccount.id, workloadIdentity.id, storageBlobDataReader.id)
  properties: {
    roleDefinitionId: storageBlobDataReader.id
    principalId: workloadIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

output clientId string = workloadIdentity.properties.clientId
output principalId string = workloadIdentity.properties.principalId
output federatedSubject string = githubSubject
output permittedRoleIds array = [
  cognitiveServicesUser.name
  storageBlobDataReader.name
]
