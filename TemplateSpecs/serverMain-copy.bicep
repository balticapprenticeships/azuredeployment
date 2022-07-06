@description('Location to store all VM resources.')
@allowed([
  'ukwest'
  'uksouth'
])
param location string = 'ukwest'

@description('Virtual Machine name e.g., 306Client')
param vmName string

@description('Virtual Machine size e.g., 2vCPU\'s 4GB RAM')
@allowed([
  'Standard_B1ms'
  'Standard_B2s'
  'Standard_D2s_v3'
])
param vmSize string

@description('The number of Virtual Machines required between 1 and 20')
@minValue(1)
@maxValue(20)
param vmCount int

@description('Select the type of storage Standard HDD, SSD or Premium SSD')
@allowed([
  'Standard_LRS'
])
param osDiskType string = 'Standard_LRS'

@description('')
@allowed([
  'Delete'
  'detatch'
])
param osDiskDeleteOption string = 'Delete'

@description('Select the Operating System type to deploy.')
@allowed([
  'Windows'
  'Linux'
])
param osPlatform string

@description('Choose the course to deliver')
@allowed([
  'NoVlaue'
  'MobilityAndDevices'
  'ServerFundamentals'
  'ItEssentials'
  'NetworkAndArchitecture'
  'SecurityPlus'
])
param course string = 'NoValue'

@description('Choose your Linux operating system')
@allowed([
  'UbuntuServer'
  'UbuntuServer2004'
  'Debian'
  'RedHat'
])
param linuxOS string = 'UbuntuServer'

@description('Lab image version')
@allowed([
  'latest'
])
param imageVersion string = 'latest'

@description('description')
param enableHotPatching bool = false

@description('Enable to help protect the VM from malware e.g., root kits')
param secureBoot bool = true

@description('Enable to configure a virtual Trusted Platform Module 2.0')
param vTPM bool = true

@description('Create a new or using an existing Virtual Network.')
@allowed([
  'new'
  'existing'
])
param vnetNewOrExisting string = 'new'

@description('')
@allowed([
  'new'
  'existing'
])
param existingVnet string = 'new'

@description('')
param subnetName string = 'default'

@description('')
@allowed([
  'Delete'
  'detatch'
])
param nicDeleteOption string = 'Delete'

@description('')
@allowed([
  'Delete'
  'detatch'
])
param pipDeleteOption string = 'Delete'

@description('Administrator account username.')
param adminUsername string

@description('The type of authentication used for the virtual machine. SSH is recommended fo Linux VM\'s.')
@allowed([
  'Password'
  'sshPublicKey'
])
param authenticationType string = 'Password'

@description('Admin password for the Virtual machines.')
@secure()
param adminPassword string

@description('SSH key for the admin account.')
@secure()
param sshPublicKeyString string

@description('Username for the non admin user.')
param localUsername string

@description('Non admin user password.')
@secure()
param localUserPassword string

@description('Please enter your firstname and surname.')
param createdBy string

@description('Please provide the first and last inital of the delivering trainer.')
param deliveringTrainerInitials string

@description('Please provide the start date of the course on the following format 01/01/2022.')
param courseStartDate string

@description('Should the virtual machines start automatically at the beginning of each day?')
@allowed([
  'Yes'
  'No'
])
param startupSchedule string = 'No'

@description('Choose whether to have the virtual machine and associated resources deleted automatically at the end of the week.')
@allowed([
  'Enabled'
  'Disabled'
])
param resourceGroupCleanup string = 'Enabled'

var vmNamePrefix = toUpper(concat(vmName, deliveringTrainerInitials))
var patchMode = ((osPlatform == 'Windows') ? 'AutomaticByOS' : 'ImageDefault')
var securityType = 'Standard'
var licenseType = 'AzureLicense'
var idleVM = 'No'
var vaultResourceGroup = 'BalticTrainerOMS'
var vaultName = 'DeploymentVM'
var artifactsLocation = 'https://raw.githubusercontent.com/balticapprenticeships/'
var extensionRepo = 'main/extensions'

module DeployNetworkInterface 'modules/networkInterface.bicep' = {
  name: 'DeployNetworkInterface'
  params: {
    location: location
    vmName: vmName
    vmCount: vmCount
    course: course
    vnetNewOrExisting: vnetNewOrExisting
    pipDeleteOption: pipDeleteOption
    existingVnet: existingVnet
    subnetName: subnetName
    createdBy: createdBy
    deliveringTrainerInitials: deliveringTrainerInitials
    courseStartDate: courseStartDate
    resourceGroupCleanup: resourceGroupCleanup
  }
  dependsOn: [
    DeployNetworkSecurityGroup
    DeployVirtualNetwork
    DeployPublicIPAddress
  ]
}

module DeployNetworkSecurityGroup 'modules/networkSecurityGroup.bicep' = {
  name: 'DeployNetworkSecurityGroup'
  params: {
    location: location
    osPlatform: osPlatform
    createdBy: createdBy
    courseStartDate: courseStartDate
    resourceGroupCleanup: resourceGroupCleanup
  }
  dependsOn: []
}

