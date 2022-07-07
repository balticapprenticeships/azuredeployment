################################################################
# Script to configure Windows lab environment using DSC        #
# Author: Chris Langford                                       #
# Version: 2.1.0                                               #
################################################################

Configuration xBaMobilityandDevicesLabCfg {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    $features = @("Hyper-V", "RSAT-Hyper-V-Tools", "Hyper-V-Tools", "Hyper-V-PowerShell")

    Node localhost {
        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        # This resource block creates a local user
        xUser "CreateUserAccount" {
            Ensure = "Present"
            Username = Split-Path -Path $Credential.Username -Leaf
            Password = $Credential
            FullName = "Baltic Apprentice"
            Description = "Baltic Apprentice"
            PasswordNeverExpires = $true
            PasswordChangeRequired = $false
            PasswordChangeNotAllowed = $true
        }

        # This resource block adds a user to a spacific group
        xGroup "AddToRemoteDesktopUserGroup"
        {
            GroupName = "Remote Desktop Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[xUser]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        xGroup "AddToHyperVAdministratorGroup"
        {
            GroupName = "Hyper-V Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[xUser]CreateUserAccount"
        }

        # This resource block ensures that a Windows Feature (Roles) is present
        xWindowsFeatureSet "AddHyperVFeatures"
        {
            Name = $features
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }

        # This resource block ensures that the file or command is executed
        xScript "RunNATForNestedVms"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "Int-vSwitch" -SwitchType Internal                
                New-NetIPAddress -InterfaceAlias "vEthernet (Int-vSwitch)" -IPAddress 172.16.20.254 -PrefixLength 24
                New-NetNat -Name "NAT-VM" -InternalIPInterfaceAddressPrefix 172.16.20.0/24
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file is executed
        xScript "RunvSwitchForNestedVms"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "Private-vSwitch" -SwitchType Private
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        xScript "RunCreateVmMD-DC"
        {
            SetScript = { 
                New-VM -Name "MD-DC (Domain Controller)" -MemoryStartupBytes 2GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\MobilityandDevices\MTAMD-DC.vhdx" -SwitchName "Private-vSwitch"
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        xScript "RunCreateVmMD-Win10"
        {
            SetScript = { 
                New-VM -Name "MD-Windows 10 Client" -MemoryStartupBytes 1GB -Generation 1 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\MobilityandDevices\MTAMD-Win10.vhdx" -SwitchName "Private-vSwitch"
                New-VM -Name "MD-Windows 10 AAD Client" -MemoryStartupBytes 1GB -Generation 1 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\MobilityandDevices\MTAMD-Win10-AAD.vhdx" -SwitchName "Int-vSwitch"
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }
    }
}

Configuration xBaSecurityPlusLabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    $features = @("Hyper-V", "RSAT-Hyper-V-Tools", "Hyper-V-Tools", "Hyper-V-PowerShell")

    Node localhost {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        # This resource block create a local user
        xUser "CreateUserAccount" {
            Ensure = "Present"
            Username = Split-Path -Path $Credential.Username -Leaf
            Password = $Credential
            FullName = "Baltic Apprentice"
            Description = "Baltic Apprentice Lab Admin"
            PasswordNeverExpires = $true
            PasswordChangeRequired = $false
            PasswordChangeNotAllowed = $true
        }

        # This resource block adds user to a spacific group
        xGroup "AddToAdministratorsGroup"
        {
            GroupName = "Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[xUser]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        xGroup "AddToRemoteDesktopUserGroup"
        {
            GroupName = "Remote Desktop Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[xUser]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        xGroup "AddToHyperVAdministratorGroup"
        {
            GroupName = "Hyper-V Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[xUser]CreateUserAccount"
        }

        # This resource block ensures that a Windows Features (Roles) is present
        xWindowsFeatureSet "AddHyperVFeatures"
        {
            Name = $features
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }

        # This resource block ensures that the file is executed
        xScript "RunvSwitchForNestedVms"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "Int-vSwitch" -SwitchType Internal
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        xScript "RunCreateVmSecPlus-DC"
        {
            SetScript = { 
                New-VM -Name "VSERVER" -MemoryStartupBytes 2GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\SecurityPlus\VSERVER.vhdx" -SwitchName "Int-vSwitch"
            }
            TestScript = { $false }
            GetScript = {  
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        xScript "RunCreateVmSecPlus-Win10"
        {
            SetScript = { 
                New-VM -Name "Client01" -MemoryStartupBytes 2GB -Generation 1 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\SecurityPlus\Client01.vhdx" -SwitchName "Int-vSwitch"
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }
    }
}

Configuration xBaServerFundamentalsLabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    $features = @("Hyper-V", "RSAT-Hyper-V-Tools", "Hyper-V-Tools", "Hyper-V-PowerShell")

    Node localhost {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        # This resource block create a local user
        xUser "CreateUserAccount" {
            Ensure = "Present"
            Username = Split-Path -Path $Credential.Username -Leaf
            Password = $Credential
            FullName = "Baltic Apprentice"
            Description = "Baltic Apprentice"
            PasswordNeverExpires = $true
            PasswordChangeRequired = $false
            PasswordChangeNotAllowed = $true
        }

        # This resource block adds user to a spacific group
        xGroup "AddToRemoteDesktopUserGroup"
        {
            GroupName = "Remote Desktop Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[xUser]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        xGroup "AddToHyperVAdministratorGroup"
        {
            GroupName = "Hyper-V Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[xUser]CreateUserAccount"
        }

        # This resource block ensures that a Windows Features (Roles) is present
        xWindowsFeatureSet "AddHyperVFeatures"
        {
            Name = $features
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }

        # This resource block ensures that the file is executed
        xScript "RunvSwitchForNestedVms"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "Private-vSwitch" -SwitchType Private
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file is executed
        xScript "RunNATForNestedVms"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "Int-vSwitch" -SwitchType Internal
                New-NetIPAddress -InterfaceAlias "vEthernet (Int-vSwitch)" -IPAddress 172.16.20.254 -PrefixLength 24
                New-NetNat -Name "NAT-VM" -InternalIPInterfaceAddressPrefix 172.16.20.0/24
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }
    }
    
}

Configuration xBaItEssentialsLabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    $features = @("Hyper-V", "RSAT-Hyper-V-Tools", "Hyper-V-Tools", "Hyper-V-PowerShell")

    Node localhost {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        # This resource block create a local user
        xUser "CreateUserAccount" {
            Ensure = "Present"
            Username = Split-Path -Path $Credential.Username -Leaf
            Password = $Credential
            FullName = "Baltic Apprentice"
            Description = "Baltic Apprentice"
            PasswordNeverExpires = $true
            PasswordChangeRequired = $false
            PasswordChangeNotAllowed = $true
        }

        # This resource block adds user to a spacific group
        xGroup "AddToRemoteDesktopUserGroup"
        {
            GroupName = "Remote Desktop Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[xUser]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        xGroup "AddToHyperVAdministratorGroup"
        {
            GroupName = "Hyper-V Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[xUser]CreateUserAccount"
        }

        # This resource block ensures that a Windows Features (Roles) is present
        xWindowsFeatureSet "AddHyperVFeatures"
        {
            Name = $features
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }

        # This resource block ensures that the file is executed
        xScript "RunvSwitchForNestedVms"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "Private-vSwitch" -SwitchType Private
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file is executed
        xScript "RunNATForNestedVms"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "Int-vSwitch" -SwitchType Internal
                New-NetIPAddress -InterfaceAlias "vEthernet (Int-vSwitch)" -IPAddress 172.16.20.254 -PrefixLength 24
                New-NetNat -Name "NAT-VM" -InternalIPInterfaceAddressPrefix 172.16.20.0/24
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }
    }
    
}

Configuration xBaNetworkAndArchitectureLabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    $features = @("Hyper-V", "RSAT-Hyper-V-Tools", "Hyper-V-Tools", "Hyper-V-PowerShell")

    Node localhost {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        # This resource block create a local user
        xUser "CreateUserAccount" {
            Ensure = "Present"
            Username = Split-Path -Path $Credential.Username -Leaf
            Password = $Credential
            FullName = "Baltic Apprentice"
            Description = "Baltic Apprentice"
            PasswordNeverExpires = $true
            PasswordChangeRequired = $false
            PasswordChangeNotAllowed = $true
        }

        # This resource block adds user to a spacific group
        xGroup "AddToRemoteDesktopUserGroup"
        {
            GroupName = "Remote Desktop Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[xUser]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        xGroup "AddToHyperVAdministratorGroup"
        {
            GroupName = "Hyper-V Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[xUser]CreateUserAccount"
        }

        # This resource block ensures that a Windows Features (Roles) is present
        xWindowsFeatureSet "AddHyperVFeatures"
        {
            Name = $features
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }

        # This resource block ensures that the file is executed
        xScript "RunvSwitchForNestedVms"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "Private-vSwitch" -SwitchType Private
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file is executed
        xScript "RunNATForNestedVms"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "Int-vSwitch" -SwitchType Internal
                New-NetIPAddress -InterfaceAlias "vEthernet (Int-vSwitch)" -IPAddress 172.16.20.254 -PrefixLength 24
                New-NetNat -Name "NAT-VM" -InternalIPInterfaceAddressPrefix 172.16.20.0/24
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }
    }
    
}