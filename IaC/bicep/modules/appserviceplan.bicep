param project string
@allowed([
  'dev'
  'stg'
  'prod'
])
param env string
param location string = resourceGroup().location
param deployment_id string
@allowed([
  'Free'
])
param sku string = 'Free'
@allowed([
  'F1'
])
param skuCode string = 'F1'
param workerSize int = 0

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: '${project}-asp-${env}-${deployment_id}'
  location: location
  tags: {
    DisplayName: 'App Service Plan'
  }
  sku: {
    tier: sku
    name: skuCode
  }
  kind: 'linux'
  properties: {
    targetWorkerSizeId: workerSize
    targetWorkerCount: 1
    reserved: true
  }
}

output appserviceplan_name string = appServicePlan.name
