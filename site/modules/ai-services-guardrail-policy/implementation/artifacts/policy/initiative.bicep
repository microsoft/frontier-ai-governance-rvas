targetScope = 'subscription'

@minLength(3)
@maxLength(64)
@description('Stable customer-owned name for the Microsoft Foundry AI services guardrail initiative.')
param initiativeName string

@description('Built-in policy: Azure AI Services resources should restrict network access.')
param networkAccessPolicyId string = '/providers/Microsoft.Authorization/policyDefinitions/037eea7a-bd0a-46c5-9a66-03aea78705d3'

@description('Built-in policy: Azure AI Services resources should have key access disabled.')
param localAuthenticationPolicyId string = '/providers/Microsoft.Authorization/policyDefinitions/71ef260a-8f18-47b7-abcb-62d0673d94dc'

@description('Built-in policy: Cognitive Services deployments should only use allowed control.')
param contentFilterPolicyId string = '/providers/Microsoft.Authorization/policyDefinitions/930f48f9-f07e-427c-9494-52603581c6a9'

@description('Built-in policy: enable logging by category group for Cognitive Services to Log Analytics.')
param diagnosticLogsPolicyId string = '/providers/Microsoft.Authorization/policyDefinitions/55d1f543-d1b0-4811-9663-d6d0dbc6326d'

var skuPolicyDefinition = loadJsonContent('definitions/restrict-foundry-deployment-sku.json')
var contentFilterNames = [
  'Hate'
  'Sexual'
  'Violence'
  'Selfharm'
]
var contentFilterDefinitions = [
  for filterName in contentFilterNames: {
    policyDefinitionId: contentFilterPolicyId
    policyDefinitionReferenceId: 'content-filter-${toLower(filterName)}'
    parameters: {
      effect: {
        value: '[parameters(\'contentFilterEffect\')]'
      }
      filterName: {
        value: filterName
      }
      allowedSeveritiesForPrompt: {
        value: '[parameters(\'allowedSeveritiesForPrompt\')]'
      }
      allowedEnabledForPrompt: {
        value: '[parameters(\'allowedEnabledForPrompt\')]'
      }
      allowedBlockingForPrompt: {
        value: '[parameters(\'allowedBlockingForPrompt\')]'
      }
      allowedSeveritiesForCompletion: {
        value: '[parameters(\'allowedSeveritiesForCompletion\')]'
      }
      allowedEnabledForCompletion: {
        value: '[parameters(\'allowedEnabledForCompletion\')]'
      }
      allowedBlockingForCompletion: {
        value: '[parameters(\'allowedBlockingForCompletion\')]'
      }
    }
  }
]

resource skuPolicy 'Microsoft.Authorization/policyDefinitions@2025-03-01' = {
  name: skuPolicyDefinition.name
  properties: skuPolicyDefinition.properties
}

