@description('The Projects name will be the first Part of the resource name')
param project string

@description('Resource Location.')
param location string

@description('Service tier of the resource SKU.')
@allowed([
  'Free'
  'Basic'
])
param skuTier string

@description('Name of the resource SKU.')
@allowed([
  'F1'
  'B1'
])
param skuName string

@description('Scaling worker size ID.')
param workerSizeId int

@description('Scaling worker count.')
param workerCount int

@description('It is used to make the resource names unique but still predictable')
var resourceGroup_id = uniqueString(resourceGroup().id)

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: '${project}-asp-${resourceGroup_id}'
  location: location
  tags: {
    DisplayName: 'App Service Plan'
  }
  sku: {
    tier: skuTier
    name: skuName
  }
  kind: 'linux'
  properties: {
    targetWorkerSizeId: workerSizeId
    targetWorkerCount: workerCount
    reserved: true
  }
}

output appserviceplan_name string = appServicePlan.name
