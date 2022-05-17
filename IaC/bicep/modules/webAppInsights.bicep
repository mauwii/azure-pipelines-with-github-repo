@allowed([
  'dev'
  'stg'
  'prod'
])
param env string
param project string
param location string
param resourceGroup_id string
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
      linuxFxVersion: 'PYTHON|3.9'
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appinsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appinsights.properties.ConnectionString
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

resource appinsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: '${project}-appinsght-${env}-${resourceGroup_id}'
  location: location
  tags: {
    DisplayName: 'Application Insights ${env}'
    Environment: env
  }
  kind: 'other'
  properties: {
    Application_Type: 'other'
  }
}

output appinsights_name string = appinsights.name
output webapp_name string = webapp.name
