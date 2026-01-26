@description('The display name for the connection (typically the admin email)')
param displayName string

@description('The location for the ARM connection')
param location string

@description('The subscription ID')
param subscriptionId string

@description('The tenant ID')
param tenantId string

@description('Tags to apply to the resource')
param tags object = {}

var connectionName = 'arm'

resource armConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: connectionName
  location: location
  tags: tags
  kind: 'V1'
  properties: {
    displayName: displayName
    customParameterValues: {}
    nonSecretParameterValues: {
      'token:tenantId': tenantId
      'token:grantType': 'code'
    }
    api: {
      name: connectionName
      displayName: 'Azure Resource Manager'
      description: 'Azure Resource Manager exposes the APIs to manage all of your Azure resources.'
      iconUri: 'https://connectoricons-prod.azureedge.net/releases/v1.0.1685/1.0.1685.3700/${connectionName}/icon.png'
      brandColor: '#003056'
      id: '/subscriptions/${subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/${connectionName}'
      type: 'Microsoft.Web/locations/managedApis'
    }
  }
}

output connectionName string = armConnection.name
output connectionId string = armConnection.id
