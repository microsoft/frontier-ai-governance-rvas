using '../policy/assignment.bicep'

var decisions = loadJsonContent('../policy/guardrail-decisions.json')

param initiativeName = decisions.initiativeName
param assignmentName = decisions.assignmentName
param location = decisions.deploymentLocation
param targetScopeResourceId = decisions.targetScopeResourceId
param enforcementMode = decisions.effects.enforcementMode
param networkAccessEffect = decisions.effects.networkAccess
param localAuthenticationEffect = decisions.effects.localAuthentication
param deploymentSkuEffect = decisions.effects.deploymentSku
param contentFilterEffect = decisions.effects.contentFilterMinimum
param diagnosticLogsEffect = decisions.effects.diagnosticLogs
param disallowedDeploymentSkus = decisions.dataResidency.disallowedDeploymentSkus
param allowedSeveritiesForPrompt = decisions.contentFilters.minimumPromptSeverities
param allowedEnabledForPrompt = decisions.contentFilters.promptMustBeEnabled
param allowedBlockingForPrompt = decisions.contentFilters.promptMustBlock
param allowedSeveritiesForCompletion = decisions.contentFilters.minimumCompletionSeverities
param allowedEnabledForCompletion = decisions.contentFilters.completionMustBeEnabled
param allowedBlockingForCompletion = decisions.contentFilters.completionMustBlock
param diagnosticSettingName = decisions.diagnosticLogs.diagnosticSettingName
param diagnosticCategoryGroup = decisions.diagnosticLogs.categoryGroup
param diagnosticResourceLocationList = decisions.diagnosticLogs.resourceLocationList
param logAnalyticsWorkspaceResourceId = decisions.diagnosticLogs.logAnalyticsWorkspaceResourceId
