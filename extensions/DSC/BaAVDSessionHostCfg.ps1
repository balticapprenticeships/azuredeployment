##########################################################################
# Script to configure Azure Virtual Desktop environment using DSC        #
# Author: Chris Langford                                                 #
# Version: 1.0.0                                                         #
##########################################################################

Configuration InstallSqlServer {
    [CmdletBinding()]

    Import-DscResource -ModuleName ComputerManagementDsc, PSDesiredStateConfiguration, SqlServerDsc

    Node localhost {
        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
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
        
    }
}

#Create MOF
InstallSqlServer -Output .\ 

#Start DSC
Start-DscConfiguration -Path .\ -ComputerName $env:COMPUTERNAME -Wait -Force