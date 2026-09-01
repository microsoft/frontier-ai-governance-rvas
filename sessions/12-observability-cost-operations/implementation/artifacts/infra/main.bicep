targetScope = 'resourceGroup'

@description('Deployment location for Azure Monitor resources.')
param location string = resourceGroup().location

@description('Workspace-based Application Insights component resource ID.')
param applicationInsightsResourceId string

@description('Azure Monitor action group resource ID.')
param actionGroupResourceId string

@description('Display name for the shared operations workbook.')
param workbookDisplayName string

@description('Stable service name emitted by application telemetry.')
param serviceName string

@allowed([
  'nonproduction'
  'production'
])
param environment string

@description('Request error-rate percentage that opens the operational alert.')
param requestErrorRateThreshold string

@description('Failed tool-call count that opens the tool alert.')
param toolFailureThreshold string

@description('Failed AI quality or safety evaluation count that opens the quality alert.')
param qualityFailureThreshold string

var implementationSession = '12-observability-cost-operations'
var commonTags = {
  implementationSession: implementationSession
  service: serviceName
  environment: environment
}

resource workbook 'Microsoft.Insights/workbooks@2023-06-01' = {
  name: guid(resourceGroup().id, 'rvas-13-operations-workbook')
  location: location
  kind: 'shared'
  tags: commonTags
  properties: {
    displayName: workbookDisplayName
    serializedData: loadTextContent('../monitoring/workbook.json')
    version: '1.0'
    sourceId: applicationInsightsResourceId
    category: 'workbook'
  }
}

resource requestErrorAlert 'Microsoft.Insights/scheduledQueryRules@2023-12-01' = {
  name: '${serviceName}-${environment}-request-error-rate'
  location: location
  kind: 'LogAlert'
  tags: commonTags
  properties: {
    displayName: '${serviceName} request error rate'
    description: 'Request failure percentage exceeded the approved operational SLO.'
    severity: 2
    enabled: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    scopes: [
      applicationInsightsResourceId
    ]
    targetResourceTypes: [
      'microsoft.insights/components'
    ]
    criteria: {
      allOf: [
        {
          query: loadTextContent('../queries/request-error-rate-alert.kql')
          timeAggregation: 'Average'
          metricMeasureColumn: 'ErrorRate'
          operator: 'GreaterThan'
          threshold: int(requestErrorRateThreshold)
          failingPeriods: {
            numberOfEvaluationPeriods: 2
            minFailingPeriodsToAlert: 2
          }
        }
      ]
    }
    actions: {
      actionGroups: [
        actionGroupResourceId
      ]
    }
    autoMitigate: true
    checkWorkspaceAlertsStorageConfigured: false
    skipQueryValidation: false
  }
}

resource toolFailureAlert 'Microsoft.Insights/scheduledQueryRules@2023-12-01' = {
  name: '${serviceName}-${environment}-tool-failures'
  location: location
  kind: 'LogAlert'
  tags: commonTags
  properties: {
    displayName: '${serviceName} tool failures'
    description: 'Tool failures exceeded the approved threshold and remain distinct from model failures.'
    severity: 2
    enabled: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    scopes: [
      applicationInsightsResourceId
    ]
    targetResourceTypes: [
      'microsoft.insights/components'
    ]
    criteria: {
      allOf: [
        {
          query: loadTextContent('../queries/tool-failure-alert.kql')
          timeAggregation: 'Total'
          metricMeasureColumn: 'ToolFailures'
          operator: 'GreaterThanOrEqual'
          threshold: int(toolFailureThreshold)
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    actions: {
      actionGroups: [
        actionGroupResourceId
      ]
    }
    autoMitigate: true
    checkWorkspaceAlertsStorageConfigured: false
    skipQueryValidation: false
  }
}

resource qualitySafetyAlert 'Microsoft.Insights/scheduledQueryRules@2023-12-01' = {
  name: '${serviceName}-${environment}-quality-safety'
  location: location
  kind: 'LogAlert'
  tags: commonTags
  properties: {
    displayName: '${serviceName} AI quality or safety failures'
    description: 'AI evaluation events exceeded the approved quality or safety threshold.'
    severity: 1
    enabled: true
    evaluationFrequency: 'PT15M'
    windowSize: 'PT30M'
    scopes: [
      applicationInsightsResourceId
    ]
    targetResourceTypes: [
      'microsoft.insights/components'
    ]
    criteria: {
      allOf: [
        {
          query: loadTextContent('../queries/quality-safety-alert.kql')
          timeAggregation: 'Total'
          metricMeasureColumn: 'EvaluationFailures'
          operator: 'GreaterThanOrEqual'
          threshold: int(qualityFailureThreshold)
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    actions: {
      actionGroups: [
        actionGroupResourceId
      ]
    }
    autoMitigate: false
    checkWorkspaceAlertsStorageConfigured: false
    skipQueryValidation: false
  }
}

output workbookResourceId string = workbook.id
output requestErrorAlertResourceId string = requestErrorAlert.id
output toolFailureAlertResourceId string = toolFailureAlert.id
output qualitySafetyAlertResourceId string = qualitySafetyAlert.id
