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

@description('The resource ID of the ARM connection')
param armConnectionId string

// Logic App resource definition
resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  tags: tags
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
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'arm\'][\'connectionId\']'
              }
            }
            method: 'get'
            path: '/subscriptions/@{encodeURIComponent(\'${subscriptionId}\')}/resourcegroups/@{encodeURIComponent(\'${resourceGroupName}\')}/providers/@{encodeURIComponent(\'Microsoft.Fabric\')}/@{encodeURIComponent(\'capacities/${fabricCapacityName}\')}'
            queries: {
              'x-ms-api-version': '2023-11-01'
            }
          }
        }
        Condition_Pause_Fabric_Capacity_if_not_Paused: {
          actions: {
            Invoke_resource_operation: {
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
    parameters: {
      '$connections': {
        value: {
          arm: {
            id: '/subscriptions/${subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/arm'
            connectionId: armConnectionId
            connectionName: 'arm'
          }
        }
      }
    }
  }
}

output logicAppName string = logicApp.name
output logicAppId string = logicApp.id
