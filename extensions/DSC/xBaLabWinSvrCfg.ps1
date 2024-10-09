################################################################
# Script to configure Windows lab environment using DSC        #
# Author: Chris Langford                                       #
# Version: 5.7.0                                               #
################################################################

Configuration xBaICTSupC1LabCfg {
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
        xScript "SetDefaultVirtualHardDiskLocation"
        {
            SetScript = { 
                Set-VMHost -VirtualHardDiskPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
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
                New-VMSwitch -SwitchName "vSwitch" -SwitchType Private
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        xScript "RunCreateVms"
        {
            SetScript = { 
                New-VM -Name "Server01" -MemoryStartupBytes 1GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\SupportITArchitecture-P1\Server01.vhdx" -SwitchName "vSwitch"
                New-VM -Name "AsimLaptop" -MemoryStartupBytes 1GB -Generation 1 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\SupportITArchitecture-P1\AsimLaptop.vhdx" -SwitchName "vSwitch"
                New-VM -Name "ApprenticeLaptop" -MemoryStartupBytes 2GB -Generation 1 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\SupportITArchitecture-P1\ApprenticeLaptop.vhdx" -SwitchName "vSwitch"
                New-VM -Name "CallumPC" -MemoryStartupBytes 1GB -Generation 1 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\SupportITArchitecture-P1\CallumPC.vhdx" -SwitchName "vSwitch"
                New-VM -Name "KiaraLaptop" -MemoryStartupBytes 1GB -Generation 1 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\SupportITArchitecture-P1\KiaraLaptop.vhdx" -SwitchName "vSwitch"
                New-VM -Name "MariaPC" -MemoryStartupBytes 1GB -Generation 1 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\SupportITArchitecture-P1\MariaPC.vhdx" -SwitchName "vSwitch"
            }
            TestScript = { $false }
            GetScript = {  
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file or command is executed
        xScript "SetRdpTimeZone"
        {
            SetScript = {
                New-ItemProperty -ErrorAction SilentlyContinue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name "fEnableTimeZoneRedirection" -Value "1" -PropertyType DWORD -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }
        
        # This resource block ensures that the file or command is executed
        xScript "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item "C:\workflow-artifacts\*" -Recurse -Force
                Remove-Item "C:\workflow-artifacts" -Force
                Remove-Item "C:\workflow-artifacts.zip" -Force
                Remove-Item "C:\*_buildlog.log" -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }
    }
    
}

Configuration xBaICTSupC2LabCfg {
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

        # This resource block ensures that the VM is built
        xScript "RunCreateVMs"
        {
            SetScript = {
                New-VM -Name "Windows 10 Client" -MemoryStartupBytes 1GB -Generation 1 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ITTshootToolTechniques\Windows 10 Client.vhdx"
                
            }
            TestScript = { $false }
            GetScript = {  
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the VM is built
        xScript "AddDataVHD"
        {
            SetScript = {
                Add-VMHardDiskDrive -VMName "Windows 10 Client" -ControllerType IDE -ControllerNumber 0 -Path "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ITTshootToolTechniques\Windows 10 Client Data.vhdx"
                
            }
            TestScript = { $false }
            GetScript = {  
                # Do Nothing
            }
            DependsOn = "[xScript]RunCreateVMs"
        }

        # This resource block ensures that the file or command is executed
        xScript "SetRdpTimeZone"
        {
            SetScript = {
                New-ItemProperty -ErrorAction SilentlyContinue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name "fEnableTimeZoneRedirection" -Value "1" -PropertyType DWORD -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }
        
        # This resource block ensures that the file or command is executed
        xScript "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item "C:\workflow-artifacts\*" -Recurse -Force
                Remove-Item "C:\workflow-artifacts" -Force
                Remove-Item "C:\workflow-artifacts.zip" -Force
                Remove-Item "C:\*_buildlog.log" -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }
    }
    
}

Configuration xBaICTSupC3LabCfg {
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
        xScript "SetDefaultVirtualHardDiskLocation"
        {
            SetScript = { 
                Set-VMHost -VirtualHardDiskPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
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
                New-VMSwitch -SwitchName "vSwitch" -SwitchType Private
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file is executed
        xScript "RunvSwitchForNat"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "Int-vSwitch" -SwitchType Internal
                New-NetIPAddress -InterfaceAlias "vEthernet (Int-vSwitch)" -IPAddress 172.16.20.254 -PrefixLength 24
                New-NetNat -Name "Nat-VM" -InternalIPInterfaceAddressPrefix 172.16.20.0/24
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file or command is executed
        xScript "SetRdpTimeZone"
        {
            SetScript = {
                New-ItemProperty -ErrorAction SilentlyContinue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name "fEnableTimeZoneRedirection" -Value "1" -PropertyType DWORD -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }

        # This resource block ensures that the file or command is executed
        xScript "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item "C:\workflow-artifacts\*" -Recurse -Force
                Remove-Item "C:\workflow-artifacts" -Force
                Remove-Item "C:\workflow-artifacts.zip" -Force
                Remove-Item "C:\*_buildlog.log" -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }
    }
    
}

Configuration xBaICTSupC4LabCfg {
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
        xScript "SetDefaultVirtualHardDiskLocation"
        {
            SetScript = { 
                Set-VMHost -VirtualHardDiskPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
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
                New-VMSwitch -SwitchName "vSwitch" -SwitchType Private
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file is executed
        xScript "RunvSwitchForNat"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "Int-vSwitch" -SwitchType Internal
                New-NetIPAddress -InterfaceAlias "vEthernet (Int-vSwitch)" -IPAddress 172.16.20.254 -PrefixLength 24
                New-NetNat -Name "Nat-VM" -InternalIPInterfaceAddressPrefix 172.16.20.0/24
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file or command is executed
        xScript "SetRdpTimeZone"
        {
            SetScript = {
                New-ItemProperty -ErrorAction SilentlyContinue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name "fEnableTimeZoneRedirection" -Value "1" -PropertyType DWORD -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }

        # This resource block ensures that the file or command is executed
        xScript "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item "C:\workflow-artifacts\*" -Recurse -Force
                Remove-Item "C:\workflow-artifacts" -Force
                Remove-Item "C:\workflow-artifacts.zip" -Force
                Remove-Item "C:\*_buildlog.log" -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }
    }
    
}

Configuration xBaICTSupC6LabCfg {
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
        xScript "SetDefaultVirtualHardDiskLocation"
        {
            SetScript = { 
                Set-VMHost -VirtualHardDiskPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
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
                New-VMSwitch -SwitchName "vSwitch" -SwitchType Private
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file is executed
        xScript "RunvSwitchForNat"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "Int-vSwitch" -SwitchType Internal
                New-NetIPAddress -InterfaceAlias "vEthernet (Int-vSwitch)" -IPAddress 172.16.20.254 -PrefixLength 24
                New-NetNat -Name "Nat-VM" -InternalIPInterfaceAddressPrefix 172.16.20.0/24
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file or command is executed
        xScript "SetRdpTimeZone"
        {
            SetScript = {
                New-ItemProperty -ErrorAction SilentlyContinue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name "fEnableTimeZoneRedirection" -Value "1" -PropertyType DWORD -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }

        # This resource block ensures that the file or command is executed
        xScript "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item "C:\workflow-artifacts\*" -Recurse -Force
                Remove-Item "C:\workflow-artifacts" -Force
                Remove-Item "C:\workflow-artifacts.zip" -Force
                Remove-Item "C:\*_buildlog.log" -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }
    }
    
}

Configuration xBaICTNetC2LabCfg {
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
        xScript "SetDefaultVirtualHardDiskLocation"
        {
            SetScript = { 
                Set-VMHost -VirtualHardDiskPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
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
                New-VMSwitch -SwitchName "Int-vSwitch" -SwitchType Internal
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        xScript "RunCreateVms"
        {
            SetScript = { 
                New-VM -Name "Problem 1 Server" -MemoryStartupBytes 2GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ICTNetCourse2\Server01-p1.vhdx" -SwitchName "Int-vSwitch"
                New-VM -Name "Problem 1 Client" -MemoryStartupBytes 1GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ICTNetCourse2\Client01-p1.vhdx" -SwitchName "Int-vSwitch"
                New-VM -Name "Problem 2 Server" -MemoryStartupBytes 2GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ICTNetCourse2\Server01-p2.vhdx" -SwitchName "Int-vSwitch"
                New-VM -Name "Problem 2 Client" -MemoryStartupBytes 1GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ICTNetCourse2\Client01-p2.vhdx" -SwitchName "Int-vSwitch"
                New-VM -Name "Problem 3 Server" -MemoryStartupBytes 2GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ICTNetCourse2\Server01-p3.vhdx" -SwitchName "Int-vSwitch"
                New-VM -Name "Problem 3 Client" -MemoryStartupBytes 1GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ICTNetCourse2\Client01-p3.vhdx" -SwitchName "Int-vSwitch"
                New-VM -Name "Problem 4 Server" -MemoryStartupBytes 2GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ICTNetCourse2\Server01-p4.vhdx" -SwitchName "Int-vSwitch"
                New-VM -Name "Problem 4 Client" -MemoryStartupBytes 1GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ICTNetCourse2\Client01-p4.vhdx" -SwitchName "Int-vSwitch"
                New-VM -Name "Problem 5 Server" -MemoryStartupBytes 2GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ICTNetCourse2\Server01-p5.vhdx" -SwitchName "Int-vSwitch"
                New-VM -Name "Problem 5 Client" -MemoryStartupBytes 1GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ICTNetCourse2\Client01-p5.vhdx" -SwitchName "Int-vSwitch"
                New-VM -Name "Problem 6 Server" -MemoryStartupBytes 2GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ICTNetCourse2\Server01-p6.vhdx" -SwitchName "Int-vSwitch"
                New-VM -Name "Problem 6 Client" -MemoryStartupBytes 1GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ICTNetCourse2\Client01-p6.vhdx" -SwitchName "Int-vSwitch"
                
            }
            TestScript = { $false }
            GetScript = {  
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file or command is executed
        xScript "SetRdpTimeZone"
        {
            SetScript = {
                New-ItemProperty -ErrorAction SilentlyContinue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name "fEnableTimeZoneRedirection" -Value "1" -PropertyType DWORD -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }

        # This resource block ensures that the file or command is executed
        xScript "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item "C:\workflow-artifacts\*" -Recurse -Force
                Remove-Item "C:\workflow-artifacts" -Force
                Remove-Item "C:\workflow-artifacts.zip" -Force
                Remove-Item "C:\*_buildlog.log" -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }
    }
    
}

Configuration xBaICTNetC3LabCfg {
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
        xScript "SetDefaultVirtualHardDiskLocation"
        {
            SetScript = { 
                Set-VMHost -VirtualHardDiskPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
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
                New-VMSwitch -SwitchName "vSwitch" -SwitchType Private
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        xScript "RunCreateVms"
        {
            SetScript = { 
                New-VM -Name "Server01" -MemoryStartupBytes 2GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ICTSupCourse4\WWEUD-Server01.vhdx" -SwitchName "vSwitch"
                New-VM -Name "WindowsClient" -MemoryStartupBytes 1GB -Generation 1 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\WWEndUserDevices\WWEUD-Win10.vhdx" -SwitchName "vSwitch"
                
            }
            TestScript = { $false }
            GetScript = {  
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file or command is executed
        xScript "SetRdpTimeZone"
        {
            SetScript = {
                New-ItemProperty -ErrorAction SilentlyContinue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name "fEnableTimeZoneRedirection" -Value "1" -PropertyType DWORD -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }

        # This resource block ensures that the file or command is executed
        xScript "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item "C:\workflow-artifacts\*" -Recurse -Force
                Remove-Item "C:\workflow-artifacts" -Force
                Remove-Item "C:\workflow-artifacts.zip" -Force
                Remove-Item "C:\*_buildlog.log" -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }
    }
    
}

Configuration xBaICTNetC5LabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration

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

        # This resource block ensures that the file or command is executed
        xScript "SetRdpTimeZone"
        {
            SetScript = {
                New-ItemProperty -ErrorAction SilentlyContinue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name "fEnableTimeZoneRedirection" -Value "1" -PropertyType DWORD -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }

        # This resource block ensures that the file or command is executed
        xScript "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item "C:\workflow-artifacts\*" -Recurse -Force
                Remove-Item "C:\workflow-artifacts" -Force
                Remove-Item "C:\workflow-artifacts.zip" -Force
                Remove-Item "C:\*_buildlog.log" -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }
    }
    
}

Configuration xBaICTNetC6LabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration

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

        # This resource block ensures that the file or command is executed
        xScript "SetRdpTimeZone"
        {
            SetScript = {
                New-ItemProperty -ErrorAction SilentlyContinue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name "fEnableTimeZoneRedirection" -Value "1" -PropertyType DWORD -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }

        # This resource block ensures that the file or command is executed
        xScript "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item "C:\workflow-artifacts\*" -Recurse -Force
                Remove-Item "C:\workflow-artifacts" -Force
                Remove-Item "C:\workflow-artifacts.zip" -Force
                Remove-Item "C:\*_buildlog.log" -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }
    }
    
}

Configuration xBaICTNetEPALabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration

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

        # This resource block ensures that the file or command is executed
        xScript "SetRdpTimeZone"
        {
            SetScript = {
                New-ItemProperty -ErrorAction SilentlyContinue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name "fEnableTimeZoneRedirection" -Value "1" -PropertyType DWORD -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }

        # This resource block ensures that the file or command is executed
        xScript "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item "C:\workflow-artifacts\*" -Recurse -Force
                Remove-Item "C:\workflow-artifacts" -Force
                Remove-Item "C:\workflow-artifacts.zip" -Force
                Remove-Item "C:\*_buildlog.log" -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }
    }
    
}

Configuration xBaICTSupMstrLabCfg {
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
        xScript "SetDefaultVirtualHardDiskLocation"
        {
            SetScript = { 
                Set-VMHost -VirtualHardDiskPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
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
                New-VMSwitch -SwitchName "Int-vSwitch" -SwitchType Private
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file is executed
        xScript "RunvSwitchForNat"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "Int-vSwitch" -SwitchType Internal
                New-NetIPAddress -InterfaceAlias "vEthernet (Int-vSwitch)" -IPAddress 172.16.20.254 -PrefixLength 24
                New-NetNat -Name "Nat-VM" -InternalIPInterfaceAddressPrefix 172.16.20.0/24
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file or command is executed
        xScript "SetRdpTimeZone"
        {
            SetScript = {
                New-ItemProperty -ErrorAction SilentlyContinue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name "fEnableTimeZoneRedirection" -Value "1" -PropertyType DWORD -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }

        # This resource block ensures that the file or command is executed
        xScript "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item "C:\workflow-artifacts\*" -Recurse -Force
                Remove-Item "C:\workflow-artifacts" -Force
                Remove-Item "C:\workflow-artifacts.zip" -Force
                Remove-Item "C:\*_buildlog.log" -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }
    }
    
}

Configuration xBaL4NetEngC4OLDLabCfg {
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
                New-VMSwitch -SwitchName "vSwitch" -SwitchType Private
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        xScript "RunCreateVms"
        {
            SetScript = {
                New-VM -Name "Task 2 Client" -MemoryStartupBytes 2GB -Generation 1 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\NetEngCourse4\Task2Client.vhdx" -SwitchName "vSwitch"
                New-VM -Name "Task 2 Server" -MemoryStartupBytes 2GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\NetEngCourse4\Task2Server.vhdx" -SwitchName "vSwitch"
                
            }
            TestScript = { $false }
            GetScript = {  
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file or command is executed
        xScript "SetRdpTimeZone"
        {
            SetScript = {
                New-ItemProperty -ErrorAction SilentlyContinue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name "fEnableTimeZoneRedirection" -Value "1" -PropertyType DWORD -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }

        # This resource block ensures that the file or command is executed
        xScript "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item "C:\workflow-artifacts\*" -Recurse -Force
                Remove-Item "C:\workflow-artifacts" -Force
                Remove-Item "C:\workflow-artifacts.zip" -Force
                Remove-Item "C:\*_buildlog.log" -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }
    }
    
}

Configuration xBaL4NetEngC4LabCfg {
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
        xScript "SetDefaultVirtualHardDiskLocation"
        {
            SetScript = { 
                Set-VMHost -VirtualHardDiskPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file is executed
        xScript "RunvSwitchForNat"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "WAN" -SwitchType Internal
                New-NetIPAddress -InterfaceAlias "vEthernet (WAN)" -IPAddress 172.16.20.254 -PrefixLength 24
                New-NetNat -Name "Nat-VM" -InternalIPInterfaceAddressPrefix 172.16.20.0/24
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
                New-VMSwitch -SwitchName "LAN" -SwitchType Private
                New-VMSwitch -SwitchName "LAN2" -SwitchType Private

            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        xScript "RunCreateVms"
        {
            SetScript = { 
                New-VM -Name "pfSense" -MemoryStartupBytes 1GB -Generation 1 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\L4NetEngC4\pfsense.vhdx" -SwitchName "WAN"
                Add-VMNetworkAdapter -VMName "pfSense" -SwitchName "LAN"
                Add-VMNetworkAdapter -VMName "pfSense" -SwitchName "LAN2"
                New-VM -Name "ManagementServer" -MemoryStartupBytes 2GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\L4NetEngC4\WinSvr22.vhdx" -SwitchName "LAN"
                Add-VMHardDiskDrive -VMName "ManagementServer" -Path "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\L4NetEngC4\Data01.vhdx"
                New-VM -Name "Client1" -MemoryStartupBytes 1GB -Generation 1 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\L4NetEngC4\Win10-Client01.vhdx" -SwitchName "LAN"
                
            }
            TestScript = { $false }
            GetScript = {  
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file or command is executed
        xScript "SetRdpTimeZone"
        {
            SetScript = {
                New-ItemProperty -ErrorAction SilentlyContinue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name "fEnableTimeZoneRedirection" -Value "1" -PropertyType DWORD -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }

        # This resource block ensures that the file or command is executed
        xScript "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item "C:\workflow-artifacts\*" -Recurse -Force
                Remove-Item "C:\workflow-artifacts" -Force
                Remove-Item "C:\workflow-artifacts.zip" -Force
                Remove-Item "C:\*_buildlog.log" -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }
    }
    
}

Configuration xBaL4NetEngC5LabCfg {
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

        # This resource block ensures that the file or command is executed
        xScript "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item "C:\workflow-artifacts\*" -Recurse -Force
                Remove-Item "C:\workflow-artifacts" -Force
                Remove-Item "C:\workflow-artifacts.zip" -Force
                Remove-Item "C:\*_buildlog.log" -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }
    }
    
}

Configuration xBaL4NetEngC7LabCfg {
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

        # This resource block ensures that the file or command is executed
        xScript "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item "C:\workflow-artifacts\*" -Recurse -Force
                Remove-Item "C:\workflow-artifacts" -Force
                Remove-Item "C:\workflow-artifacts.zip" -Force
                Remove-Item "C:\*_buildlog.log" -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }
    }
    
}

Configuration xBaItBootcampLabCfg {
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
        xScript "SetDefaultVirtualHardDiskLocation"
        {
            SetScript = { 
                Set-VMHost -VirtualHardDiskPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
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
                New-VMSwitch -SwitchName "vSwitch" -SwitchType Private
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        xScript "RunCreateVms"
        {
            SetScript = { 
                New-VM -Name "DC" -MemoryStartupBytes 2GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ITBootcamp\ITB-DC.vhdx" -SwitchName "vSwitch"                
            }
            TestScript = { $false }
            GetScript = {  
                # Do Nothing
            }
            DependsOn = "[xWindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file or command is executed
        xScript "SetRdpTimeZone"
        {
            SetScript = {
                New-ItemProperty -ErrorAction SilentlyContinue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name "fEnableTimeZoneRedirection" -Value "1" -PropertyType DWORD -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }

        # This resource block ensures that the file or command is executed
        xScript "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item "C:\workflow-artifacts\*" -Recurse -Force
                Remove-Item "C:\workflow-artifacts" -Force
                Remove-Item "C:\workflow-artifacts.zip" -Force
                Remove-Item "C:\*_buildlog.log" -Force
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
        }
    }
    
}