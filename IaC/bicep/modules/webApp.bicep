param project string
@allowed([
  'dev'
  'stg'
  'prod'
])
param env string
param location string
param deployment_id string
param linuxFxVersion string = 'PYTHON|3.9'
param appServicePlan object
@secure()
param appinsights object

resource webapp 'Microsoft.Web/sites@2020-06-01' = {
  name: '${project}-webapp-${env}-${deployment_id}'
  location: location
  kind: 'app,linux'
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

output webapp_name string = webapp.name
