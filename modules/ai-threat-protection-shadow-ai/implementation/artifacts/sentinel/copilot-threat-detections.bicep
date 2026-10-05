targetScope = 'resourceGroup'

@description('Approved implementation scope alias. Preflight checks this before any deployment.')
param targetScopeAlias string

@description('Existing Log Analytics workspace onboarded to Microsoft Sentinel.')
param sentinelWorkspaceName string

@description('Stable rule resource name. The default matches the source Microsoft Sentinel content ID.')
param analyticsRuleName string = 'e5f6a7b8-c9d0-41e2-f3a4-b5c6d7e8f9a0'

@description('Saved-search resource name for the Copilot external-IP hunting query.')
param huntingQueryName string = 'copilot-external-ip-access'

var implementationSession = 'optional-module-ai-threat-protection-shadow-ai'
var jailbreakQuery = loadTextContent('copilot-jailbreak-analytics.kql')
var externalIpQuery = loadTextContent('copilot-external-ip-hunting.kql')

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: sentinelWorkspaceName
}

resource copilotJailbreakRule 'Microsoft.SecurityInsights/alertRules@2025-09-01' = {
  name: analyticsRuleName
  scope: workspace
  kind: 'Scheduled'
  properties: {
    displayName: 'Copilot - Jailbreak Attempt Detected'
    description: 'Detects Copilot interactions where event data reports a jailbreak attempt.'
    enabled: true
    query: jailbreakQuery
    queryFrequency: 'PT5M'
    queryPeriod: 'PT5M'
    severity: 'High'
    triggerOperator: 'GreaterThan'
    triggerThreshold: 0
    suppressionDuration: 'PT5H'
    suppressionEnabled: false
    tactics: [
      'InitialAccess'
      'CredentialAccess'
      'Impact'
    ]
    techniques: [
      'T1078'
      'T1110'
      'T1565'
    ]
    entityMappings: [
      {
        entityType: 'Account'
        fieldMappings: [
          {
            identifier: 'FullName'
            columnName: 'ActorName'
          }
        ]
      }
    ]
    eventGroupingSettings: {
      aggregationKind: 'SingleAlert'
    }
    incidentConfiguration: {
      createIncident: true
      groupingConfiguration: {
        enabled: true
        reopenClosedIncident: false
        lookbackDuration: 'PT5H'
        matchingMethod: 'Selected'
        groupByEntities: [
          'Account'
        ]
        groupByAlertDetails: []
        groupByCustomDetails: []
      }
    }
    customDetails: {
      implementationSession: implementationSession
      targetScopeAlias: targetScopeAlias
      sourceSolution: 'Microsoft Copilot'
    }
    templateVersion: '1.0.0'
  }
}

resource copilotExternalIpHunt 'Microsoft.OperationalInsights/workspaces/savedSearches@2026-03-01' = {
  name: huntingQueryName
  parent: workspace
  properties: {
    category: 'Hunting Queries'
    displayName: 'Copilot - Access From External IP Address'
    query: externalIpQuery
    version: 2
    tags: [
      {
        name: 'Description'
        value: 'Finds Copilot access from IP addresses outside the starter private-range filter. Tune before recurring use.'
      }
      {
        name: 'Tactics'
        value: 'InitialAccess'
      }
      {
        name: 'Techniques'
        value: 'T1078'
      }
      {
        name: 'implementationSession'
        value: implementationSession
      }
      {
        name: 'targetScopeAlias'
        value: targetScopeAlias
      }
    ]
  }
}

output analyticsRuleId string = copilotJailbreakRule.id
output huntingQueryId string = copilotExternalIpHunt.id
output implementationSession string = implementationSession
