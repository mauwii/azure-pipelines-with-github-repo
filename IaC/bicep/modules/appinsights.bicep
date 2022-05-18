@description('The Project`s Name will be the first Part of every Resource`s Name')
param project string
@allowed([
  'dev'
  'stg'
  'prod'
])
param env string
param location string

var resourceGroup_id = uniqueString(resourceGroup().id)

resource appinsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: '${project}-appi-${env}-${resourceGroup_id}'
  location: location
  tags: {
    DisplayName: 'Application Insights'
    Environment: env
  }
  kind: 'other'
  properties: {
    Application_Type: 'other'
  }
}

output appinsights_name string = appinsights.name
