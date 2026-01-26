@description('The admin email - used for Fabric capacity administration')
param adminEmail string

@description('The name of the Fabric capacity')
param fabricCapacityName string

@description('The location for the Fabric capacity')
param location string

@description('The Fabric F-SKU size')
@allowed([
  'F2'
  'F4'
  'F8'
  'F16'
  'F32'
  'F64'
  'F128'
  'F256'
  'F512'
  'F1024'
  'F2048'
])
param sku string

@description('Tags to apply to the resource')
param tags object = {}

resource fabricCapacity 'Microsoft.Fabric/capacities@2023-11-01' = {
  name: fabricCapacityName
  location: location
  tags: tags
  sku: {
    name: sku
    tier: 'Fabric'
  }
  properties: {
    administration: {
      members: [
        adminEmail
      ]
    }
  }
}

output fabricCapacityName string = fabricCapacity.name
output fabricCapacityId string = fabricCapacity.id
