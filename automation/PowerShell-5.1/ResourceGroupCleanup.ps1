workflow ResourceGroupCleanupAutomation {
    param (
        [Parameter(mandatory = $true)]
        [ValidateNotNullOrEmpty("Yes","No")]
        [string]$cleanupResourceGroup,
        
        [int]$throttleLimit = 20,
        [string]$removeUnmanagedOsdiskVhdBlob = 'Yes',
        [string]$showWarnings = 'Yes'
    )

    $ErrorActionPreference = "Stop"
    $WarningPreference = @("SilentlyContinue", "Continue")[$showWarnings -eq "Yes"]
    $VerbosePreference = "Continue"
    $connectionName = 'AzureRunAsConnection'

    try {
        # Get the connection "AzureRunAsConnection "
        $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

        "Logging in to Azure..."
        
        Connect-AzAccount -Identity
        
        $start = Get-Date
        $checkTime = Get-Date -Format F

        #$rgName = (Get-AzResourceGroup).ResourceGroupName
        if ($cleanupResourceGroup -ieq "Yes") {
            $vmList = inlineScript {
                $vmList = @()
                $vms = Get-AzVm | Where-Object {$_.Tags.Cleanup -ieq 'Enabled'}
                #$vms = Get-AzVm | Where-Object {(($_.Tags).Name -eq 'Cleanup') -and (($_.Tags).Value -eq 'Enabled')}
                #$VMs = Get-AzVM | Where-Object {(($_.Tags).ContainsKey('Cleanup'))}

                foreach ($vm in $vms) {
                    $vmList += @{"resourceGroup" = $vm.ResourceGroupName; "Name" = $vm.Name; "id" = $vm.id; "VmId" = $vm.VmId; "BootDiag" = $vm.DiagnosticsProfile.BootDiagnostics.StorageUri; "nics" = $vm.NetworkProfile.NetworkInterfaces; "OsDisk" = $vm.StorageProfile.OsDisk.Name; "OsDiskVhd" = $vm.StorageProfile.OsDisk.Vhd.Uri}
                }
                $vmList
            }
        }
        else {
            Write-Output "No VM resources exist with the tag Cleanup enabled."
            exit
        }        
    }
    catch {
        Write-Output "Failed to obtain service principal, login to Azure and Get VMs: " $_
        exit
    }

    if ($vmList) {
        Write-Output "`nStarting parallel complete removal of $vmRg VM Resources..."
        foreach -parallel -ThrottleLimit $throttleLimit ($virtualMachine in $vmList) {
            try {
                $vmName = $virtualMachine["Name"]
                $vmRg = $virtualMachine["resourceGroup"]
                Write-Output "started removal of VM ($vmName) in resource group ($vmRg)..."
                $vmDisks = inlineScript {
                    $vmDisks = @()
                    $vmDiskList = Get-AzDisk | where-object {$_.ManagedBy -eq $Using:virtualMachine["id"]}
                    foreach ($disk in $vmDiskList) {
                        $vmDisks += @{"resourceGroup" = $disk.ResourceGroupName; "Name" = $disk.Name; "SourceUri" = $disk.CreationData.SourceUri}
                    }
                    $vmDisks
                }

                if ($virtualMachine["BootDiag"]) {
                    $diagSa = [regex]::match($virtualMachine["BootDiag"], 'https[s]?://(.+?)\.').Groups[1].Value
                    $vmDiagName = $vmName -replace '[^a-zA-Z0-9]', ''
                    if ($vmDiagName.Length -gt 9) {$i = 9} else {$i = $vmDiagName.Length}
                    $diagContainerName = ('bootdiagnostics-{0}-{1}' -f $vmDiagName.ToLower().Substring(0, $i), $virtualMachine["VmId"])
                    $diagSaRg = (Get-AzStorageAccount | Where-Object -FilterScript { $_.StorageAccountName -eq $diagSa }).ResourceGroupName
                    $saParams = @{'ResourceGroupName' = $diagSaRg; 'Name' = $diagSa}
                    Write-Output "($vmName) Step 1: Removing boot diagnostics storage container ($diagContainerName) in storage account ($diagSa)."
                    inlineScript {
                        Get-AzStorageAccount @Using:saParams | Get-AzStorageContainer | Where-Object -FilterScript { $_.Name -eq $Using:diagContainerName } | Remove-AzStorageContainer -Force
                    }
                }

                if (!$virtualMachine["BootDiag"]) {
                    Write-Output "Step 1: No boot diagnostics features configured."
                }

                # Remove VM
                Write-Output "($vmName) Step 2: Removing the VM."
                Remove-AzVM -Name $vmName -ResourceGroupName $vmRg -Force

                #Remove NICs
                Write-Output "($vmName) Step 3: Remove Nics and PublicIPs..."
                foreach -parallel -ThrottleLimit $throttleLimit ($nicUri in $virtualMachine["nics"]) {
                    $nicName = $nicUri.Id.Split('/')[-1]
                    $nicRg = $nicUri.Id.Split('/')[4]
                    $nicIpIds = inlineScript {
                        $nic = Get-AzNetworkInterface -ResourceGroupName $Using:nicRg -Name $Using:nicName
                        $nicIpIds = $nic.IpConfigurations.PublicIpAddress.Id
                        $nicIpIds
                    }
                    Write-Output "($vmName) Removing NIC ($nicName)."
                    Remove-AzNetworkInterface -Name $nicName -ResourceGroupName $nicRg -Force

                    # Remove PublicIPs
                    foreach -parallel -ThrottleLimit $throttleLimit ($ipId in $nicIpIds) {
                        $ipName = $ipId.Split('/')[-1]
                        $ipRg = $ipId.Split('/')[4]
                        Write-Output "($vmName) Removing PublicIP Address ($ipName) of NIC ($nicName)."
                        Remove-AzPublicIpAddress -ResourceGroupName $ipRg -Name $ipName -Force
                    }
                }

                #Remove Managed OS and Data disks
                Write-Output "($vmName) Step 4: Removing OS & Data disks..."
                if ($vmDisks.Count -gt 0) {
                    foreach -parallel -ThrottleLimit $throttleLimit ($vmDisk in $vmDisks) {
                        #$diskSourceUri = $vmDisk["SourceUri"]
                        $diskType = @("Data disk", "OS disk")[$vmDisk["Name"] -ieq $virtualMachine["OsDisk"]]
                        Write-Output "($vmName) removing managed $diskType ($($vmDisk["Name"]))."
                        Remove-AzDisk -DiskName $vmDisk["Name"] -ResourceGroupName $vmDisk["ResourceGroup"] -Force
                    }
                }

                # Remove VHD & status blobs of unmanaged OS disk
                if ($virtualMachine["OsDiskVhd"] -and ($removeUnmanagedOsdiskVhdBlob -ieq "Yes")) {
                    $vhdUri = $virtualMachine["OsDiskVhd"]
                    $vhdSaName = $vhdUri.Split('/')[2].Split('.')[0]
                    $vhdContainerName = $vhdUri.Split('/')[-2]
                    $unmanagedVmDiskBlob = $vhdUri.Split('/')[-1]
                    Write-Output "($vmName) Removing VHD blob ($vhdUri) of unmanaged OS Disk ($($virtualMachine["OsDisk"]))."
                    inlineScript {
                        $vhdSa = Get-AzStorageAccount | Where-Object -FilterScript {$_.StorageAccountName -eq $Using:vhdSaName}
                        $vhdSa | Remove-AzStorageBlob -Container $Using:vhdContainerName -Blob $Using:unmanagedVmDiskBlob
                        # Remove status blob unmanaged OS disk
                        Write-Output "($Using:vmName) Removing unmanaged OS disk status blob."
                        $vhdSa | Get-AzStorageBlob -Container $Using:vhdContainerName -Blob "$($Using:vmName)*.status" | Remove-AzStorageBlob
                        #$vhdSa | Get-AzureStorageBlob -Container $Using:vhdContainerName -Blob "$($Using:vmName)*.status" | Remove-AzureStorageBlob
                    }
                }
                Write-Output "($vmName) completely removed successfully. Now removing the Virtual network and Network Security Group."

                # Remove vNet and NSG
                Write-Output "Step 5: Removing Virtual Network and Network Security Group from ($vmRg) Resource group."
                $vNetName = (Get-AzVirtualNetwork -ResourceGroupName $vmRg).Name
                $vNet = Get-AzVirtualNetwork -ResourceGroupName $vmRg -Name $vNetName
                Write-Output "Removing Virtual Network from ($vmRg) Resource group."
                $vNet | Remove-AzVirtualNetwork -Force

                # Remove NSG
                $nsgName = (Get-AzNetworkSecurityGroup -ResourceGroupName $vmRg).Name
                $nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $vmRg -Name $nsgName
                Write-Output "emoving Network Security Group from ($vmRg) resource group."
                $nsg | Remove-AzNetworkSecurityGroup -Force

                # Process Complete
                Write-Output "All resources have been removed from ($vmRg) Resource group."
            }
            catch {
                $ErrorMessage = $_
                Write-Output "Failed to completely remove VM ($vmName) with error message: `n$ErrorMessage"
            }
        }
        
    }
    else {
        Write-Output "`nNo resource group resources set with tags Cleanup enabled in subscription $($servicePrincipleConnection.SubscriptionID). `nValid at the time of running this process $checkTime"
    }
    $endTime = Get-Date
    $executionTime = New-TimeSpan -Start $start -End $endTime
    $executionTimeMinutes = $executionTime.TotalMinutes
    Write-Output "`nTotal execution time $executionTimeMinutes minutes.`n"    
}