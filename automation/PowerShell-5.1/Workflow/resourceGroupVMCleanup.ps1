################################################################
# Script to delete VM resources from resource group            #
# Author: Chris Langford                                       #
# Version: 2.0.0                                               #
################################################################
workflow ResourceGroupVMCleanup {
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

    "Please enable appropriate RBAC permissions to the system identity of this automation account. Otherwise, the runbook may fail..."

    try {
        "Logging in to Azure..."
        Connect-AzAccount -Identity
    }
    catch {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }

    try {        
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
        Write-Output "Failed to obtain Get VMs: " $_
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

                Write-Output "($vmName) completely removed successfully. Now removing the Virtual network and Network Security Group."

                # Remove vNet and NSG
                Write-Output "Step 2: Removing Virtual Network and Network Security Group from ($vmRg) Resource group."
                $vNetName = (Get-AzVirtualNetwork -ResourceGroupName $vmRg).Name
                $vNet = Get-AzVirtualNetwork -ResourceGroupName $vmRg -Name $vNetName
                Write-Output "Removing Virtual Network from ($vmRg) Resource group."
                $vNet | Remove-AzVirtualNetwork -Force

                # Remove NSG
                $nsgName = (Get-AzNetworkSecurityGroup -ResourceGroupName $vmRg).Name
                $nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $vmRg -Name $nsgName
                Write-Output "emoving Network Security Group from ($vmRg) resource group."
                $nsg | Remove-AzNetworkSecurityGroup -Force

                # Remove VM
                Write-Output "($vmName) Step 3: Removing the VM."
                Remove-AzVM -Name $vmName -ResourceGroupName $vmRg -Force

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