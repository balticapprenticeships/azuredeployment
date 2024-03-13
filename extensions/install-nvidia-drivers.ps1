#region Nvidia T4 Drivers
try {
    # Check if Driver is already installed.
    $nvidia = "NVIDIA Install Application"
    $nvidiaInstalled = ((Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*) | Where-Object { $_.DisplayName -like "*$nvidia*" })
    if($nvidiaInstalled){
        Write-Output "Nvidia GRID T4 Drivers already install"
    }else{
        # Disable the remote call to ngx. Nvidia will remove this by default in 15.3
        write-output "Disabling remote call to ngx"
        If (!(Test-Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global\NGXCore")) {
            New-Item -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global\NGXCore" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global\NGXCore" -Name "EnableOTA" -Type DWord -Value 0
        # Create parent directory. might move this to buildAftifacts
        if(!(Test-Path "C:\Nvidia_T4_Driver")){
            Write-Output "Creating Nvidia driver directory"
            New-Item -Path "C:\" -Name "Nvidia_T4_Driver" -ItemType Directory -Force
        }
        # Download Nvidia driver v15.2
        Write-Output "Downloading Drivers"
        Invoke-WebRequest -Uri "https://labresourcesclientsa.blob.core.windows.net/labconfig/Nvidia_T4_Driver/15-2.zip?sp=r&st=2023-06-19T14:22:08Z&se=2023-07-30T22:22:08Z&spr=https&sv=2022-11-02&sr=b&sig=ZjorKIbOVyfrjhnE6NJtUsu5jncZCGTlqfg0N2GdsQU%3D" -OutFile C:\15-2.zip
        # Extract driver to parent directory
        Write-Output "Unzipping driver package"
        Expand-Archive -Path "C:\15-2.zip" -DestinationPath "C:\Nvidia_T4_Driver\"
        # Install driver
        Write-Output "Installing Nvidia Drivers"        
        $nvidiaArgs = @('/s')
        Start-Process -FilePath "C:\Nvidia_T4_Driver\15-2\setup.exe" -ArgumentList $nvidiaArgs -Wait
        # Check if driver is installed
        if($nvidiaInstalled){
            Write-Output "Nvidia GRID T4 Drivers installation succeded"
        }
        # Cleanup downloaded files
        Remove-Item "C:\15-2.zip" -Force
    }
}
catch [System.Exception] {
    Write-Warning $_.Exception.Message
    Write-Output "Error installing Nvidia GRID T4 Drivers: $ErrorMessage"
}
#endregion