// This is the most basic Logic App - it doesn't even check to see if the Fabric Capacity is already suspended.
// !!TODO add a check to see if the Fabric Capacity is already suspended before attempting to suspend it.
param fabricCapacityName string
param location string
param logicAppName string
param resourceGroupName string
param subscriptionId string
param connections_arm_externalid string = '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Web/connections/arm'

resource logicApp_res 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        Recurrence: {
          recurrence: {
            interval: 1
            frequency: 'Day'
            timeZone: 'GMT Standard Time'
            schedule: {
              hours: [
                '21'
              ]
            }
          }
          evaluatedRecurrence: {
            interval: 1
            frequency: 'Day'
            timeZone: 'GMT Standard Time'
            schedule: {
              hours: [
                '21'
              ]
            }
          }
          type: 'Recurrence'
        }
      }
      actions: {
        Invoke_resource_operation: {
          runAfter: {}
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'arm\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/subscriptions/@{encodeURIComponent(\'${subscriptionId}\')}/resourcegroups/@{encodeURIComponent(\'${resourceGroupName}\')}/providers/@{encodeURIComponent(\'Microsoft.Fabric\')}/@{encodeURIComponent(\'capacities/${fabricCapacityName}\')}/@{encodeURIComponent(\'suspend\')}'
            queries: {
              'x-ms-api-version': '2023-11-01'
            }
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          arm: {
            id: '/subscriptions/${subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/arm'
            connectionId: connections_arm_externalid
            connectionName: 'arm'
          }
        }
      }
    }
  }
}

output logicAppName string = logicAppName
