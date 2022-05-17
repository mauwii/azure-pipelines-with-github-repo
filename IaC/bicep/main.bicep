@description('Unique ID defined by the resource group id')
param resourceGroup_id string = uniqueString(resourceGroup().id)
@description('Location where all resources will be deployed to')
param location string = 'westeurope'
@description('The Project Name will be used in front of your resource names')
param project string
@allowed([
  'dev'
  'stg'
  'prod'
])
param env array = [
  'dev'
  'stg'
  'prod'
]

module webAppInsightsPlan './modules/webAppInsightsPlan.bicep' = {
  name: project
  params: {
    envs: env
    resourceGroup_id: resourceGroup_id
    location: location
    project: project
  }
}

output appinsights_name array = webAppInsightsPlan.outputs.appinsights_name
output webapp_name array = webAppInsightsPlan.outputs.webapp_name
