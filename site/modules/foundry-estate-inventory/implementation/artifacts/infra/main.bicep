targetScope = 'resourceGroup'

@description('Azure region for the shared workbook resource.')
param location string = resourceGroup().location

@description('Display name for the Azure AI estate and lifecycle workbook.')
param workbookDisplayName string = 'Azure AI estate and lifecycle review'

@description('Workbook source context for Azure Resource Graph and ARM queries.')
param workbookSourceId string = 'Azure Monitor'

resource workbook 'Microsoft.Insights/workbooks@2023-06-01' = {
  name: guid(resourceGroup().id, 'foundry-estate-inventory-workbook')
  location: location
  kind: 'shared'
  tags: {
    implementationModule: 'foundry-estate-inventory'
  }
  properties: {
    displayName: workbookDisplayName
    serializedData: loadTextContent('../monitoring/estate-lifecycle-workbook.json')
    version: '1.0'
    sourceId: workbookSourceId
    category: 'workbook'
  }
}

output workbookResourceId string = workbook.id