module DeployVirtualNetwork 'modules/virtualNetwork.bicep' = if (vnetNewOrExisting == 'new') {
  name: 'DeployVirtualNetwork'
  params: {
    location: location
    subnetName: subnetName
    createdBy: createdBy
    courseStartDate: courseStartDate
    resourceGroupCleanup: resourceGroupCleanup
  }
  dependsOn: []
}

module DeployPublicIPAddress 'modules/publicIP.bicep' = {
  name: 'DeployPublicIPAddress'
  params: {
    location: location
    vmName: vmName
    vmCount: vmCount
    createdBy: createdBy
    deliveringTrainerInitials: deliveringTrainerInitials
    courseStartDate: courseStartDate
    resourceGroupCleanup: resourceGroupCleanup
  }
  dependsOn: []
}

module DeployWindowsVM 'modules/windowsServer.bicep' = if (osPlatform == 'Windows') {
  name: 'DeployWindowsVM'
  params: {
    location: location
    vmName: vmName
    vmSize: vmSize
    vmCount: vmCount
    osDiskType: osDiskType
    osDiskDeleteOption: osDiskDeleteOption
    course: course
    imageVersion: imageVersion
    licenseType: licenseType
    enableHopPatching: enableHotPatching
    patchMode: patchMode
    securityType: securityType
    secureBoot: secureBoot
    vTPM: vTPM
    idleVM: idleVM
    nicDeleteOption: nicDeleteOption
    adminUsername: adminUsername
    adminPassword: adminPassword
    localUsername: localUsername
    localUserPassword: localUserPassword
    createdBy: createdBy
    deliveringTrainerInitials: deliveringTrainerInitials
    courseStartDate: courseStartDate
    startupSchedule: startupSchedule
    resourceGroupCleanup: resourceGroupCleanup
    artifactsLocation: artifactsLocation
    extensionRepo: extensionRepo
  }
  dependsOn: [
    DeployNetworkInterface
  ]
}

module DeployLinuxVM 'modules/linuxServer.bicep' = if (osPlatform == 'Linux') {
  name: 'DeployLinuxVM'
  params: {
    location: location
    vmName: vmName
    vmSize: vmSize
    vmCount: vmCount
    osDiskType: osDiskType
    osDiskDeleteOption: osDiskDeleteOption
    linuxOS: linuxOS
    securityType: securityType
    secureBoot: secureBoot
    vTPM: vTPM
    idleVM: idleVM
    nicDeleteOption: nicDeleteOption
    adminUsername: adminUsername
    adminPassword: adminPassword
    authenticationType: authenticationType
    sshPublicKeyString: sshPublicKeyString
    createdBy: createdBy
    deliveringTrainerInitials: deliveringTrainerInitials
    courseStartDate: courseStartDate
    startupSchedule: startupSchedule
    resourceGroupCleanup: resourceGroupCleanup
  }
  dependsOn: [
    DeployNetworkInterface
  ]
}

resource shutdown_computevm_vmNamePrefix_shutdownLoop_1 'Microsoft.DevTestLab/schedules@2018-09-15' = [for i in range(0, vmCount): {
  name: 'shutdown-computevm-${vmNamePrefix}${(i + 1)}'
  location: location
  tags: {
    Displayname: 'Shutdown Schedule'
    Dept: resourceGroup().tags.Dept
    CreatedBy: createdBy
    CourseDate: 'WC-${courseStartDate}'
    Cleanup: resourceGroupCleanup
  }
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '17:00'
    }
    timeZoneId: 'GMT Standard Time'
    targetResourceId: resourceId('Microsoft.Compute/virtualMachines', concat(vmNamePrefix, (i + 1)))
    notificationSettings: {
      status: 'Disabled'
      notificationLocale: 'en'
      timeInMinutes: 30
    }
  }
  dependsOn: [
    resourceId('Microsoft.Resources/deployments', ((osPlatform == 'Windows') ? 'DeployWindowsVM' : 'DeployLinuxVM'))
  ]
}]

output contentVersion string = deployment().properties.template.contentVersion
output location string = location
output vmNamePrefix string = vmName
output createdBy string = createdBy
output trainer string = deliveringTrainerInitials
output scheduleOn string = startupSchedule
output idleVm string = idleVM
output resourceGroupCleanup string = resourceGroupCleanup
output osDiskType string = osDiskType
output vmSize string = vmSize
output osPlatform string = osPlatform
output operatingSystem string = ((osPlatform == 'Windows') ? course : linuxOS)
output imageVersion string = ((osPlatform == 'Windows') ? imageVersion : DeployLinuxVM.properties.outputs.linuxOS.value.version)
output virtualMachineFQDN array = DeployPublicIPAddress.properties.outputs.fqdn.value
output localUsername string = localUsername
output localUserPassword securestring = localUserPassword