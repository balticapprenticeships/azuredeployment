param location string
param subnetName string
param createdBy string
param courseStartDate string
param resourceGroupCleanup string

var vnetName_var = '${resourceGroup().name}-vnet'
var addressPrefixes = '10.0.0.0/16'
var subnetsAddressPrefix = '10.0.0.0/24'

resource vnetName 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnetName_var
  location: location
  tags: {
    DisplayName: 'Virtual Network'
    Dept: resourceGroup().tags.Dept
    CreatedBy: createdBy
    CourseDate: 'WC-${courseStartDate}'
    Cleanup: resourceGroupCleanup
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefixes
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetsAddressPrefix
        }
      }
    ]
  }
}

output vnetName object = vnetName.properties
output subnetName array = vnetName.properties.subnets
output vnetId object = vnetName.properties