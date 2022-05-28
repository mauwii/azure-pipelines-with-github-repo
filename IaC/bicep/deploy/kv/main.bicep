@description('Specifies the name of the key vault.')
param keyVaultName string = 'kv'


@description('The environment you deploy to')
@allowed([
  'dev'
  'stg'
  'prod'
])
param env string

@description('Specifies the Azure location where the key vault should be created.')
param location string = resourceGroup().location

@description('Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.')
param enabledForDeployment bool = true

@description('Specifies whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.')
param enabledForDiskEncryption bool = false

@description('Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault.')
param enabledForTemplateDeployment bool = true

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
param tenantId string = subscription().tenantId

@description('Specifies the object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Get it by using Get-AzADUser or Get-AzADServicePrincipal cmdlets.')
param objectId string = 'bb36fc31-5a0b-42db-8800-1a945c93eece'

@description('Specifies the permissions to keys in the vault. Valid values are: all, encrypt, decrypt, wrapKey, unwrapKey, sign, verify, get, list, create, update, import, delete, backup, restore, recover, and purge.')
@allowed([
  'backup'
  'create'
  'decrypt'
  'delete'
  'encrypt'
  'get'
  'import'
  'list'
  'purge'
  'recover'
  'release'
  'restore'
  'sign'
  'unwrapKey'
  'update'
  'verify'
  'wrapKey'
])
param keysPermissions array = [
  'list'
]

@description('Specifies the permissions to secrets in the vault. Valid values are: all, get, list, set, delete, backup, restore, recover, and purge.')
@allowed([
  'backup'
  'delete'
  'get'
  'list'
  'purge'
  'recover'
  'restore'
  'set'
])
param secretsPermissions array = [
  'list'
]

@description('Specifies whether the key vault is a standard vault or a premium vault.')
@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'

// @description('Specifies all secrets {"secretName":"","secretValue":""} wrapped in a secure object.')
// @secure()
// param secretsObject object

resource kv 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: '${keyVaultName}${env}${uniqueString(resourceGroup().id)}'
  location: location
  tags: {
    environment: env
  }
  properties: {
    enabledForDeployment: enabledForDeployment
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    tenantId: tenantId
    accessPolicies: [
      {
        objectId: objectId
        tenantId: tenantId
        permissions: {
          keys: keysPermissions
          secrets: secretsPermissions
        }
      }
    ]
    sku: {
      name: skuName
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

// resource secrets 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = [for secret in secretsObject.secrets: {
//   name: secret.secretName
//   parent: kv
//   properties: {
//     value: secret.secretValue
//   }
// }]
