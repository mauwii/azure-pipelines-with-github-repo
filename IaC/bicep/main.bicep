param project string = 'apwgr'
param location string = 'westeurope'
param env string = 'dev'
param keyvault_owner_object_id string
param deployment_id string

module appServicePlan './modules/appserviceplan.bicep' = {
  name: '${project}-asp-${env}-${deployment_id}'
  params: {
    deployment_id: deployment_id
    env: env
    project: project
    location: location
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
// output loganalytics_name string = loganalytics.outputs.loganalyticswsname
