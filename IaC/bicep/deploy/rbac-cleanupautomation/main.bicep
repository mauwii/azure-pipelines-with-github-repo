targetScope = 'managementGroup'

@description('Array of actions for the roleDefinition')
param actions array = [
  'Microsoft.Management/managementGroups/read'
  'Microsoft.Resources/subscriptions/resourceGroups/delete'
  'Microsoft.Resources/tags/delete'
  'Microsoft.Authorization/locks/read'
  'Microsoft.Authorization/locks/write'
  'Microsoft.Authorization/locks/delete'
  'Microsoft.Resources/tags/read'
  'Microsoft.Resources/tags/write'
  'Microsoft.Resources/subscriptions/resources/read'
  'Microsoft.Resources/subscriptions/resourceGroups/read'
  'Microsoft.Resources/subscriptions/read'
  'Microsoft.Resources/subscriptions/resourcegroups/resources/read'
]

@description('Array of notActions for the roleDefinition')
param notActions array = []

@description('ObjectID of the ServicePrincipal who the role should be assigned to')
param servicePrincipalID string

@description('Friendly name of the role definition')
param roleName string = 'Custom Role - cleanupautomation ${managementGroup().name}'

@description('Detailed description of the role definition')
param roleDescription string = 'Custom Role for the Cleanup Automation Script'

var roleDefName = guid(managementGroup().id, string(actions), string(notActions))
var roleAssignName = guid(managementGroup().id, roleDef.name, servicePrincipalID)

resource roleDef 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' = {
  name: roleDefName
  properties: {
    roleName: roleName
    description: roleDescription
    type: 'customRole'
    permissions: [
      {
        actions: actions
        notActions: notActions
      }
    ]
    assignableScopes: [
      managementGroup().id
    ]
  }
}

resource roleAssign 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
    name: roleAssignName
    scope: managementGroup()
    properties: {
      principalId: servicePrincipalID
      roleDefinitionId: roleDef.id
      principalType: 'ServicePrincipal'
      description: roleDef.properties.description
    }
  }