resource initiative 'Microsoft.Authorization/policySetDefinitions@2025-03-01' = {
  name: initiativeName
  properties: {
    displayName: 'Azure Policy guardrails for Microsoft Foundry AI services'
    description: 'Stages account hardening, deployment SKU, content-filter, and diagnostic-log guardrails for Microsoft Foundry and Azure AI services resources.'
    policyType: 'Custom'
    version: '1.0.0'
    metadata: {
      category: 'AI Governance'
      implementationSession: 'optional-module-ai-services-guardrail-policy'
      owner: 'AI platform policy owner'
    }
    parameters: {
      networkAccessEffect: {
        type: 'String'
        allowedValues: [
          'Audit'
          'Deny'
          'Disabled'
        ]
        metadata: {
          displayName: 'Network access effect'
          description: 'Effect for restricting public network access and default network ACL behavior.'
        }
      }
      localAuthenticationEffect: {
        type: 'String'
        allowedValues: [
          'Audit'
          'Deny'
          'Disabled'
        ]
        metadata: {
          displayName: 'Local authentication effect'
          description: 'Effect for requiring Microsoft Entra authentication instead of key access.'
        }
      }
      deploymentSkuEffect: {
        type: 'String'
        allowedValues: [
          'Audit'
          'Deny'
          'Disabled'
        ]
        metadata: {
          displayName: 'Deployment SKU effect'
          description: 'Effect for the custom policy that blocks disallowed Foundry deployment SKUs.'
        }
      }
      disallowedDeploymentSkus: {
        type: 'Array'
        metadata: {
          displayName: 'Disallowed deployment SKUs'
          description: 'Foundry deployment SKU names excluded by the data-residency decision.'
        }
      }
      contentFilterEffect: {
        type: 'String'
        allowedValues: [
          'Audit'
          'Disabled'
        ]
        metadata: {
          displayName: 'Content filter effect'
          description: 'Effect for minimum content-filter settings. The preview built-in is audit-only.'
        }
      }
      allowedSeveritiesForPrompt: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed prompt severities'
          description: 'Accepted severity thresholds for prompt-side content filters.'
        }
      }
      allowedEnabledForPrompt: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed prompt enabled values'
          description: 'Accepted enabled values for prompt-side content filters.'
        }
      }
      allowedBlockingForPrompt: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed prompt blocking values'
          description: 'Accepted blocking values for prompt-side content filters.'
        }
      }
      allowedSeveritiesForCompletion: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed completion severities'
          description: 'Accepted severity thresholds for completion-side content filters.'
        }
      }
      allowedEnabledForCompletion: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed completion enabled values'
          description: 'Accepted enabled values for completion-side content filters.'
        }
      }
      allowedBlockingForCompletion: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed completion blocking values'
          description: 'Accepted blocking values for completion-side content filters.'
        }
      }
      diagnosticLogsEffect: {
        type: 'String'
        allowedValues: [
          'AuditIfNotExists'
          'DeployIfNotExists'
          'Disabled'
        ]
        metadata: {
          displayName: 'Diagnostic logs effect'
          description: 'Effect for routing Cognitive Services logs to Log Analytics.'
        }
      }
      diagnosticSettingName: {
        type: 'String'
        metadata: {
          displayName: 'Diagnostic setting name'
          description: 'Name created by the diagnostic-log policy.'
        }
      }
      diagnosticCategoryGroup: {
        type: 'String'
        allowedValues: [
          'audit'
          'allLogs'
        ]
        metadata: {
          displayName: 'Diagnostic category group'
          description: 'Diagnostic category group routed to Log Analytics.'
        }
      }
      diagnosticResourceLocationList: {
        type: 'Array'
        metadata: {
          displayName: 'Diagnostic resource locations'
          description: 'Locations selected for diagnostic-log evaluation. Use * only when all locations are approved.'
        }
      }
      logAnalyticsWorkspaceResourceId: {
        type: 'String'
        metadata: {
          displayName: 'Log Analytics workspace resource ID'
          description: 'Workspace that receives diagnostic logs.'
          strongType: 'omsWorkspace'
        }
      }
    }
    policyDefinitions: concat([
      {
        policyDefinitionId: networkAccessPolicyId
        policyDefinitionReferenceId: 'restrict-network-access'
        parameters: {
          effect: {
            value: '[parameters(\'networkAccessEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: localAuthenticationPolicyId
        policyDefinitionReferenceId: 'disable-local-authentication'
        parameters: {
          effect: {
            value: '[parameters(\'localAuthenticationEffect\')]'
          }
        }
      }
      {
        policyDefinitionId: skuPolicy.id
        policyDefinitionReferenceId: 'restrict-deployment-sku'
        parameters: {
          effect: {
            value: '[parameters(\'deploymentSkuEffect\')]'
          }
          disallowedDeploymentSkus: {
            value: '[parameters(\'disallowedDeploymentSkus\')]'
          }
        }
      }
    ], contentFilterDefinitions, [
      {
        policyDefinitionId: diagnosticLogsPolicyId
        policyDefinitionReferenceId: 'diagnostic-logs-log-analytics'
        parameters: {
          effect: {
            value: '[parameters(\'diagnosticLogsEffect\')]'
          }
          diagnosticSettingName: {
            value: '[parameters(\'diagnosticSettingName\')]'
          }
          categoryGroup: {
            value: '[parameters(\'diagnosticCategoryGroup\')]'
          }
          resourceLocationList: {
            value: '[parameters(\'diagnosticResourceLocationList\')]'
          }
          logAnalytics: {
            value: '[parameters(\'logAnalyticsWorkspaceResourceId\')]'
          }
        }
      }
    ])
  }
}

output initiativeDefinitionId string = initiative.id
output customSkuPolicyDefinitionId string = skuPolicy.id
output policyDefinitionReferenceIds array = map(initiative.properties.policyDefinitions, item => item.policyDefinitionReferenceId)
