param location string
param vmName string
param vmSize string
param vmCount int
param osDiskType string
param osDiskDeleteOption string
param linuxOS string
param securityType string
param secureBoot string
param vTPM string
param idleVM string
param nicDeleteOption string
param adminUsername string
param adminPassword string
param authenticationType string
param sshPublicKeyString string
param createdBy string
param deliveringTrainerInitials string
param courseStartDate string
param startupSchedule string
param resourceGroupCleanup string

var vmNamePrefix = toUpper(concat(vmName, deliveringTrainerInitials))
var operatingSystemValues = {
  UbuntuServer: {
    publisher: 'canonical'
    offer: 'UbuntuServer'
    sku: '18_04-lts-gen2'
    version: 'latest'
  }
  UbuntuServer2004: {
    publisher: 'canonical'
    offer: '0001-com-ubuntu-server-focal'
    sku: '20_04-lts-gen2'
    version: 'latest'
  }
  Debian: {
    publisher: 'debian'
    offer: 'debian-11'
    sku: '11-gen2'
    version: 'latest'
  }
  RedHat: {
    publisher: 'RedHat'
    offer: 'RHEL'
    sku: '83-gen2'
    version: 'latest'
  }
}
var linuxConfigurationSsh = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: sshPublicKeyString
      }
    ]
  }
  patchSettings: {
    patchMode: 'ImageDefault'
  }
}
var linuxConfigurationPassword = {
  patchSettings: {
    patchMode: 'ImageDefault'
  }
}
var trustedLaunch = {
  securityType: securityType
  uefiSettings: {
    secureBootEnabled: secureBoot
    vTpmEnabled: vTPM
  }
}

resource vmNamePrefix_virtualMachineLoop_1 'Microsoft.Compute/virtualMachines@2021-11-01' = [for i in range(0, vmCount): {
  name: concat(vmNamePrefix, (i + 1))
  location: location
  tags: {
    Displayname: 'Virtual Machine'
    Dept: resourceGroup().tags.Dept
    CreatedBy: createdBy
    CourseDate: 'WC-${courseStartDate}'
    Schedule: ((startupSchedule == 'Yes') ? 'StartDaily' : 'NoSchedule')
    IdleShutdown: idleVM
    Cleanup: resourceGroupCleanup
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        name: '${vmNamePrefix}${(i + 1)}-osdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
        deleteOption: osDiskDeleteOption
      }
      imageReference: {
        id: operatingSystemValues[linuxOS]
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${vmNamePrefix}${(i + 1)}-nic')
          properties: {
            deleteOption: nicDeleteOption
          }
        }
      ]
    }
    osProfile: {
      computerName: concat(vmNamePrefix, (i + 1))
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: ((authenticationType == 'Password') ? linuxConfigurationPassword : linuxConfigurationSsh)
    }
    securityProfile: ((securityType == 'TrustedLaunch') ? trustedLaunch : json('null'))
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
  dependsOn: []
}]

resource vmNamePrefix_virtualMachineLoop_1_AzurePolicyforWindows 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = [for i in range(0, vmCount): {
  name: '${vmNamePrefix}${(i + 1)}/AzurePolicyforWindows'
  location: location
  properties: {
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforWindows'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
    }
    protectedSettings: {
    }
  }
  dependsOn: [
    resourceId('Microsoft.Compute/virtualMachines', concat(vmNamePrefix, (i + 1)))
  ]
}]

output vmId array = [for i in range(0, vmCount): {
  value: resourceId('Microsoft.Compute/virtualMachines', concat(vmNamePrefix, (i + 1)))
}]
output linuxOS object = operatingSystemValues[linuxOS]