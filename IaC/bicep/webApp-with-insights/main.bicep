@description('This will be the first Part of the resource name and added as a resource tag')
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

@description('The Runtime you want to use in your WebApp')
@allowed([
  'PYTHON|3.9'
])
param linuxFxVersion string = 'PYTHON|3.9'

@description('The Pricing Tier of the AppService-Plan')
param skuName string = 'F1'
param skuTier string = 'Free'

// Variables
var resourceGroup_id = uniqueString(resourceGroup().id)
var appServicePlanName = toLower('${project}-asp-${resourceGroup_id}')
var webSiteName = toLower('${project}-webapp-${env}-${resourceGroup_id}')
var appInsightName = toLower('${project}-appi-${resourceGroup_id}')
var logAnalyticsName = toLower('${project}-la-${resourceGroup_id}')

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  tags: {
    displayName: 'HostingPlan'
    ProjectName: project
  }
  sku: {
    name: skuName
    tier: skuTier
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: webSiteName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    displayName: 'Website'
    ProjectName: project
  }
  dependsOn: [
    logAnalyticsWorkspace
  ]
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    reserved: true
    siteConfig: {
      minTlsVersion: '1.2'
      linuxFxVersion: linuxFxVersion
    }
  }
}

resource appServiceLogging 'Microsoft.Web/sites/config@2020-06-01' = {
  parent: appService
  name: 'appsettings'
  properties: {
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.properties.InstrumentationKey
  }
  dependsOn: [
    appServiceSiteExtension
  ]
}

resource appServiceSiteExtension 'Microsoft.Web/sites/siteextensions@2020-06-01' = {
  parent: appService
  name: 'Microsoft.ApplicationInsights.AzureWebSites'
  dependsOn: [
    appInsights
  ]
}

resource appServiceAppSettings 'Microsoft.Web/sites/config@2020-06-01' = {
  parent: appService
  name: 'logs'
  properties: {
    applicationLogs: {
      fileSystem: {
        level: 'Warning'
      }
    }
    httpLogs: {
      fileSystem: {
        retentionInMb: 25
        enabled: true
      }
    }
    failedRequestsTracing: {
      enabled: true
    }
    detailedErrorMessages: {
      enabled: true
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightName
  location: location
  kind: 'web'
  tags: {
    displayName: 'AppInsight'
    ProjectName: project
  }
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: logAnalyticsName
  location: location
  tags: {
    displayName: 'Log Analytics'
    ProjectName: project
  }
  properties: {
    sku: {
      name: 'Standard'
    }
    retentionInDays: 30
    features: {
      searchVersion: 1
      legacy: 0
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}
