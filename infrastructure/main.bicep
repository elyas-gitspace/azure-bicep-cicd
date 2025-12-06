// ==============================
// PARAMÈTRES GLOBAUX
// ==============================

@description('Nom de l\'app service plan')
param elyassAppServicePlan string

@description('SKU de l\'App Service Plan')
param sku string = 'B1'

@description('Nom de la Web App')
param elyassWebApp string

@description('Nom du compte de stockage')
param elyassStorageAccount string

@description('SKU du compte de stockage (Redondance)')
param storageAccountsku string = 'Standard_LRS'

@description('Paramètres de tags')
param tags object = {
  Description: 'WebApp hébergeant notre appli node js'
}

@description('Accessibilité publique')
param publicNetworkAccess string = 'Enabled'

// ==============================
// 📊 DIAGNOSTIC SETTINGS PARAMÈTRES
// ==============================

@description('Nom de la ressource diagnosticSettings')
param diagnosticSettingsName string = 'diagnosticSettings_ressource'

@description('Type de destination des logs')
param destination string = 'AzureStorage'

// ==============================
// ☁️ APP SERVICE PLAN (Linux)
// ==============================

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: elyassAppServicePlan
  location: 'westeurope'
  sku: {
    name: sku
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

// ==============================
// 🌐 WEB APP
// ==============================

var appSettings = [
  {
    name: 'NODE_ENV'
    value: 'production'
  }
  {
    name: 'REGION_NAME'
    value: 'westeurope'
  }
]

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: elyassWebApp
  location: 'westeurope'
  tags: tags
  kind: 'linux'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|18-lts'
      appSettings: appSettings
    }
    httpsOnly: true
    publicNetworkAccess: publicNetworkAccess
  }
}

// ==============================
// 🗄️ STORAGE ACCOUNT
// ==============================

resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: elyassStorageAccount
  location: 'westeurope'
  sku: {
    name: storageAccountsku
  }
  kind: 'StorageV2'
  properties: {}
}

// ==============================
// 📊 DIAGNOSTIC SETTINGS
// ==============================

resource webApp_logs_redirection 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: webApp
  name: diagnosticSettingsName
  properties: {
    logAnalyticsDestinationType: destination
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
      {
        category: 'AppServiceConsoleLogs'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
      {
        category: 'AppServiceAuditLogs'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
    storageAccountId: storageAccount.id
  }
}
