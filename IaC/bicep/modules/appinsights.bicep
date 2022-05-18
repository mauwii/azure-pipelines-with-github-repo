@description('The Project`s Name will be the first Part of every Resource`s Name')
param project string

@description('The location where the Resource(s) will be deployed')
param location string

@description('It is used to make the resource names unique but still predictable')
var resourceGroup_id = uniqueString(resourceGroup().id)

@description('Name of the Resource')
var name = '${project}-appi-${resourceGroup_id}'

resource appinsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: name
  location: location
  tags: {
    Project: project
  }
  kind: 'other'
  properties: {
    Application_Type: 'other'
  }
}

output appinsights_name string = appinsights.name
