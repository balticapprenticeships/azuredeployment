param location string
param vmName string
param vmCount int
param course string
param vnetNewOrExisting string
param pipDeleteOption string
param existingVnet string
param subnetName string
param createdBy string
param deliveringTrainerInitials string
param courseStartDate string
param resourceGroupCleanup string

var nsgName = '${resourceGroup().name}-nsg'
var vmNamePrefix = toUpper(concat(vmName, deliveringTrainerInitials))
var vnetname = '${resourceGroup().name}-vnet'
var newVnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetname, subnetName)
var existingVnetId = resourceId('Microsoft.Network/virtualNetworks/', existingVnet)
var existingSubnetId = '${existingVnetId}/subnets/${subnetName}'
var acceleratedNetworking = true

resource vmNamePrefix_nicloop_1_nic 'Microsoft.Network/networkInterfaces@2021-03-01' = [for i in range(0, vmCount): {
  name: '${vmNamePrefix}${copyIndex('nicloop', 1)}-nic'
  location: location
  tags: {
    DisplayName: '${vmNamePrefix}${copyIndex('nicloop', 1)}-nic'
    Dept: resourceGroup().tags.Dept
    CreatedBy: createdBy
    CourseDate: 'WC-${courseStartDate}'
    Cleanup: resourceGroupCleanup
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: ((vnetNewOrExisting == 'new') ? newVnetId : existingSubnetId)
          }
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', '${vmNamePrefix}${(i + 1)}-ip')
            properties: {
              deleteOption: pipDeleteOption
            }
          }
        }
      }
    ]
    enableAcceleratedNetworking: ((course == 'WindowsServer') ? acceleratedNetworking : json('null'))
    networkSecurityGroup: resourceId('Microsoft.Network/networkSecurityGroup', nsgName)
  }
  dependsOn: [
    resourceId('Microsoft.Network/virtualNetworks', 'virtualNetwork')
  ]
}]

output networkInterfaceId array = [for i in range(0, vmCount): {
  value: reference(resourceId('Microsoft.Network/networkInterfaces', '${vmNamePrefix}${(i + 1)}-nic'))
}]
output privateIP array = [for i in range(0, vmCount): {
  value: reference(resourceId('Microsoft.Network/networkInterfaces', '${vmNamePrefix}${(i + 1)}-nic')).ipConfigurations[0].properties.privateIPAddress
}]