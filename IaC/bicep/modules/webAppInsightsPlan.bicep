@allowed([
  'dev'
  'stg'
  'prod'
])
param envs array

@allowed([
  'Free'
])
param sku string = 'Free'
@allowed([
  'F1'
])
param skuCode string = 'F1'
param project string
param workerSize int = 0
param location string
param resourceGroup_id string

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: '${project}-asp-${resourceGroup_id}'
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

module webAppInsights './webAppInsights.bicep' = [for (env, i) in envs: {
  name: '${project}-webapp-${env}-${resourceGroup_id}'
  params: {
    appServicePlan: {
      serverFarmId: appServicePlan.id
    }
    resourceGroup_id: resourceGroup_id
    env: env
    location: location
    project: project
  }
}]

output appinsights_name array = [for (env, i) in envs: webAppInsights[i].outputs.appinsights_name]
output webapp_name array = [for (env, i) in envs: webAppInsights[i].outputs.webapp_name]
