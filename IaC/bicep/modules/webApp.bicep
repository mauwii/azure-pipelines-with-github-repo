@description('The projects name will be used as the first Part of the resource name and added as a resource tag')
param project string

@description('The location where the Resource will be deployed')
param location string

@description('An Array of Name/Value Pairs which defines your Applicationsettings')
param appSettings array

@description('The Runtime you want to use in your WebApp')
@allowed([
  'PYTHON|3.9'
])
param linuxFxVersion string

@description('The id of the AppServicePlan which should be used by the webapp')
param serverFarmId string

resource webapp 'Microsoft.Web/sites@2020-06-01' = {
  name: 'webApp-Module'
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
