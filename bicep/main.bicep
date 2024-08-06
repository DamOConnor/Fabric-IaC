// Setup

targetScope = 'subscription'

@description('The location for all resources deployed in this template')
param location string = 'uksouth'

//@description('The core name that will be used for resources')
//param prefix string = 'general'

//@description('The text that will be suffixed to the end of resource names')
//param postfix string = 'uks'

@description('The Fabric F-SKU size, eg F2, F64 etc')
param sku string = 'F2'

@description('The admin email - used in the authorisation for the Logic App')
param adminEmail string

@description('Unique guid - to help make resource names (like Fabric Capacity names) unique')
param guid string = newGuid()
var uniqueSuffix = toLower(substring(guid, 0, 5))

// Helper variables for resource names
//var baseName = '${prefix}-${postfix}${uniqueSuffix}'
//var resourceGroupName = 'rg-${baseName}'
//var safeBaseName = '${prefix}${postfix}'

// How to create eg rg-fabric-suyi5, fabsuyi5, la-pause-fabsuyi5 ?
var baseName = '${uniqueSuffix}'
var resourceGroupName = 'rg-fabric-${uniqueSuffix}'
var fabricCapacityName = 'fab${baseName}'
var logicAppName = 'la-pause-fab${baseName}'


// Resource group

resource rg_res 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
}

// Fabric capacity

module fab_mod './fabric_capacity.bicep' = {
  name: 'fab'
  scope: resourceGroup(rg_res.name)
  params: {
    adminEmail: adminEmail
    fabricCapacityName: fabricCapacityName
    location: location
    sku: sku
  }
}


// ARM API Connection

module arm_mod './arm.bicep' = {
  name: 'arm'
  scope: resourceGroup(rg_res.name)
  params: {
    adminEmail: adminEmail
    subscriptionId: subscription().subscriptionId
    tenantId: subscription().tenantId   
  }
}


// Logic App

module logicApp_mod './logic_app.bicep' = {
  name: 'logicApp'
  scope: resourceGroup(rg_res.name)
  params: {
    fabricCapacityName: fabricCapacityName
    location: location
    logicAppName: logicAppName
    resourceGroupName: resourceGroupName
    subscriptionId: subscription().subscriptionId
  }
  dependsOn: [
    fab_mod
    arm_mod
  ]
}
