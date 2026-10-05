targetScope = 'subscription'

@description('Approved implementation scope alias. Preflight checks this before any deployment.')
param targetScopeAlias string

@description('Set to True or False. Enables suspicious prompt evidence for Defender for Cloud AI alerts.')
param isAIPromptEvidenceEnabled string

@description('Set to True or False. Enables Microsoft Purview data security for AI interactions where supported and licensed.')
param isAIPromptSharingWithPurviewEnabled string

var implementationSession = 'optional-module-ai-threat-protection-shadow-ai'

resource defenderForAI 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'AI'
  properties: {
    pricingTier: 'Standard'
    extensions: [
      {
        name: 'AIPromptEvidence'
        isEnabled: isAIPromptEvidenceEnabled
      }
      {
        name: 'AIPromptSharingWithPurview'
        isEnabled: isAIPromptSharingWithPurviewEnabled
      }
    ]
  }
}

output defenderForAIPlanId string = defenderForAI.id
output implementationSession string = implementationSession
output approvedTargetScopeAlias string = targetScopeAlias
