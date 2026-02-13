@description('The name of the Fabric Capacity')
param fabricCapacityName string

@description('The location where the resources will be deployed')
param location string

@description('The name of the Logic App')
param logicAppName string

@description('The name of the resource group')
param resourceGroupName string

@description('The subscription ID where the resources will be deployed')
param subscriptionId string

@description('The hour (0-23) when the Logic App should pause the Fabric capacity')
@minValue(0)
@maxValue(23)
param pauseHour int = 21

@description('The timezone for the schedule')
param timezone string = 'GMT Standard Time'

@description('Tags to apply to the resource')
param tags object = {}

// ARM REST API base URL for the Fabric capacity
var armBaseUrl = environment().resourceManager
var fabricCapacityUri = '${armBaseUrl}subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Fabric/capacities/${fabricCapacityName}'

// Logic App resource definition
resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {}
      triggers: {
        Recurrence: {
          recurrence: {
            interval: 1
            frequency: 'Day'
            timeZone: timezone
            schedule: {
              hours: [
                pauseHour
              ]
            }
          }
          type: 'Recurrence'
        }
      }
      actions: {
        Read_status_of_Fabric_Capacity: {
          runAfter: {}
          type: 'Http'
          inputs: {
            method: 'GET'
            uri: '${fabricCapacityUri}?api-version=2023-11-01'
            authentication: {
              type: 'ManagedServiceIdentity'
              audience: armBaseUrl
            }
          }
        }
        Condition_Pause_Fabric_Capacity_if_not_Paused: {
          actions: {
            Suspend_Fabric_Capacity: {
              type: 'Http'
              inputs: {
                method: 'POST'
                uri: '${fabricCapacityUri}/suspend?api-version=2023-11-01'
                authentication: {
                  type: 'ManagedServiceIdentity'
                  audience: armBaseUrl
                }
              }
            }
          }
          runAfter: {
            Read_status_of_Fabric_Capacity: [
              'Succeeded'
            ]
          }
          else: {
            actions: {}
          }
          expression: {
            and: [
              {
                not: {
                  equals: [
                    '@body(\'Read_status_of_Fabric_Capacity\')?[\'properties\']?[\'state\']'
                    'Paused'
                  ]
                }
              }
            ]
          }
          type: 'If'
        }
      }
      outputs: {}
    }
    parameters: {}
  }
}

output logicAppName string = logicApp.name
output logicAppId string = logicApp.id
output logicAppPrincipalId string = logicApp.identity.principalId
