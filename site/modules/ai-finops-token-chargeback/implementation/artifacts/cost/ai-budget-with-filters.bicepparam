using './ai-budget-with-filters.bicep'

param targetScope = '__REQUIRED_AI_FINOPS_TARGET_SCOPE_RESOURCE_ID__'
param budgetName = '__REQUIRED_AI_BUDGET_NAME__'
param monthlyBudgetAmount = '__REQUIRED_MONTHLY_AI_BUDGET_AMOUNT__'
param startDate = '__REQUIRED_BUDGET_START_DATE__'
param endDate = '__REQUIRED_BUDGET_END_DATE__'
param actualThresholdPercent = '__REQUIRED_ACTUAL_BUDGET_THRESHOLD_PERCENT__'
param forecastThresholdPercent = '__REQUIRED_FORECAST_BUDGET_THRESHOLD_PERCENT__'
param contactEmails = [
  '__REQUIRED_COST_NOTIFICATION_EMAIL__'
]
param contactGroups = [
  '__REQUIRED_BUDGET_ACTION_GROUP_RESOURCE_ID__'
]
param resourceGroupFilterValues = [
  '__REQUIRED_AI_RESOURCE_GROUP_NAME__'
]
param meterCategoryFilterValues = [
  '__REQUIRED_AI_METER_CATEGORY__'
]
