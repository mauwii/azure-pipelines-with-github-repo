@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object = {}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'applicationInsights-Module'
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

output applicationInsightsId string = applicationInsights.id
output InstrumentationKey string = applicationInsights.properties.InstrumentationKey
output ConnectionString string = applicationInsights.properties.ConnectionString
