// Parameters
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

@description('The external ID for the ARM connection')
param connections_arm_externalid string = '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Web/connections/arm'

// Logic App resource definition
resource logicApp_res 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  properties: {
    state: 'Enabled' // The state of the Logic App
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#' // Schema for the Logic App definition
      contentVersion: '1.0.0.0' // Version of the Logic App definition
      parameters: {
        '$connections': {
          defaultValue: {} // Default value for connections parameter
          type: 'Object' // Type of the connections parameter
        }
      }
      triggers: {
        Recurrence: {
          recurrence: {
            interval: 1 // Interval for the recurrence trigger
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
            connectionId: connections_arm_externalid
            connectionName: 'arm'
          }
        }
      }
    }
  }
}

output logicAppName string = logicAppName
