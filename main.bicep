@description('That name is the name of our application. It has to be unique.Type a name followed by your resource group name. (<name>-<resourceGroupName>)')
param webAppName string = 'django-gh-dev${uniqueString(resourceGroup().id)}'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Runtime Stack of the Application')
param linuxFxVersion string = 'PYTHON|3.9'

@secure()
@description('Secret Key of your Django App which you should not share with anybody!')
param secretKey string

var sku = 'Free'
var skuCode = 'F1'
var workerSize = 0
var appInsights_var = '${webAppName}-insights'
var appServicePlanName_var = '${webAppName}-asp'

resource webApp 'Microsoft.Web/sites@2020-06-01' = {
  name: webAppName
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
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'default'
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~2'
        }
        {
          name: 'SECRET_KEY'
          value: secretKey
        }
      ]
    }
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName_var
  location: location
  kind: 'linux'
  sku: {
    tier: sku
    name: skuCode
  }
  properties: {
    targetWorkerSizeId: workerSize
    targetWorkerCount: 1
    reserved: true
  }
}

resource appInsights 'microsoft.insights/components@2020-02-02-preview' = {
  name: appInsights_var
  location: location
  kind: 'web'
  properties: {
    // ApplicationId: webAppName_resource.id
    Application_Type: 'web'
  }
}
