################################################################
# Script to configure Windows lab environment using DSC        #
# Author: Chris Langford                                       #
# Version: 5.0.0                                               #
################################################################

Configuration BaICTSupC1LabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, PSDscResources

    $features = @("Hyper-V", "RSAT-Hyper-V-Tools", "Hyper-V-Tools", "Hyper-V-PowerShell")

    Node localhost {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        # This resource block create a local user
        User "CreateUserAccount" {
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
        Group "AddToRemoteDesktopUserGroup"
        {
            GroupName = "Remote Desktop Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        Group "AddToHyperVAdministratorGroup"
        {
            GroupName = "Hyper-V Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block ensures that a Windows Features (Roles) is present
        WindowsFeatureSet "AddHyperVFeatures"
        {
            Name = $features
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }

        # This resource block ensures that the file is executed
        Script "SetDefaultVirtualHardDiskLocation"
        {
            SetScript = { 
                Set-VMHost -VirtualHardDiskPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file is executed
        Script "RunvSwitchForNestedVms"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "vSwitch" -SwitchType Private
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        Script "RunCreateVms"
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
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file or command is executed
        Script "SetRdpTimeZone"
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
        Script "RemoveArtifacts"
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

Configuration BaICTSupC2LabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, PSDscResources

    $features = @("Hyper-V", "RSAT-Hyper-V-Tools", "Hyper-V-Tools", "Hyper-V-PowerShell")

    Node localhost {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        # This resource block create a local user
        User "CreateUserAccount" {
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
        Group "AddToRemoteDesktopUserGroup"
        {
            GroupName = "Remote Desktop Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        Group "AddToHyperVAdministratorGroup"
        {
            GroupName = "Hyper-V Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block ensures that a Windows Features (Roles) is present
        WindowsFeatureSet "AddHyperVFeatures"
        {
            Name = $features
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }

        # This resource block ensures that the file is executed
        Script "SetDefaultVirtualHardDiskLocation"
        {
            SetScript = { 
                Set-VMHost -VirtualHardDiskPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file is executed
        Script "RunvSwitchForNestedVms"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "vSwitch" -SwitchType Private
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        Script "RunCreateVms"
        {
            SetScript = {               
                New-VM -Name "SoniaPC" -MemoryStartupBytes 2GB -Generation 1 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\SupportITArchitecture-P2\SoniaPC.vhdx" -SwitchName "vSwitch"
                New-VM -Name "AdamLaptop" -MemoryStartupBytes 512MB -Generation 1 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\SupportITArchitecture-P2\AdamLaptop.vhdx" -SwitchName "vSwitch"
                New-VM -Name "Server01" -MemoryStartupBytes 1GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\SupportITArchitecture-P1\Server01.vhdx" -SwitchName "vSwitch"
                New-VM -Name "ApprenticeLaptop" -MemoryStartupBytes 2GB -Generation 1 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\SupportITArchitecture-P1\ApprenticeLaptop.vhdx" -SwitchName "vSwitch"
            }
            TestScript = { $false }
            GetScript = {  
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file or command is executed
        Script "SetRdpTimeZone"
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
        Script "RemoveArtifacts"
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

Configuration BaICTNetC2LabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, PSDscResources

    $features = @("Hyper-V", "RSAT-Hyper-V-Tools", "Hyper-V-Tools", "Hyper-V-PowerShell")

    Node localhost {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        # This resource block create a local user
        User "CreateUserAccount" {
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
        Group "AddToRemoteDesktopUserGroup"
        {
            GroupName = "Remote Desktop Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        Group "AddToHyperVAdministratorGroup"
        {
            GroupName = "Hyper-V Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block ensures that a Windows Features (Roles) is present
        WindowsFeatureSet "AddHyperVFeatures"
        {
            Name = $features
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }

        # This resource block ensures that the file is executed
        Script "SetDefaultVirtualHardDiskLocation"
        {
            SetScript = { 
                Set-VMHost -VirtualHardDiskPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file is executed
        Script "RunvSwitchForNestedVms"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "Int-vSwitch" -SwitchType Internal
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        Script "RunCreateVms"
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
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file or command is executed
        Script "SetRdpTimeZone"
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
        Script "RemoveArtifacts"
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

Configuration BaICTSupC3LabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, PSDscResources

    $features = @("Hyper-V", "RSAT-Hyper-V-Tools", "Hyper-V-Tools", "Hyper-V-PowerShell")

    Node localhost {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        # This resource block create a local user
        User "CreateUserAccount" {
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
        Group "AddToRemoteDesktopUserGroup"
        {
            GroupName = "Remote Desktop Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        Group "AddToHyperVAdministratorGroup"
        {
            GroupName = "Hyper-V Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block ensures that a Windows Features (Roles) is present
        WindowsFeatureSet "AddHyperVFeatures"
        {
            Name = $features
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }
        
        # This resource block ensures that the file is executed
        Script "SetDefaultVirtualHardDiskLocation"
        {
            SetScript = { 
                Set-VMHost -VirtualHardDiskPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file or command is executed
        Script "SetRdpTimeZone"
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
        Script "RemoveArtifacts"
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

Configuration BaICTSupC4LabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, PSDscResources

    $features = @("Hyper-V", "RSAT-Hyper-V-Tools", "Hyper-V-Tools", "Hyper-V-PowerShell")

    Node localhost {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        # This resource block create a local user
        User "CreateUserAccount" {
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
        Group "AddToRemoteDesktopUserGroup"
        {
            GroupName = "Remote Desktop Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        Group "AddToHyperVAdministratorGroup"
        {
            GroupName = "Hyper-V Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block ensures that a Windows Features (Roles) is present
        WindowsFeatureSet "AddHyperVFeatures"
        {
            Name = $features
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }

        # This resource block ensures that the file is executed
        Script "SetDefaultVirtualHardDiskLocation"
        {
            SetScript = { 
                Set-VMHost -VirtualHardDiskPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file is executed
        Script "RunvSwitchForNestedVms"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "vSwitch" -SwitchType Private
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        Script "RunCreateVms"
        {
            SetScript = { 
                New-VM -Name "Server01" -MemoryStartupBytes 2GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ICTSupCourse4\WWEUD-Server01.vhdx" -SwitchName "vSwitch"
                New-VM -Name "WindowsClient" -MemoryStartupBytes 1GB -Generation 1 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\WWEndUserDevices\WWEUD-Win10.vhdx" -SwitchName "vSwitch"
                
            }
            TestScript = { $false }
            GetScript = {  
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file or command is executed
        Script "SetRdpTimeZone"
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
        Script "RemoveArtifacts"
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

Configuration BaItBootcampLabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, PSDscResources

    $features = @("Hyper-V", "RSAT-Hyper-V-Tools", "Hyper-V-Tools", "Hyper-V-PowerShell")

    Node localhost {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        # This resource block create a local user
        User "CreateUserAccount" {
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
        Group "AddToRemoteDesktopUserGroup"
        {
            GroupName = "Remote Desktop Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        Group "AddToHyperVAdministratorGroup"
        {
            GroupName = "Hyper-V Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block ensures that a Windows Features (Roles) is present
        WindowsFeatureSet "AddHyperVFeatures"
        {
            Name = $features
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }

        # This resource block ensures that the file is executed
        Script "SetDefaultVirtualHardDiskLocation"
        {
            SetScript = { 
                Set-VMHost -VirtualHardDiskPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file is executed
        Script "RunvSwitchForNestedVms"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "vSwitch" -SwitchType Private
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        Script "RunCreateVms"
        {
            SetScript = { 
                New-VM -Name "DC" -MemoryStartupBytes 2GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ITBootcamp\ITBootcamp-DC.vhdx" -SwitchName "vSwitch"                
            }
            TestScript = { $false }
            GetScript = {  
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file or command is executed
        Script "SetRdpTimeZone"
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
        Script "RemoveArtifacts"
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

Configuration BaICTSupC6LabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, PSDscResources

    $features = @("Hyper-V", "RSAT-Hyper-V-Tools", "Hyper-V-Tools", "Hyper-V-PowerShell")

    Node localhost {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        # This resource block create a local user
        User "CreateUserAccount" {
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
        Group "AddToRemoteDesktopUserGroup"
        {
            GroupName = "Remote Desktop Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        Group "AddToHyperVAdministratorGroup"
        {
            GroupName = "Hyper-V Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block ensures that a Windows Features (Roles) is present
        WindowsFeatureSet "AddHyperVFeatures"
        {
            Name = $features
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }

        # This resource block ensures that the file is executed
        Script "SetDefaultVirtualHardDiskLocation"
        {
            SetScript = { 
                Set-VMHost -VirtualHardDiskPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file is executed
        Script "RunvSwitchForNestedVms"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "vSwitch" -SwitchType Private
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        Script "RunCreateVms"
        {
            SetScript = { 
                New-VM -Name "Server01" -MemoryStartupBytes 1GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ICTSupCourse6\Server01.vhdx" -SwitchName "vSwitch"
                New-VM -Name "WindowsClient1" -MemoryStartupBytes 1GB -Generation 1 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ICTSupCourse6\WindowsClient1.vhdx" -SwitchName "vSwitch"
                New-VM -Name "WindowsClient2" -MemoryStartupBytes 1GB -Generation 1 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ICTSupCourse6\WindowsClient2.vhdx" -SwitchName "vSwitch"
                New-VM -Name "WindowsClient3" -MemoryStartupBytes 1GB -Generation 1 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ICTSupCourse6\WindowsClient3.vhdx" -SwitchName "vSwitch"
                
            }
            TestScript = { $false }
            GetScript = {  
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file or command is executed
        Script "SetRdpTimeZone"
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
        Script "RemoveArtifacts"
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

Configuration BaWSvrDevLabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, PSDscResources

    $features = @("Hyper-V", "RSAT-Hyper-V-Tools", "Hyper-V-Tools", "Hyper-V-PowerShell")

    Node localhost {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        # This resource block create a local user
        User "CreateUserAccount" {
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
        Group "AddToRemoteDesktopUserGroup"
        {
            GroupName = "Remote Desktop Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        Group "AddToHyperVAdministratorGroup"
        {
            GroupName = "Hyper-V Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block ensures that a Windows Features (Roles) is present
        WindowsFeatureSet "AddHyperVFeatures"
        {
            Name = $features
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }

        # This resource block ensures that the file is executed
        Script "SetDefaultVirtualHardDiskLocation"
        {
            SetScript = { 
                Set-VMHost -VirtualHardDiskPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file or command is executed
        Script "SetRdpTimeZone"
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
        Script "RemoveArtifacts"
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

Configuration BaICTNetC3LabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, PSDscResources

    $features = @("Hyper-V", "RSAT-Hyper-V-Tools", "Hyper-V-Tools", "Hyper-V-PowerShell")

    Node localhost {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        # This resource block create a local user
        User "CreateUserAccount" {
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
        Group "AddToRemoteDesktopUserGroup"
        {
            GroupName = "Remote Desktop Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        Group "AddToHyperVAdministratorGroup"
        {
            GroupName = "Hyper-V Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block ensures that a Windows Features (Roles) is present
        WindowsFeatureSet "AddHyperVFeatures"
        {
            Name = $features
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }

        # This resource block ensures that the file is executed
        Script "SetDefaultVirtualHardDiskLocation"
        {
            SetScript = { 
                Set-VMHost -VirtualHardDiskPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file is executed
        Script "RunvSwitchForNestedVms"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "vSwitch" -SwitchType Private
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        Script "RunCreateVms"
        {
            SetScript = { 
                New-VM -Name "Server01" -MemoryStartupBytes 2GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\ICTSupCourse4\WWEUD-Server01.vhdx" -SwitchName "vSwitch"
                New-VM -Name "WindowsClient" -MemoryStartupBytes 1GB -Generation 1 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\WWEndUserDevices\WWEUD-Win10.vhdx" -SwitchName "vSwitch"
                
            }
            TestScript = { $false }
            GetScript = {  
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file or command is executed
        Script "SetRdpTimeZone"
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
        Script "RemoveArtifacts"
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

Configuration BaICTNetC5LabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, PSDscResources

    Node localhost {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        # This resource block create a local user
        User "CreateUserAccount" {
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
        Group "AddToRemoteDesktopUserGroup"
        {
            GroupName = "Remote Desktop Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        Group "AddToHyperVAdministratorGroup"
        {
            GroupName = "Hyper-V Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block ensures that the file or command is executed
        Script "SetRdpTimeZone"
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
        Script "RemoveArtifacts"
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

Configuration BaICTNetC6LabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, PSDscResources

    Node localhost {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        # This resource block create a local user
        User "CreateUserAccount" {
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
        Group "AddToRemoteDesktopUserGroup"
        {
            GroupName = "Remote Desktop Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        Group "AddToHyperVAdministratorGroup"
        {
            GroupName = "Hyper-V Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block ensures that the file or command is executed
        Script "SetRdpTimeZone"
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
        Script "RemoveArtifacts"
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

Configuration BaICTNetEPALabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, PSDscResources

    Node localhost {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        # This resource block create a local user
        User "CreateUserAccount" {
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
        Group "AddToRemoteDesktopUserGroup"
        {
            GroupName = "Remote Desktop Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        Group "AddToHyperVAdministratorGroup"
        {
            GroupName = "Hyper-V Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block ensures that the file or command is executed
        Script "SetRdpTimeZone"
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
        Script "RemoveArtifacts"
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

Configuration BaL4NetEngC4LabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, PSDscResources

    $features = @("Hyper-V", "RSAT-Hyper-V-Tools", "Hyper-V-Tools", "Hyper-V-PowerShell")

    Node localhost {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        # This resource block create a local user
        User "CreateUserAccount" {
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
        Group "AddToRemoteDesktopUserGroup"
        {
            GroupName = "Remote Desktop Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        Group "AddToHyperVAdministratorGroup"
        {
            GroupName = "Hyper-V Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block ensures that a Windows Features (Roles) is present
        WindowsFeatureSet "AddHyperVFeatures"
        {
            Name = $features
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }

        # This resource block ensures that the file is executed
        Script "RunvSwitchForNestedVms"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "vSwitch" -SwitchType Private
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        Script "RunCreateVms"
        {
            SetScript = {
                New-VM -Name "Task 2 Client" -MemoryStartupBytes 2GB -Generation 1 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\NetEngCourse4\Task2Client.vhdx" -SwitchName "vSwitch"
                New-VM -Name "Task 2 Server" -MemoryStartupBytes 2GB -Generation 2 -BootDevice VHD -VHDPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\NetEngCourse4\Task2Server.vhdx" -SwitchName "vSwitch"
                
            }
            TestScript = { $false }
            GetScript = {  
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file or command is executed
        Script "SetRdpTimeZone"
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
        Script "RemoveArtifacts"
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

Configuration BaL4NetEngC5LabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, PSDscResources

    $features = @("Hyper-V", "RSAT-Hyper-V-Tools", "Hyper-V-Tools", "Hyper-V-PowerShell")

    Node localhost {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        # This resource block create a local user
        User "CreateUserAccount" {
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
        Group "AddToRemoteDesktopUserGroup"
        {
            GroupName = "Remote Desktop Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        Group "AddToHyperVAdministratorGroup"
        {
            GroupName = "Hyper-V Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block ensures that a Windows Features (Roles) is present
        WindowsFeatureSet "AddHyperVFeatures"
        {
            Name = $features
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }

        # This resource block ensures that the file or command is executed
        Script "RemoveArtifacts"
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

Configuration BaServerFundamentalsLabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, PSDscResources

    $features = @("Hyper-V", "RSAT-Hyper-V-Tools", "Hyper-V-Tools", "Hyper-V-PowerShell")

    Node localhost {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        # This resource block create a local user
        User "CreateUserAccount" {
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
        Group "AddToRemoteDesktopUserGroup"
        {
            GroupName = "Remote Desktop Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        Group "AddToHyperVAdministratorGroup"
        {
            GroupName = "Hyper-V Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block ensures that a Windows Features (Roles) is present
        WindowsFeatureSet "AddHyperVFeatures"
        {
            Name = $features
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }

        # This resource block ensures that the file is executed
        Script "SetDefaultVirtualHardDiskLocation"
        {
            SetScript = { 
                Set-VMHost -VirtualHardDiskPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file is executed
        Script "RunvSwitchForNestedVms"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "Private-vSwitch" -SwitchType Private
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file or command is executed
        Script "SetRdpTimeZone"
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
        Script "RemoveArtifacts"
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

Configuration BaTrblshootNetLabCfg {
    [CmdletBinding()]

    Param (
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, PSDscResources

    $features = @("Hyper-V", "RSAT-Hyper-V-Tools", "Hyper-V-Tools", "Hyper-V-PowerShell")

    Node localhost {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        # This resource block create a local user
        User "CreateUserAccount" {
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
        Group "AddToRemoteDesktopUserGroup"
        {
            GroupName = "Remote Desktop Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        Group "AddToHyperVAdministratorGroup"
        {
            GroupName = "Hyper-V Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block ensures that a Windows Features (Roles) is present
        WindowsFeatureSet "AddHyperVFeatures"
        {
            Name = $features
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }

        # This resource block ensures that the file is executed
        Script "SetDefaultVirtualHardDiskLocation"
        {
            SetScript = { 
                Set-VMHost -VirtualHardDiskPath "C:\Users\Public\Documents\Hyper-V\Virtual hard disks"
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file is executed
        Script "RunvSwitchForNestedVms"
        {
            SetScript = { 
                New-VMSwitch -SwitchName "Int-vSwitch" -SwitchType Internal
            }
            TestScript = { $false }
            GetScript = { 
                # Do Nothing
            }
            DependsOn = "[WindowsFeatureSet]AddHyperVFeatures"
        }

        # This resource block ensures that the file or command is executed
        Script "SetRdpTimeZone"
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
        Script "RemoveArtifacts"
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