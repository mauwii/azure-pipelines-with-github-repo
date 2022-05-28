@description('This will be the first Part of the resource name and added as a resource tag')
param project string = 'apwghr'

@description('Which Pricing tier our App Service Plan to')
param skuName string = 'F1'

@description('How many instances of our app service will be scaled out to')
param skuCapacity int = 1

@description('Pricing Tier for the LogAnalytics Workspace')
@allowed([
  'CapacityReservation'
  'Free'
  'LACluster'
  'PerGB2018'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
param skuNameLogAnalyticsWorkspace string = 'PerGB2018'

@description('The environment where you want to use this webapp')
@allowed([
  'dev'
  'stg'
  'prod'
])
param env string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The Runtime you want to use in your WebApp')
@allowed([
  '3.8'
  '3.9'
])
param pythonVersion string = '3.9'


@description('Name that will be used to build associated artifacts')
var groupid = uniqueString(resourceGroup().id)
var appServicePlanName = toLower('${project}-asp-${groupid}')
var webSiteName = toLower('${project}-wapp-${env}-${groupid}')
var appInsightName = toLower('${project}-appi-${groupid}')
var logAnalyticsName = toLower('${project}-la-${groupid}')

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
    capacity: skuCapacity
  }
  tags: {
    displayName: 'HostingPlan'
    ProjectName: project
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
  properties: {
    serverFarmId: appServicePlan.id
    reserved: true
    httpsOnly: true
    siteConfig: {
      minTlsVersion: '1.2'
      pythonVersion: pythonVersion
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
        retentionInMb: 40
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
  kind: 'string'
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
      name: skuNameLogAnalyticsWorkspace
    }
    retentionInDays: 120
    features: {
      searchVersion: 1
      legacy: 0
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}
