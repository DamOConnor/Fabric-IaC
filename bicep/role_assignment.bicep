@description('The principal ID of the managed identity to assign the role to')
param principalId string

@description('The resource ID of the Fabric capacity')
param fabricCapacityId string

// Contributor role definition ID
var contributorRoleDefinitionId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

// Reference the existing Fabric capacity
resource fabricCapacity 'Microsoft.Fabric/capacities@2023-11-01' existing = {
  name: last(split(fabricCapacityId, '/'))
}

// Assign Contributor role on the Fabric capacity to the Logic App managed identity
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(fabricCapacityId, principalId, contributorRoleDefinitionId)
  scope: fabricCapacity
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleDefinitionId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

output roleAssignmentId string = roleAssignment.id
