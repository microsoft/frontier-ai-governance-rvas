using './tag-allocation.bicep'

param targetScope = '__REQUIRED_AI_FINOPS_TARGET_SCOPE_RESOURCE_ID__'
param assignmentIdentityLocation = '__REQUIRED_POLICY_ASSIGNMENT_IDENTITY_LOCATION__'
param assignmentNamePrefix = '__REQUIRED_POLICY_ASSIGNMENT_PREFIX__'
param requiredTags = [
  'CostCenter'
  'AIUseCase'
  'Environment'
  'Owner'
]
