param location string
param vmName string
param vmSize string
param vmCount int
param osDiskType string
param osDiskDeleteOption string
param course string
param imageVersion string
param licenseType string
param enableHotPatching string
param patchMode string
param securityType string
param secureBoot string
param vTPM string
param idleVM string
param nicDeleteOption string
param adminUsername string
param adminPassword string
param localUsername string
param localUserPassword string
param createdBy string
param deliveringTrainerInitials string
param courseStartDate string
param startupSchedule string
param resourceGroupCleanup string
param artifactsLocation string
param extensionRepo string

var vmNamePrefix = toUpper(concat(vmName, deliveringTrainerInitials))
var galleryImageName = 'SharedImageGallery'
var WindowsLicense = 'Windows_Server'
var operatingSystemValues = {
  WindowsServer: {
    galleryImageDefinitionName: 'BA-WinServer2016'
  }
}
var labConfigDscFunction = 'xBa${course}LabCfg'
var trustedLaunch = {
  securityType: securityType
  uefiSettings: {
    secureBootEnabled: secureBoot
    vTpmEnabled: vTPM
  }
}
var dscArchiveFolder = 'DSC'
var dscArchiveFileName = 'xBaLabWinSvrCgf.zip'

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
        id: resourceId('Microsoft.Compute/galleries/images/versions', galleryImageName, operatingSystemValues[course].galleryImageDefinitionName, imageVersion)
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
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        timeZone: 'GMT Standard Time'
        patchSettings: {
          enableHotpatching: enableHotPatching
          patchMode: patchMode
        }
      }
    }
    securityProfile: ((securityType == 'TrustedLaunch') ? trustedLaunch : json('null'))
    licenseType: ((licenseType == 'AzureHybrid') ? WindowsLicense : json('null'))
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
  dependsOn: []
}]

resource vmNamePrefix_virtualMachineLoop_1_Microsoft_PowerShell_DSC 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = [for i in range(0, vmCount): {
  name: '${vmNamePrefix}${(i + 1)}/Microsoft.PowerShell.DSC'
  location: location
  tags: {
    DisplayName: 'DSC'
    Dept: resourceGroup().tags.Dept
    CreatedBy: createdBy
    CourseDate: courseStartDate
    Cleanup: resourceGroupCleanup
  }
  properties: {
    publisher: 'Microsoft.PowerShell'
    type: 'DSC'
    typeHandlerVersion: '2.80'
    autoUpgradeMinorVersion: true
    settings: {
      wmfVersion: 'latest'
      configuration: {
        url: '${artifactsLocation}/${extensionRepo}/${dscArchiveFolder}/${dscArchiveFileName}'
        script: 'xBaLabWinSvrCfg.ps1'
        function: labConfigDscFunction
      }
    }
    protectedSettings: {
      configurationArguments: {
        Credential: {
          Username: localUsername
          Password: localUserPassword
        }
      }
    }
  }
  dependsOn: [
    resourceId('Microsoft.Compute/virtualMachines', concat(vmNamePrefix, (i + 1)))
  ]
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