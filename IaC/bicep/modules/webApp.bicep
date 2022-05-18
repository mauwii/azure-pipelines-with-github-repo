// Parameters
@description('The projects name will be used as the first Part of the resource name and added as a resource tag')
param project string

@description('The environment where you want to use this webapp')
@allowed([
  'dev'
  'stg'
  'prod'
])
param env string

@description('The location where the Resource(s) will be deployed')
param location string

@description('An Array of Name/Value Pairs which defines your Applicationsettings')
param appSettings array

@description('The Runtime you want to use in your WebApp')
@allowed([
  'PYTHON|3.9'
])
param linuxFxVersion string

@description('The AppServicePlan which should be used by the webapp')
param appServicePlanName string

// Variables
var resourceGroup_id = string(uniqueString(resourceGroup().id))
var subscriptionID = string(subscription().id)
var groupName = string(resourceGroup().name)
var serverFarmId = string('/subscriptions/${subscriptionID}/resourceGroups/${groupName}/providers/Microsoft.Web/serverfarms/${appServicePlanName}')
var webAppName = string('${project}-webapp-${env}-${resourceGroup_id}')

resource webapp 'Microsoft.Web/sites@2020-06-01' = {
  name: webAppName
  location: location
  kind: 'app,linux'
  tags: {
    Project: project
  }
  properties: {
    httpsOnly: true
    serverFarmId: serverFarmId
    clientAffinityEnabled: false
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
      appSettings: appSettings
    }
  }
}

output webappId string = webapp.id
