targetScope = 'subscription'

@description('Exact subscription scope approved for this AI budget. Preflight checks this value against the operator input.')
param targetScope string

@description('Name of the approved monthly AI cost budget.')
param budgetName string

@description('Monthly budget amount in the subscription billing currency. String keeps unresolved sentinels compilable.')
param monthlyBudgetAmount string

@description('Budget time grain.')
@allowed([
  'Monthly'
  'Quarterly'
  'Annually'
])
param timeGrain string = 'Monthly'

@description('Budget start date in YYYY-MM-DD format.')
param startDate string

@description('Budget end date in YYYY-MM-DD format.')
param endDate string

@description('Actual-cost notification threshold as a percent.')
param actualThresholdPercent string

@description('Forecasted-cost notification threshold as a percent.')
param forecastThresholdPercent string

@description('Email addresses approved for budget notifications.')
param contactEmails array

@description('Azure Monitor action group resource IDs approved for budget automation.')
param contactGroups array

@description('Resource group names included in this AI budget.')
param resourceGroupFilterValues array

@description('Meter categories included in this AI budget. Confirm values against Cost analysis before deployment.')
param meterCategoryFilterValues array

resource aiBudget 'Microsoft.Consumption/budgets@2023-11-01' = {
  name: budgetName
  properties: {
    category: 'Cost'
    amount: int(monthlyBudgetAmount)
    timeGrain: timeGrain
    timePeriod: {
      startDate: startDate
      endDate: endDate
    }
    notifications: {
      ActualThreshold: {
        enabled: true
        operator: 'GreaterThanOrEqualTo'
        threshold: int(actualThresholdPercent)
        thresholdType: 'Actual'
        contactEmails: contactEmails
        contactRoles: []
        contactGroups: contactGroups
      }
      ForecastThreshold: {
        enabled: true
        operator: 'GreaterThanOrEqualTo'
        threshold: int(forecastThresholdPercent)
        thresholdType: 'Forecasted'
        contactEmails: contactEmails
        contactRoles: []
        contactGroups: contactGroups
      }
    }
    filter: {
      and: [
        {
          dimensions: {
            name: 'ResourceGroupName'
            operator: 'In'
            values: resourceGroupFilterValues
          }
        }
        {
          dimensions: {
            name: 'MeterCategory'
            operator: 'In'
            values: meterCategoryFilterValues
          }
        }
      ]
    }
  }
}

output budgetResourceId string = aiBudget.id
output approvedTargetScope string = targetScope
