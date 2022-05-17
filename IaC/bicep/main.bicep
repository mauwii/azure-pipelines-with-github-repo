param project string = 'apwgr'
param env string = 'dev'
param location string = 'westeurope'
param deployment_id string
param keyvault_owner_object_id string

module appserviceplan './modules/appserviceplan.bicep' = {
  name: '${project}-asp-${env}-${deployment_id}'
  kind: 'linux'
  location: location
  sku: {
    tier: sku
    name: skuCode
  }
  properties: {
    targetWorkerSizeId: workerSize
    targetWorkerCount: 1
    reserved: true
  }
}

module keyvault './modules/keyvault.bicep' = {
  name: 'keyvault_deploy_${deployment_id}'
  params: {
    project: project
    env: env
    location: location
    deployment_id: deployment_id
    keyvault_owner_object_id: keyvault_owner_object_id
  }
}

module appinsights './modules/appinsights.bicep' = {
  name: 'appinsights_deploy_${deployment_id}'
  params: {
    project: project
    env: env
    location: location
    deployment_id: deployment_id
  }
}

output appinsights_name string = appinsights.outputs.appinsights_name
output keyvault_name string = keyvault.outputs.keyvault_name
output keyvault_resource_id string = keyvault.outputs.keyvault_resource_id
output loganalytics_name string = loganalytics.outputs.loganalyticswsname
