param location string
param vmName string
param vmCount int
param createdBy string
param deliveringTrainerInitials string
param courseStartDate string
param resourceGroupCleanup string

var vmNamePrefix = toUpper(concat(vmName, deliveringTrainerInitials))

resource vmNamePrefix_publicIpNameLoop_1_ip 'Microsoft.Network/publicIPAddresses@2020-11-01' = [for i in range(0, vmCount): {
  name: '${vmNamePrefix}${(i + 1)}-ip'
  location: location
  tags: {
    DisplayName: 'Public IP Address'
    Dept: resourceGroup().tags.Dept
    CreatedBy: createdBy
    CourseDate: 'WC-${courseStartDate}'
    Cleanup: resourceGroupCleanup
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: toLower('baltic-${vmNamePrefix}${(i + 1)}')
    }
  }
  sku: {
    name: 'Basic'
  }
}]

output FQDN array = [for i in range(0, vmCount): {
  value: reference(resourceId('Microsoft.Network/publicIpAddresses', '${vmNamePrefix}${(i + 1)}-ip')).dnsSettings.fqdn
}]
output publicIP string = ''