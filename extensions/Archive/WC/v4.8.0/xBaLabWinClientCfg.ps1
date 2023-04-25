################################################################
# Script to configure Windows lab environment using DSC        #
# Author: Chris Langford                                       #
# Version: 5.0.0                                               #
################################################################

Configuration BaWinClientLabCfg {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName ComputerManagementDsc, PSDesiredStateConfiguration

    Node localhost {
        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        #This resource block creates a local user
        User "CreateUserAccount"
        {
            Ensure = "Present"
            UserName = Split-Path -Path $Credential.Username -Leaf
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
        Group "AddToUsersGroup"
        {
            GroupName = "Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
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

Configuration BaDataBootCampLabCfg {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName ComputerManagementDsc, PSDesiredStateConfiguration

    Node localhost {
        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        #This resource block creates a local user
        User "CreateUserAccount"
        {
            Ensure = "Present"
            UserName = Split-Path -Path $Credential.Username -Leaf
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
        Group "AddToUsersGroup"
        {
            GroupName = "Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
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

Configuration BaDiplomaLabCfg {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName ComputerManagementDsc, PSDesiredStateConfiguration

    Node localhost {
        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        #This resource block creates a local user
        User "CreateUserAccount"
        {
            Ensure = "Present"
            UserName = Split-Path -Path $Credential.Username -Leaf
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
        Group "AddToUsersGroup"
        {
            GroupName = "Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        Group "AddToAdministratorsGroup"
        {
            GroupName = "Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
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

Configuration BaRawDigitalLabCfg {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName ComputerManagementDsc, PSDesiredStateConfiguration

    Node localhost {
        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        #This resource block creates a local user
        User "CreateUserAccount"
        {
            Ensure = "Present"
            UserName = Split-Path -Path $Credential.Username -Leaf
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
        Group "AddToUsersGroup"
        {
            GroupName = "Users"
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

Configuration BaExamTestingLabCfg {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName ComputerManagementDsc, PSDesiredStateConfiguration

    Node localhost {
        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        #This resource block creates a local user
        User "CreateUserAccount"
        {
            Ensure = "Present"
            UserName = Split-Path -Path $Credential.Username -Leaf
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
        Group "AddToUsersGroup"
        {
            GroupName = "Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }
    }
}

Configuration BaICTL3SupportLabCfg {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName ComputerManagementDsc, PSDesiredStateConfiguration

    Node localhost {
        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        #This resource block creates a local user
        User "CreateUserAccount"
        {
            Ensure = "Present"
            UserName = Split-Path -Path $Credential.Username -Leaf
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
        Group "AddToUsersGroup"
        {
            GroupName = "Users"
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

Configuration BaSQLDataAnalysisLabCfg {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName ComputerManagementDsc, PSDesiredStateConfiguration,  SqlServerDsc

    Node localhost {
        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        #This resource block creates a local user
        User "CreateUserAccount"
        {
            Ensure = "Present"
            UserName = Split-Path -Path $Credential.Username -Leaf
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
        Group "AddToAdministratorsUserGroup"
        {
            GroupName = "Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        Group "AddToUsersGroup"
        {
            GroupName = "Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block will install SQL Server
        SqlSetup "InstallDefaultSQL"
        {
            InstanceName = 'MSSQLSERVER'
            Features = 'SQLENGINE'
            SourcePath = 'C:\sqlBuildArtifacts\SQLServer2019-Dev'
            SQLCollation = 'Latin1_General_CI_AS'
            SQLSysAdminAccounts = @('Administrators')
            InstallSharedDir = 'C:\Program Files\Microsoft SQL Server'
            InstallSharedWOWDir = 'C:\Program Files (x86)\Microsoft SQL Server'
            InstanceDir = 'C:\Program Files\Microsoft SQL Server'
            NpEnabled = $false
            TcpEnabled = $false
            UpdateEnabled = 'False'
            UseEnglish = $true
            ForceReboot = $false

            SqlTempdbFileCount = 8
            SqlTempdbFileSize = 8
            SqlTempdbFileGrowth = 64
            SqlTempdbLogFileSize = 8
            SqlTempdbLogFileGrowth = 64

            SqlSvcStartupType     = 'Automatic'
            AgtSvcStartupType     = 'Manual'
            BrowserSvcStartupType = 'Manual'            
        }

        # This resource block ensures that the file or command is executed
        Script "AddSSMSDesktopShortcut"
        {
            SetScript = {
                $ssmsTargetFile = "C:\Program Files (x86)\Microsoft SQL Server Management Studio 19\Common7\IDE\Ssms.exe"
                $ssmsShortcutFile = "C:\Users\Public\Desktop\SQL Server Management Studio.lnk"
                $ssmsWScriptShell = New-Object -ComObject WScript.Shell
                $ssmsShortcut = $ssmsWScriptShell.CreateShortcut($ssmsShortcutFile)
                $ssmsShortcut.TargetPath = $ssmsTargetFile
                $ssmsShortcut.Save()

                $bytes = [System.IO.File]::ReadAllBytes("C:\Users\Public\Desktop\SQL Server Management Studio.lnk")
                $bytes[0x15] = $bytes[0x15] -bor 0x20 #set byte 21 (0x15) bit 6 (0x20) ON
                [System.IO.File]::WriteAllBytes("C:\Users\Public\Desktop\SQL Server Management Studio.lnk", $bytes)
                
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

Configuration BaDataLevel4LabCfg {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName ComputerManagementDsc, PSDesiredStateConfiguration, SqlServerDsc

    Node localhost {
        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        #This resource block creates a local user
        User "CreateUserAccount"
        {
            Ensure = "Present"
            UserName = Split-Path -Path $Credential.Username -Leaf
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
        Group "AddToAdministratorsUserGroup"
        {
            GroupName = "Administrators"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds user to a spacific group
        Group "AddToUsersGroup"
        {
            GroupName = "Users"
            Ensure = "Present"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block will install SQL Server
        SqlSetup "InstallDefaultSQL"
        {
            InstanceName = 'MSSQLSERVER'
            Features = 'SQLENGINE'
            SourcePath = 'C:\sqlBuildArtifacts\SQLServer2019-Dev'
            SQLCollation = 'Latin1_General_CI_AS'
            SQLSysAdminAccounts = @('Administrators')
            InstallSharedDir = 'C:\Program Files\Microsoft SQL Server'
            InstallSharedWOWDir = 'C:\Program Files (x86)\Microsoft SQL Server'
            InstanceDir = 'C:\Program Files\Microsoft SQL Server'
            NpEnabled = $false
            TcpEnabled = $false
            UpdateEnabled = 'False'
            UseEnglish = $true
            ForceReboot = $false

            SqlTempdbFileCount = 8
            SqlTempdbFileSize = 8
            SqlTempdbFileGrowth = 64
            SqlTempdbLogFileSize = 8
            SqlTempdbLogFileGrowth = 64

            SqlSvcStartupType     = 'Automatic'
            AgtSvcStartupType     = 'Manual'
            BrowserSvcStartupType = 'Manual'            
        }

        # This resource block ensures that the file or command is executed
        Script "AddSSMSDesktopShortcut"
        {
            SetScript = {
                $ssmsTargetFile = "C:\Program Files (x86)\Microsoft SQL Server Management Studio 19\Common7\IDE\Ssms.exe"
                $ssmsShortcutFile = "C:\Users\Public\Desktop\SQL Server Management Studio.lnk"
                $ssmsWScriptShell = New-Object -ComObject WScript.Shell
                $ssmsShortcut = $ssmsWScriptShell.CreateShortcut($ssmsShortcutFile)
                $ssmsShortcut.TargetPath = $ssmsTargetFile
                $ssmsShortcut.Save()

                $bytes = [System.IO.File]::ReadAllBytes("C:\Users\Public\Desktop\SQL Server Management Studio.lnk")
                $bytes[0x15] = $bytes[0x15] -bor 0x20 #set byte 21 (0x15) bit 6 (0x20) ON
                [System.IO.File]::WriteAllBytes("C:\Users\Public\Desktop\SQL Server Management Studio.lnk", $bytes)
                
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