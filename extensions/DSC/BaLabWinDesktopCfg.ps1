################################################################
# Script to configure Windows lab environment using DSC        #
# Author: Chris Langford                                       #
# Version: 6.1.0                                               #
################################################################

Configuration BaWinDesktopLabCfg {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName ComputerManagementDsc, PSDesiredStateConfiguration

    Node localhost {
        LocalConfigurationmanager {
            RebootNodeIfNeeded = $true
        }

        # This resource block creates a local User
        User "CreateUserAccount"
        {
            Ensure = "Present"
            UserName = Split-Path -Path $Credential.Username -Leaf
            Password = $Credential
            FullName = "Baltic Apprentice"
            Description = "Baltic Apprentice User Account"
            PasswordNeverExpires = $true
            PasswordChangeRequired = $false
            PasswordChangeNotAllowed = $true
        }

        # This resource block adds a user to specific groups
        Group "AddToUserGroup"
        {
            Ensure = "Present"
            GroupName = "Users"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds a user to specific groups
        Group "AddToRemoteDesktopUserGroup"
        {
            Ensure = "Present"
            GroupName = "Remote Desktop Users"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }        
        
        # This resource block ensures that the file or command is executed
        Script "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item -Path "C:\workflow-artifacts\" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "C:\workflow-artifacts" -Force -ErrorAction SilentlyContinue   
                Remove-Item -Path "C:\workflow-artifacts.zip" -Force -ErrorAction SilentlyContinue 
            }
            TestScript = { $false }
            GetScript = {
                # Do not return anything, just a placeholder
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
        LocalConfigurationmanager {
            RebootNodeIfNeeded = $true
        }

        # This resource block creates a local User
        User "CreateUserAccount"
        {
            Ensure = "Present"
            UserName = Split-Path -Path $Credential.Username -Leaf
            Password = $Credential
            FullName = "Baltic Apprentice"
            Description = "Baltic Apprentice User Account"
            PasswordNeverExpires = $true
            PasswordChangeRequired = $false
            PasswordChangeNotAllowed = $true
        }

        # This resource block adds a user to specific groups
        Group "AddToUserGroup"
        {
            Ensure = "Present"
            GroupName = "Users"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds a user to specific groups
        Group "AddToRemoteDesktopUserGroup"
        {
            Ensure = "Present"
            GroupName = "Remote Desktop Users"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }        
        
        # This resource block ensures that the file or command is executed
        Script "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item -Path "C:\workflow-artifacts\" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "C:\workflow-artifacts" -Force -ErrorAction SilentlyContinue   
                Remove-Item -Path "C:\workflow-artifacts.zip" -Force -ErrorAction SilentlyContinue 
            }
            TestScript = { $false}
            GetScript = {
                # Do not return anything, just a placeholder
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
        LocalConfigurationmanager {
            RebootNodeIfNeeded = $true
        }

        # This resource block creates a local User
        User "CreateUserAccount"
        {
            Ensure = "Present"
            UserName = Split-Path -Path $Credential.Username -Leaf
            Password = $Credential
            FullName = "Baltic Apprentice"
            Description = "Baltic Apprentice User Account"
            PasswordNeverExpires = $true
            PasswordChangeRequired = $false
            PasswordChangeNotAllowed = $true
        }

        # This resource block adds a user to specific groups
        Group "AddToUserGroup"
        {
            Ensure = "Present"
            GroupName = "Users"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds a user to specific groups
        Group "AddToRemoteDesktopUserGroup"
        {
            Ensure = "Present"
            GroupName = "Remote Desktop Users"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }        
        
        # This resource block ensures that the file or command is executed
        Script "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item -Path "C:\workflow-artifacts\" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "C:\workflow-artifacts" -Force -ErrorAction SilentlyContinue   
                Remove-Item -Path "C:\workflow-artifacts.zip" -Force -ErrorAction SilentlyContinue 
            }
            TestScript = { $false}
            GetScript = {
                # Do not return anything, just a placeholder
            }
        }
    }
}

Configuration BaDataLevel3LabCfg {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName ComputerManagementDsc, PSDesiredStateConfiguration

    Node localhost {
        LocalConfigurationmanager {
            RebootNodeIfNeeded = $true
        }

        # This resource block creates a local User
        User "CreateUserAccount"
        {
            Ensure = "Present"
            UserName = Split-Path -Path $Credential.Username -Leaf
            Password = $Credential
            FullName = "Baltic Apprentice"
            Description = "Baltic Apprentice User Account"
            PasswordNeverExpires = $true
            PasswordChangeRequired = $false
            PasswordChangeNotAllowed = $true
        }

        # This resource block adds a user to specific groups
        Group "AddToUserGroup"
        {
            Ensure = "Present"
            GroupName = "Users"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds a user to specific groups
        Group "AddToRemoteDesktopUserGroup"
        {
            Ensure = "Present"
            GroupName = "Remote Desktop Users"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }        
        
        # This resource block ensures that the file or command is executed
        Script "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item -Path "C:\workflow-artifacts\" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "C:\workflow-artifacts" -Force -ErrorAction SilentlyContinue   
                Remove-Item -Path "C:\workflow-artifacts.zip" -Force -ErrorAction SilentlyContinue 
            }
            TestScript = { $false}
            GetScript = {
                # Do not return anything, just a placeholder
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

    Import-DscResource -ModuleName ComputerManagementDsc, PSDesiredStateConfiguration

    Node localhost {
        LocalConfigurationmanager {
            RebootNodeIfNeeded = $true
        }

        # This resource block creates a local User
        User "CreateUserAccount"
        {
            Ensure = "Present"
            UserName = Split-Path -Path $Credential.Username -Leaf
            Password = $Credential
            FullName = "Baltic Apprentice"
            Description = "Baltic Apprentice User Account"
            PasswordNeverExpires = $true
            PasswordChangeRequired = $false
            PasswordChangeNotAllowed = $true
        }

        # This resource block adds a user to specific groups
        Group "AddToUserGroup"
        {
            Ensure = "Present"
            GroupName = "Users"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds a user to specific groups
        Group "AddToRemoteDesktopUserGroup"
        {
            Ensure = "Present"
            GroupName = "Remote Desktop Users"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }        
        
        # This resource block ensures that the file or command is executed
        Script "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item -Path "C:\workflow-artifacts\" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "C:\workflow-artifacts" -Force -ErrorAction SilentlyContinue   
                Remove-Item -Path "C:\workflow-artifacts.zip" -Force -ErrorAction SilentlyContinue 
            }
            TestScript = { $false}
            GetScript = {
                # Do not return anything, just a placeholder
            }
        }
    }
}

Configuration BaDataLevel4SqlLabCfg {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName ComputerManagementDsc, PSDesiredStateConfiguration, SqlServerDsc

    Node localhost {
        LocalConfigurationmanager {
            RebootNodeIfNeeded = $true
        }

        # This resource block creates a local User
        User "CreateUserAccount"
        {
            Ensure = "Present"
            UserName = Split-Path -Path $Credential.Username -Leaf
            Password = $Credential
            FullName = "Baltic Apprentice"
            Description = "Baltic Apprentice User Account"
            PasswordNeverExpires = $true
            PasswordChangeRequired = $false
            PasswordChangeNotAllowed = $true
        }

        # This resource block adds a user to specific groups
        Group "AddToUserGroup"
        {
            Ensure = "Present"
            GroupName = "Users"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds a user to specific groups
        Group "AddToAdministratorGroup"
        {
            Ensure = "Present"
            GroupName = "Administrators"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }        

        # This resource block adds a user to specific groups
        Group "AddToRemoteDesktopUserGroup"
        {
            Ensure = "Present"
            GroupName = "Remote Desktop Users"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }
        
        # This resource block will install SQL Server 2022 Devloper Edition
        SqlSetup "InstallSQLServer"
        {
            InstanceName = 'MSSQLSERVER'
            Features = 'SQLENGINE'
            SourcePath = 'C:\sqlBuildArtifacts\SQLServer2022-Dev'
            SQLCollation = 'Latin1_General_CI_AS'
            SQLSysAdminAccounts = @('Administrators')
            InstallSharedDir = 'C:\Program Files\Microsoft SQL Server'
            InstallSharedWOWDir = 'C:\Program Files (x86)\Microsoft SQL Server'
            InstanceDir = 'C:\Program Files\Microsoft SQL Server'
            NpEnabled = $false
            TcpEnabled = $false
            UpdateEnabled = $false
            UseEnglish = $true
            ForceReboot = $false

            SqlTempdbFileCount = 8
            SqlTempdbFileSize = 8
            SqlTempdbFileGrowth = 64
            SqlTempdbLogFileSize = 8
            SqlTempdbLogFileGrowth = 64

            SqlSvcStartupType = 'Automatic'
            AgtSvcStartupType = 'Manual'
            BrowserSvcStartupType = 'Manual'
            
            DependsOn = "[User]CreateUserAccount", "[Group]AddToAdministratorGroup"
        }

        # This resource block ensures that the file or command is executed after SQL Server installation
        Script "AddSSMSDesktopShortcut"
        {
            SetScript = {
                $ssmsTargetFile = "C:\Program Files (x86)\Microsoft SQL Server Management Studio 20\Common7\IDE\Ssms.exe"
                $ssmsShortcutFile = "C:\Users\Public\Desktop\Sql Server Management Studio.lnk"
                if (Test-Path -Path $ssmsTargetFile) {
                    $ssmsWShell = New-Object -ComObject WScript.Shell
                    $ssmsShortcut = $ssmsWShell.CreateShortcut($ssmsShortcutFile)
                    $ssmsShortcut.TargetPath = $ssmsTargetFile
                    $ssmsShortcut.Save()
                } else {
                    Write-Error "SQL Server Management Studio executable not found at $ssmsTargetFile"
                }
            }
            TestScript = { $false}
            GetScript = {
                # Do not return anything, just a placeholder
            }

            dependsOn = "[SqlSetup]InstallSQLServer"
        }

        # This resource block ensures that the file or command is executed
        Script "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item -Path "C:\workflow-artifacts\" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "C:\workflow-artifacts" -Force -ErrorAction SilentlyContinue   
                Remove-Item -Path "C:\workflow-artifacts.zip" -Force -ErrorAction SilentlyContinue 
            }
            TestScript = { $false}
            GetScript = {
                # Do not return anything, just a placeholder
            }
        }
    }
}

Configuration BaSWAPC5LabCfg {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName ComputerManagementDsc, PSDesiredStateConfiguration

    Node localhost {
        LocalConfigurationmanager {
            RebootNodeIfNeeded = $true
        }

        # This resource block creates a local User
        User "CreateUserAccount"
        {
            Ensure = "Present"
            UserName = Split-Path -Path $Credential.Username -Leaf
            Password = $Credential
            FullName = "Baltic Apprentice"
            Description = "Baltic Apprentice User Account"
            PasswordNeverExpires = $true
            PasswordChangeRequired = $false
            PasswordChangeNotAllowed = $true
        }

        # This resource block adds a user to specific groups
        Group "AddToUserGroup"
        {
            Ensure = "Present"
            GroupName = "Users"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds a user to specific groups
        Group "AddToRemoteDesktopUserGroup"
        {
            Ensure = "Present"
            GroupName = "Remote Desktop Users"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }        
        
        # This resource block ensures that the file or command is executed
        Script "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item -Path "C:\workflow-artifacts\" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "C:\workflow-artifacts" -Force -ErrorAction SilentlyContinue   
                Remove-Item -Path "C:\workflow-artifacts.zip" -Force -ErrorAction SilentlyContinue 
            }
            TestScript = { $false}
            GetScript = {
                # Do not return anything, just a placeholder
            }
        }
    }
}

