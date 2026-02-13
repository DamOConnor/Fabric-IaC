using './main.bicep'

param adminEmail = '<your-admin-email>'
param projectName = 'analytics'
param region = 'uksouth'
param sku = 'F2'
param pauseHour = 21
param timezone = 'GMT Standard Time'
param tags = {
  environment: 'production'
  costCenter: 'IT'
}
