using './budget.bicep'

param budgetName = '__REQUIRED_BUDGET_NAME__'
param amount = '__REQUIRED_MONTHLY_BUDGET_AMOUNT__'
param startDate = '__REQUIRED_BUDGET_START_DATE__'
param endDate = '__REQUIRED_BUDGET_END_DATE__'
param contactEmails = [
  '__REQUIRED_COST_NOTIFICATION_EMAIL__'
]
param contactGroups = [
  '__REQUIRED_ACTION_GROUP_RESOURCE_ID__'
]