Configuration BaSWAPC5UE5LabCfg {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Import-DscResource -ModuleName ComputerManagementDsc, PSDesiredStateConfiguration

    Node localhost {
        LocalConfigurationmanager {
            RebootNodeIfNeeded = $true
        }

        # This resource block creates a local User
        User "CreateUserAccount"
        {
            Ensure = "Present"
            UserName = Split-Path -Path $Credential.Username -Leaf
            Password = $Credential
            FullName = "Baltic Apprentice"
            Description = "Baltic Apprentice User Account"
            PasswordNeverExpires = $true
            PasswordChangeRequired = $false
            PasswordChangeNotAllowed = $true
        }

        # This resource block adds a user to specific groups
        Group "AddToUserGroup"
        {
            Ensure = "Present"
            GroupName = "Users"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }

        # This resource block adds a user to specific groups
        Group "AddToRemoteDesktopUserGroup"
        {
            Ensure = "Present"
            GroupName = "Remote Desktop Users"
            MembersToInclude = Split-Path -Path $Credential.Username -Leaf
            DependsOn = "[User]CreateUserAccount"
        }        
        
        # This resource block ensures that the file or command is executed
        Script "RemoveArtifacts"
        {
            SetScript = {
                Remove-Item -Path "C:\workflow-artifacts\" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "C:\workflow-artifacts" -Force -ErrorAction SilentlyContinue   
                Remove-Item -Path "C:\workflow-artifacts.zip" -Force -ErrorAction SilentlyContinue 
            }
            TestScript = { $false}
            GetScript = {
                # Do not return anything, just a placeholder
            }
        }
    }
}