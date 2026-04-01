// Provisioned for Thomas's app — previously done manually in 45 minutes
// Bicep template : App Service + Azure SQL Database
// Environnement : Production
// Région : West Europe (proximité équipe Thomas)

@description('Nom de l\'application — utilisé comme préfixe pour toutes les ressources')
param appName string = 'thomas-sisyphe-api'

@description('Région Azure pour le déploiement')
param location string = resourceGroup().location

@description('Environnement cible')
@allowed(['dev', 'staging', 'prod'])
param environment string = 'prod'

@description('Nom administrateur SQL')
param sqlAdminLogin string = 'thomas-admin'

@description('Mot de passe administrateur SQL')
@secure()
param sqlAdminPassword string

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// App Service Plan — B1 (suffisant pour la démo)
// Thomas avait créé ça en CLI, une commande à la fois, en 45 minutes
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${appName}-plan-${environment}'
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    reserved: true  // Required for Linux App Service
  }
  tags: {
    project: 'azure-insiders-demo'
    owner: 'thomas'
    createdBy: 'bicep-not-manual'  // Contrairement à avant
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// App Service — Python 3.11, Linux
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: '${appName}-${environment}'
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.11'
      pythonVersion: '3.11'
      appCommandLine: 'gunicorn --bind=0.0.0.0:8000 --workers=2 app:app'
      alwaysOn: true
      ftpsState: 'Disabled'  // Sécurité : désactiver FTP
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'FLASK_ENV'
          value: environment
        }
        {
          name: 'DATABASE_URL'
          value: 'sqlite:///users.db'  // En prod, utiliser Azure SQL — voir sqlDatabase ci-dessous
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
      ]
    }
    httpsOnly: true  // Sécurité : forcer HTTPS
  }
  tags: {
    project: 'azure-insiders-demo'
    owner: 'thomas'
    boulder: 'boulder-4-resolved'
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Azure SQL Server
// Thomas créait ça avec des clics dans le portail — 20 minutes minimum
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: '${appName}-sql-${environment}'
  location: location
  properties: {
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
  tags: {
    project: 'azure-insiders-demo'
    owner: 'thomas'
  }
}

// Firewall rule — autoriser les services Azure
resource sqlFirewallRule 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  parent: sqlServer
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Azure SQL Database — Basic tier (5 DTU)
// Suffisant pour la démo, scalable en prod
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: '${appName}-db'
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5  // 5 DTU — Basic tier
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648  // 2 GB
    requestedBackupStorageRedundancy: 'Local'
  }
  tags: {
    project: 'azure-insiders-demo'
    owner: 'thomas'
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Outputs — informations utiles post-déploiement
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
output appServiceUrl string = 'https://${appService.properties.defaultHostName}'
output appServiceName string = appService.name
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
output sqlDatabaseName string = sqlDatabase.name

// Pour déployer :
// az group create --name rg-thomas-demo --location westeurope
// az deployment group create --resource-group rg-thomas-demo --template-file main.bicep --parameters sqlAdminPassword=<password>
