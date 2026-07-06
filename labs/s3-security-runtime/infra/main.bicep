targetScope = 'subscription'

@description('Azure region for the resource group and Azure AI Content Safety account.')
param location string = deployment().location

@description('Resource group that will contain the S3 Azure-plane resources.')
param resourceGroupName string = 'rg-rvas-s3-security-runtime'

@description('Globally unique Azure AI Content Safety account name. Use only lowercase letters, numbers, and hyphens.')
param contentSafetyAccountName string

@description('SKU for the Azure AI Content Safety account.')
@allowed([
  'F0'
  'S0'
])
param contentSafetySku string = 'S0'

@description('Disable local key authentication. Set true when the customer is ready for Entra-only access.')
param disableLocalAuth bool = false

@description('Set true only when the customer approves Defender for Cloud AI pricing/plan changes through IaC.')
param enableDefenderAiPricing bool = false

@description('Defender for Cloud pricing tier to apply if enableDefenderAiPricing is true.')
@allowed([
  'Free'
  'Standard'
])
param defenderPricingTier string = 'Standard'

@description('Tags applied to deployed resources.')
param tags object = {
  workload: 'rvas-s3-security-runtime'
  session: 'S3'
}

resource labRg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

resource defenderAiPricing 'Microsoft.Security/pricings@2024-01-01' = if (enableDefenderAiPricing) {
  name: 'AI'
  properties: {
    pricingTier: defenderPricingTier
  }
}

module contentSafety 'modules/content-safety.bicep' = {
  name: 'rvas-s3-content-safety'
  scope: labRg
  params: {
    accountName: contentSafetyAccountName
    location: location
    skuName: contentSafetySku
    disableLocalAuth: disableLocalAuth
    tags: tags
  }
}

output contentSafetyEndpoint string = contentSafety.outputs.endpoint
output contentSafetyResourceId string = contentSafety.outputs.resourceId
output defenderAiPricingConfigured bool = enableDefenderAiPricing
