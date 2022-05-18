@description('The Projects name will be the first Part of the resource name')
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

@description('It is used to make the resource names unique but still predictable')
param resourceGroup_id string = uniqueString(resourceGroup().id)

@description('The Runtime you want to use in your WebApp')
@allowed([
  'PYTHON|3.9'
])
param linuxFxVersion string

@description('The AppServicePlan which should be used by the webapp')
param appServicePlan object

resource webapp 'Microsoft.Web/sites@2020-06-01' = {
  name: '${project}-webapp-${env}-${resourceGroup_id}'
  location: location
  kind: 'app,linux'
  properties: {
    httpsOnly: true
    serverFarmId: appServicePlan.serverFarmId
    clientAffinityEnabled: false
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
      appSettings: appSettings
    }
  }
}

output webapp_name string = webapp.name
