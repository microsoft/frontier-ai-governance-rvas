using 'model-governance.bicep'

var register = loadJsonContent('../model-approval-register.json')

// Resolve both definition IDs by display name before deployment. Preflight rejects empty values.
param approvedModelsPolicyDefinitionId = readEnvironmentVariable('RVAS_APPROVED_MODELS_POLICY_ID')
param eligibilityPolicyDefinitionId = readEnvironmentVariable('RVAS_MODEL_ELIGIBILITY_POLICY_ID')

param assignmentEffect = register.assignmentEffect
param allowedPublishers = register.allowedPublishers
param allowedAssetIds = register.allowedAssetIds
param onlyAllowDirectFromAzure = register.eligibility.onlyAllowDirectFromAzure
param denyPreviewModels = register.eligibility.denyPreviewModels
