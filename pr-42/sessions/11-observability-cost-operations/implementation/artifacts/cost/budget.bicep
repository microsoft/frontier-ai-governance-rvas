targetScope = 'subscription'

@description('Name of the approved monthly cost budget.')
param budgetName string

@description('Monthly budget amount in the billing currency for this subscription.')
param amount string

@description('Budget start date in ISO 8601 format. The service aligns it to the selected time grain.')
param startDate string

@description('Budget end date in ISO 8601 format.')
param endDate string

@description('Notification email addresses approved by the cost owner.')
param contactEmails array

@description('Azure Monitor action group resource IDs approved for cost notifications.')
param contactGroups array

resource budget 'Microsoft.Consumption/budgets@2023-11-01' = {
  name: budgetName
  properties: {
    amount: int(amount)
    category: 'Cost'
    timeGrain: 'Monthly'
    timePeriod: {
      startDate: startDate
      endDate: endDate
    }
    notifications: {
      Actual80: {
        enabled: true
        operator: 'GreaterThanOrEqualTo'
        threshold: 80
        thresholdType: 'Actual'
        contactEmails: contactEmails
        contactGroups: contactGroups
        contactRoles: []
      }
      Forecast100: {
        enabled: true
        operator: 'GreaterThanOrEqualTo'
        threshold: 100
        thresholdType: 'Forecasted'
        contactEmails: contactEmails
        contactGroups: contactGroups
        contactRoles: []
      }
    }
  }
}

output budgetResourceId string = budget.id
