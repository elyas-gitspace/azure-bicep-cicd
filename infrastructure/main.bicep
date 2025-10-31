// Fichier bicep que j'ai écrit à l'aide de la documentation officielle d'Azure via leurs github : 
// https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.web
                   
                   
                   
                   // PARAMETRES //


@description('Nom de l\'app service plan')
param elyassAppServicePlan string

@description('sku qui va dicter la puissance et taille de l\'app service plan')
param sku string = 'B1'


                // ==============================
                // ☁️ APP SERVICE PLAN (Linux)
                // ==============================


// PARAMETRES //

@description('Nom de l\'app service plan')
param elyassAppServicePlan string

@description('sku qui va dicter la puissance et taille de l\'app service plan')
param sku string = 'B1'

// Déploiement de l'App service plan (qui va héberger la Web App qui elle même va accueillir notre app node js). App service plan définit la puissance de la Web App, 
// et l'OS que je choisi (en loccurence Linux)

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: elyassAppServicePlan
  location: 'westeurope'
  sku: {
    name: sku // puissance et taille du App Service Plan
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

                // ==============================
                // 🌐 WEB APP 
                //
                // (la Node.js app que l'on a enregistré dans le clouddrive du cloudshell dans ~/clouddrive/azure-bicep-cicd/app/bicep-azure-cicd.js)
                // ==============================



// PARAMETRES //

@description('Nom de la Web App')
param elyassWebApp string

@description('Paramètre tag')
param tags object = {
  'Description' : 'WebApp hébergeant notre appli node js'
}

@description('Accessibilité publique')
param publicNetworkAccess string = 'Enabled'

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

// Déploiement //

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: elyassWebApp
  location: 'westeurope'
  tags: tags
  kind: 'linux'                    // on choisit l'os sur lequel va tourner l'app (doit être le même que l'os de l'App service Plan !)
  properties: {
    serverFarmId: appServicePlan.id // Cela se réfère automatiquement au service plan que l'on a définit juste au dessus
    siteConfig: {
      appSettings: appSettings
    }
    httpsOnly: true           // notre webApp n'acceptera les connexions que de https
    publicNetworkAccess: publicNetworkAccess
  }
}


                // ==============================
                // 🗄️ STORAGE ACCOUNT (Logs / Data)
                // ==============================


// PARAMETRES //

@description('Nom de compte de stockage')
param elyassStorageAccount string

@description('sku --> niveau de redondance du compte de stockage')
param storageAccountsku string = 'Standard_LRS'

// Déploiement //

resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: elyassStorageAccount
  location: 'westeurope'
  sku: {
    name: storageAccountsku // le niveau de redondance des données (local, interzone, etc... La j'ai pris le moins cher donc le local --> Locally Redundant Storage)
  }
  kind: 'StorageV2' // Le type de compte de stockage que l'on souhaite
  properties: {} 
}


// ==============================================
// 📊 Partie qui va rediriger les logs de la Web App (que l'on a défini plus haut) 
//     vers le Storage Account (également définit en amont)
// ==============================================

// Template officiel sur lequel je me suis appuyé pour rédiger la redirection des logs : https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?pivots=deployment-language-bicep

@description('Nom de la ressource diagnosticSettings')
param name string = 'diagnosticSettings_ressource'

@description('destination des logs')
param destination string = 'AzureStorage'

resource webApp_logs_redirection 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: webApp
  name: name
  properties: {
    logAnalyticsDestinationType: destination
    logs: [

      // On va définir les logs de l'App service que l'on souhaite récupérer. Pour savoir les catégories de logs possibles, je me suis rendu sur la doc officielle d'Azure sur ce sujet
      // https://learn.microsoft.com/en-us/azure/azure-monitor/reference/supported-logs/microsoft-web-sites-logs
      {
        category: 'AppServiceHTTPLogs'       // ici on prends les logs http de l'App service
        enabled: true
        retentionPolicy: {
          days: 30                           // on choisit de conserver les données 30 jours
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
    metrics: [                          // on récupère également les métriques de la webApp et de l'App service sur lequel repose la webApp
      {
        category: 'AllMetrics'          // on veut toutes les métriques
        enabled: true
        retentionPolicy: {
          days: 30                      // on conserve les données 30 jours
          enabled: true
        }
      }
    ]
    storageAccountId: storageAccount.id // Ca va rediriger les logs vers le storage account que l'on a définit plus haut, grâce à '.id'
  }
}
