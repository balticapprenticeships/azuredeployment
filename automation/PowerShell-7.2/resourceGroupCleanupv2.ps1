<#
.VERSION 2.0.0

.AUTHOR Chris Langford

.COPYRIGHT (c) 2023 Chris Langford. All rights reserved.

.TAGS Azure Automation Azure Resource Group PowerShell Runbook DevOps 

.SYNOPSIS  
  Connects to Azure and delete virtual machines and associated resources with the tag Cleanup
  
.DESCRIPTION  
  This runbook connects to Azure and and delete virtual machines and associated resources with the tag Cleanup.
  
  REQUIRED AUTOMATION ASSETS 
   
  
.NOTES
   AUTHOR: Chris Langford 
   LASTEDIT: 27.01.23
#>
param (
    [Parameter(mandatory = $true)]
    [string]$cleanupResourceGroup
)

$ErrorActionPreference = "Continue"
$WarningPreference = @("SilentlyContinue", "Continue")

"Please enable appropriate RBAC permissions to the system identity of this automation account. Otherwise, the runbook may fail..."
try {
    "logging in to Azure....."
    Connect-AzAccount -Identity
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

# Get VMs with tag.value Cleanup.Enabled
try {
    $start = Get-Date

    if ($cleanupResourceGroup -ieq "Yes"){
        Write-Output "`nStarting resource group cleanup"
        $vmList = Get-AzVM | Where-Object {$_.Tags.Cleanup -ieq 'Enabled'}
        #$vmRg = $vmList.ResourceGroupName
        #$vmName = $vmList.Name
        foreach($vm in $vmList){
            Write-Output "Starting removal of VM $($vm.name) in resource group $($vm.ResourceGroupName)"
            $vmBootDiag = $vm.DiagnosticsProfile.BootDiagnostics.StorageUri
            if($vmBootDiag){
                $diagSa = [regex]::match($vmBootDiag, 'Https[s]?://(.+?)\.').Groups[1].Value
                $vmDiagName = $vm.Name -replace '[^a-zA-Z0-9]',''
                if($vmDiagName.Length -gt 9){
                    $i = 9
                }else{
                    $i = $vmDiagName.Length
                }
                $diagContainerName = ('bootdiagnostics-{0}-{1}' -f $vmDiagName.ToLower().Substring(0, $i), $vm.Id)
                $diagSaRg = (Get-AzStorageAccount | Where-Object -FilterScript {$_.StorageAccountName -eq $diagSa}).ResourceGroupName
                #$saParams = @{'ResourceGroupName' = $diagSaRg; 'Name' = $diagSa}
                Write-Output "$($vm.Name) Step 1: Removing boot diagnostics storage container ($diagContainerName) in storage account ($diagSa)."
                Get-AzStorageAccount -ResourceGroupName $diagSaRg -Name $diagSa | Get-AzStorageContainer | Where-Object -FilterScript { $_.Name -eq $diagContainerName } | Remove-AzStorageContainer -Force
            }else{
                Write-Output "Step 1: No boot diagnostics features configured."
            }

            # Removing VM
            Write-Output "Step 2: Removing VM $($vm.name)."
            Remove-AzVM -Name $vm.name -ResourceGroupName $vm.ResourceGroupName -Force
            Write-Output "`n$($vm.Name) successfully deleted.`n"
        }

        # remove NSG
        $nsgList = Get-AzNetworkSecurityGroup | Where-Object {$_.Tag.Cleanup -ieq 'Enabled'}
        #$nsgRg = $nsgList.ResourceGroupName
        #$nsgName = $nsgList.Name        
        Write-Output "Step 3: Checking for Network Security groups."
        foreach($nsg in $nsgList){
            Write-Output "`nStep 4: Removing Network Security Group $($nsg.Name) from $($nsg.ResourceGroupName) resource group."
            #$nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $nsg.ResourceGroupName -Name $nsg.Name
            $nsg | Remove-AzNetworkSecurityGroup -Force
        }        

        # remove vNet
        $vnetList = Get-AzVirtualNetwork  | Where-Object {$_.Tag.Cleanup -ieq 'Enabled'}
        #$vnetRg = $vnetList.ResourceGroupName
        #$vnetName = $vnetList.Name
        Write-Output "Step 5: Checking for Virtual Networks."
        foreach($vnet in $vnetList){
            Write-Output "Step 6: Removing virtual network $($vnet.Name) from $($vnet.ResourceGroupName) resource group."
            #$vnet = Get-AzVirtualNetwork -ResourceGroupName $vnet.ResourceGroupName -Name $vnet.Name
            $vnet | Remove-AzVirtualNetwork -Force
        }
        
        # Cleanup complete
        Write-Output "`nAll resources have been removed."
    }else{
        Write-Output "No VM resources exist with the tag Cleanup enabled"
        exit
    }
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

$endTime = Get-Date
$executionTime = New-TimeSpan -Start $start -End $endTime
$executionTimeMinutes = $executionTime.TotalMinutes
Write-Output "`nTotal execution time $executionTimeMinutes minutes.`n"