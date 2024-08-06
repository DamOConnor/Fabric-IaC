param adminEmail string
param fabricCapacityName string
param location string

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

resource fabricCapacity_res 'Microsoft.Fabric/capacities@2023-11-01' = {
  name: fabricCapacityName
  location: location
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

output fabricCapacityName string = fabricCapacityName
