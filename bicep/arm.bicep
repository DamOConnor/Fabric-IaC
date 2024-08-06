param adminEmail string
param connections_arm_name string = 'arm'
param subscriptionId string
param tenantId string

resource arm_res 'Microsoft.Web/connections@2016-06-01' = {
  name: connections_arm_name
  location: 'uksouth'
  kind: 'V1'
  properties: {
    displayName: adminEmail
    statuses: [
      {
        status: 'Connected'
      }
    ]
    customParameterValues: {}
    nonSecretParameterValues: {
      'token:tenantId': tenantId
      'token:grantType': 'code'
    }
    createdTime: '2024-08-05T14:15:07.2117587Z'
    changedTime: '2024-08-05T14:15:14.4079761Z'
    api: {
      name: connections_arm_name
      displayName: 'Azure Resource Manager'
      description: 'Azure Resource Manager exposes the APIs to manage all of your Azure resources.'
      iconUri: 'https://connectoricons-prod.azureedge.net/releases/v1.0.1685/1.0.1685.3700/${connections_arm_name}/icon.png'
      brandColor: '#003056'
      id: '/subscriptions/${subscriptionId}/providers/Microsoft.Web/locations/uksouth/managedApis/${connections_arm_name}'
      type: 'Microsoft.Web/locations/managedApis'
    }
    testLinks: []
  }
}


output connections_arm_name string = arm_res.name
