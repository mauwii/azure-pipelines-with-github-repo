@description('This will be the first Part of the resource name and added as a resource tag')
param project string

@description('The environment where you want to use this webapp')
@allowed([
  'dev'
  'stg'
  'prod'
])
param env string

param tags object = {
  project: project
}

@description('The location where the Resource(s) will be deployed')
param location string

@description('The Runtime you want to use in your WebApp')
@allowed([
  'PYTHON|3.9'
])
param linuxFxVersion string = 'PYTHON|3.9'

param appServicePlanSku object = {
  name: 'F1'
  tier: 'Free'
}

@description('Scaling worker size ID.')
param workerSizeId int

@description('Scaling worker count.')
param workerCount int

// Variables
var resourceGroup_id = string(uniqueString(resourceGroup().id))
var appServicePlanName = string('${project}-asp-${resourceGroup_id}')
var webAppName = string('${project}-webapp-${env}-${resourceGroup_id}')
var appInsightsName = string('${project}-appi-${resourceGroup_id}')

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    DisableIpMasking: false
    DisableLocalAuth: false
    Flow_Type: 'Bluefield'
    ForceCustomerStorageForProfiler: false
    ImmediatePurgeDataOn30Days: true
    IngestionMode: 'ApplicationInsights'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Disabled'
    Request_Source: 'rest'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: appServicePlanSku
  kind: 'linux'
  properties: {
    targetWorkerSizeId: workerSizeId
    targetWorkerCount: workerCount
    reserved: true
  }
}

resource webapp 'Microsoft.Web/sites@2020-06-01' = {
  name: webAppName
  location: location
  kind: 'app,linux'
  tags: tags
  properties: {
    httpsOnly: true
    serverFarmId: appServicePlan.id
    clientAffinityEnabled: false
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'default'
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~2'
        }
      ]
    }
  }
}
