##########################################################################
# Script to configure Azure Virtual Desktop environment using DSC        #
# Install SQL Server                                                     #
# Author: Chris Langford                                                 #
# Version: 1.0.0                                                         #
##########################################################################

# Download VDOT
$URL = 'https://github.com/balticapprenticeships/azuredeployment/raw/main/extensions/DSC/InstallSqlServer.zip'
$ZIP = 'C:\sqlBuildArtifacts\InstallSqlServer.zip'
Invoke-WebRequest -Uri $URL -OutFile $ZIP -ErrorAction 'Stop'

# Extract DSC files from ZIP archive
Expand-Archive -Path $ZIP -DestinationPath C:\sqlBuildArtifacts\ -Force -ErrorAction 'Stop'

#Set DSC resources
#Install-Module -Name ComputerManagementDsc
Install-Module -Name SqlServerDsc -Force -Confirm:$false
Import-Module -Name SqlServerDsc -ErrorAction:Continue
Import-Module -Name PSDesiredStateConfiguration -ErrorAction:Continue

#Enable PowerShell Remoting
Enable-PSRemoting -Force -Confirm:$false
    
# Run VDOT
& C:\sqlBuildArtifacts\InstallSqlServer.ps1 -Force