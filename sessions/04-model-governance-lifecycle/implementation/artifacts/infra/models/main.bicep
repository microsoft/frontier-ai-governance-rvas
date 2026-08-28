targetScope = 'resourceGroup'

@description('Name of the existing Microsoft Foundry resource.')
param foundryAccountName string

var deploymentProfiles = loadJsonContent('../../models/deployment-profiles.json')

resource foundryAccount 'Microsoft.CognitiveServices/accounts@2026-05-01' existing = {
  name: foundryAccountName
}

resource approvedModelDeployments 'Microsoft.CognitiveServices/accounts/deployments@2026-05-01' = [for deployment in deploymentProfiles.deployments: {
  name: deployment.deploymentName
  parent: foundryAccount
  sku: {
    name: deployment.sku.name
    capacity: deployment.sku.capacity
  }
  properties: {
    model: {
      format: deployment.model.format
      name: deployment.model.name
      version: deployment.model.version
    }
    raiPolicyName: deployment.raiPolicyName
    versionUpgradeOption: deployment.versionUpgradeOption
  }
  tags: {
    implementationSession: deploymentProfiles.implementationSession
    modelApprovalId: deployment.approvalId
  }
}]

output deploymentIds array = [for (_, index) in deploymentProfiles.deployments: approvedModelDeployments[index].id]
output deploymentNames array = [for (_, index) in deploymentProfiles.deployments: approvedModelDeployments[index].name]
output deploymentSkus array = [for (_, index) in deploymentProfiles.deployments: approvedModelDeployments[index].sku.name]
