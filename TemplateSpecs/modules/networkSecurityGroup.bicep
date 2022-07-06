param location string
param createdBy string
param osPlatform string
param courseStartDate string
param resourceGroupCleanup string

var nsgName_var = '${resourceGroup().name}-nsg'
var allowRDP = {
  securityRules: [
    {
      name: 'Allow-RDP'
      properties: {
        priority: 300
        protocol: 'Tcp'
        access: 'Allow'
        direction: 'Inbound'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '3389'
      }
    }
  ]
}
var allowSSH = {
  securityRules: [
    {
      name: 'Allow-SSH'
      properties: {
        priority: 310
        protocol: 'Tcp'
        access: 'Allow'
        direction: 'Inbound'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '22'
      }
    }
  ]
}

resource nsgName 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: nsgName_var
  location: location
  tags: {
    DisplayName: 'Network Security Group'
    Dept: resourceGroup().tags.Dept
    CreatedBy: createdBy
    CourseDate: 'WC-${courseStartDate}'
    Cleanup: resourceGroupCleanup
  }
  properties: ((osPlatform == 'Windows') ? allowRDP : allowSSH)
}

output nsgId object = nsgName.properties
output nsgRules array = nsgName.properties.securityRules