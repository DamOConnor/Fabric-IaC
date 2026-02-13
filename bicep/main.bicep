// Fabric Capacity Deployment with Auto-Pause Logic App
// Deploys a resource group, Fabric capacity, ARM connection, and Logic App for scheduled pause

targetScope = 'subscription'

@description('The admin email - used for Fabric capacity administration and ARM connection')
param adminEmail string

@description('The project name - used to derive resource names')
@minLength(2)
@maxLength(10)
param projectName string

@description('The Azure region for deployment')
@allowed([
  'uksouth'
  'ukwest'
  'northeurope'
  'westeurope'
  'eastus'
  'eastus2'
  'westus'
  'westus2'
])
param region string

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
param sku string = 'F2'

@description('The hour (0-23) when the Logic App should pause the Fabric capacity')
@minValue(0)
@maxValue(23)
param pauseHour int = 21

@description('The timezone for the pause schedule')
param timezone string = 'GMT Standard Time'

@description('Optional suffix for uniqueness. Leave empty for deterministic names, or set to a short random string for lab/multi-attendee use.')
@maxLength(5)
param uniqueSuffix string = ''

@description('Tags to apply to all resources')
param tags object = {}

// Region abbreviation mapping
var regionAbbreviations = {
  uksouth: 'uks'
  ukwest: 'ukw'
  northeurope: 'neu'
  westeurope: 'weu'
  eastus: 'eus'
  eastus2: 'eus2'
  westus: 'wus'
  westus2: 'wus2'
}

// Derived resource names
var regionAbbr = regionAbbreviations[region]
var suffix = empty(uniqueSuffix) ? '' : '-${uniqueSuffix}'
var safeSuffix = toLower(uniqueSuffix)
var resourceGroupName = 'rg-${projectName}-${regionAbbr}${suffix}'
var fabricCapacityName = 'fab${projectName}${regionAbbr}${safeSuffix}'
var logicAppName = 'la-pause-${projectName}-${regionAbbr}${suffix}'

// Common tags
var commonTags = union(tags, {
  project: projectName
  region: region
})

// Resource group
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: region
  tags: commonTags
}

// Fabric capacity
module fabricCapacity './fabric_capacity.bicep' = {
  name: 'fabricCapacity'
  scope: resourceGroup(rg.name)
  params: {
    adminEmail: adminEmail
    fabricCapacityName: fabricCapacityName
    location: region
    sku: sku
    tags: commonTags
  }
}

// ARM API Connection
module armConnection './arm_connection.bicep' = {
  name: 'armConnection'
  scope: resourceGroup(rg.name)
  params: {
    displayName: adminEmail
    location: region
    subscriptionId: subscription().subscriptionId
    tenantId: subscription().tenantId
    tags: commonTags
  }
}

// Logic App for auto-pause
module logicApp './logic_app.bicep' = {
  name: 'logicApp'
  scope: resourceGroup(rg.name)
  params: {
    fabricCapacityName: fabricCapacityName
    location: region
    logicAppName: logicAppName
    resourceGroupName: resourceGroupName
    subscriptionId: subscription().subscriptionId
    pauseHour: pauseHour
    timezone: timezone
    tags: commonTags
    armConnectionId: armConnection.outputs.connectionId
  }
  dependsOn: [
    fabricCapacity
  ]
}

// Outputs
output resourceGroupName string = rg.name
output fabricCapacityName string = fabricCapacity.outputs.fabricCapacityName
output fabricCapacityId string = fabricCapacity.outputs.fabricCapacityId
output logicAppName string = logicApp.outputs.logicAppName
output logicAppId string = logicApp.outputs.logicAppId
