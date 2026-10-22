targetScope = 'resourceGroup'

@description('Approved scope alias checked by preflight and written as a tag.')
param targetScopeAlias string

@description('Deployment location for Azure Monitor resources.')
param location string = resourceGroup().location

@description('Name of the existing Microsoft Foundry or Azure OpenAI account.')
param foundryAccountName string

@description('Resource ID of the Log Analytics workspace that receives platform logs and metrics.')
param logAnalyticsWorkspaceResourceId string

@description('Name of the diagnostic setting on the Foundry account.')
param diagnosticSettingName string = 'ai-governance-platform-logs'

@description('Name of the action group used by the module alert rules.')
param actionGroupName string

@description('Action group short name. Azure Monitor uses this value in short notifications.')
param actionGroupShortName string

@description('Operations email receiver for alert notifications.')
param actionReceiverEmail string

@description('Stable service name shown in alert names and tags.')
param serviceName string

@allowed([
  'nonproduction'
  'production'
])
@description('Environment label for tags.')
param environment string = 'nonproduction'

@description('Threshold for throttled requests over the alert window.')
param throttledRequestsThreshold string

@description('StatusCode dimension value that represents throttled requests. Confirm it in Metrics Explorer before deployment.')
param throttledStatusCodeValue string = '429'

@description('Threshold for average time to last byte in milliseconds.')
param timeToLastByteThresholdMs string

@description('Threshold for processed inference tokens over the alert window.')
param tokenTransactionThreshold string

@description('Evaluation window for metric alerts.')
@allowed([
  'PT1M'
  'PT5M'
  'PT15M'
  'PT30M'
  'PT1H'
])
param windowSize string = 'PT5M'

@description('Evaluation frequency for metric alerts.')
@allowed([
  'PT1M'
  'PT5M'
  'PT15M'
  'PT30M'
  'PT1H'
])
param evaluationFrequency string = 'PT1M'

var implementationSession = 'optional-module-continuous-evaluation-platform-alerts'
var commonTags = {
  implementationSession: implementationSession
  targetScope: targetScopeAlias
  service: serviceName
  environment: environment
  deploymentLocation: location
}
var actionGroupResourceId = actionGroup.id
var commonActions = [
  {
    actionGroupId: actionGroupResourceId
  }
]

resource foundryAccount 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = {
  name: foundryAccountName
}

resource diagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingName
  scope: foundryAccount
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: 'global'
  tags: commonTags
  properties: {
    groupShortName: actionGroupShortName
    enabled: true
    emailReceivers: [
      {
        name: 'operations-primary'
        emailAddress: actionReceiverEmail
        useCommonAlertSchema: true
      }
    ]
  }
}

resource throttlingAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${serviceName}-${environment}-foundry-throttled-requests'
  location: 'global'
  tags: commonTags
  properties: {
    description: 'Azure OpenAI requests with the confirmed throttling StatusCode dimension exceeded the approved threshold.'
    severity: 2
    enabled: true
    scopes: [
      foundryAccount.id
    ]
    evaluationFrequency: evaluationFrequency
    windowSize: windowSize
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'throttled-requests'
          metricName: 'AzureOpenAIRequests'
          dimensions: [
            {
              name: 'StatusCode'
              operator: 'Include'
              values: [
                throttledStatusCodeValue
              ]
            }
          ]
          operator: 'GreaterThan'
          threshold: int(throttledRequestsThreshold)
          timeAggregation: 'Total'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    actions: commonActions
  }
}

resource latencyAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${serviceName}-${environment}-foundry-latency-high'
  location: 'global'
  tags: commonTags
  properties: {
    description: 'Time to last byte exceeded the approved latency threshold. Compare with token volume before declaring an incident.'
    severity: 3
    enabled: true
    scopes: [
      foundryAccount.id
    ]
    evaluationFrequency: evaluationFrequency
    windowSize: windowSize
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'time-to-last-byte'
          metricName: 'AzureOpenAITTLTInMS'
          dimensions: []
          operator: 'GreaterThan'
          threshold: int(timeToLastByteThresholdMs)
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    actions: commonActions
  }
}

resource tokenUsageAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${serviceName}-${environment}-foundry-token-volume-high'
  location: 'global'
  tags: commonTags
  properties: {
    description: 'Processed inference tokens exceeded the approved operating threshold.'
    severity: 3
    enabled: true
    scopes: [
      foundryAccount.id
    ]
    evaluationFrequency: evaluationFrequency
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'token-volume'
          metricName: 'TokenTransaction'
          dimensions: []
          operator: 'GreaterThan'
          threshold: int(tokenTransactionThreshold)
          timeAggregation: 'Total'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    actions: commonActions
  }
}

output diagnosticSettingResourceId string = diagnosticSetting.id
output actionGroupResourceId string = actionGroup.id
output alertRuleIds array = [
  throttlingAlert.id
  latencyAlert.id
  tokenUsageAlert.id
]
