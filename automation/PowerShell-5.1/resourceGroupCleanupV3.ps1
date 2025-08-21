<#
.VERSION 2.0.1

.AUTHOR Chris Langford

.COPYRIGHT (c) 2023 Chris Langford. All rights reserved.

.TAGS Azure Automation Azure Resource Group PowerShell Runbook DevOps 

.SYNOPSIS  
  Connects to Azure and deletes virtual machines and associated resources with the tag Cleanup

.DESCRIPTION  
  This runbook connects to Azure and deletes virtual machines and associated resources with the tag Cleanup.

.NOTES
  AUTHOR: Chris Langford 
  LASTEDIT: 18.08.25
#>

param (
    [Parameter(Mandatory = $true)]
    [bool]$performCleanup
)

$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"

Write-Output "Ensure appropriate RBAC permissions are granted to the system identity of this automation account."

try {
    Write-Output "Logging in to Azure..."
    Connect-AzAccount -Identity
}
catch {
    Write-Error "Azure login failed: $($_.Exception.Message)"
    throw
}

if ($performCleanup) {
    $start = Get-Date
    Write-Output "`nStarting resource cleanup process..."

    # Get VMs tagged with Cleanup=Enabled
    $vmList = Get-AzVM | Where-Object { $_.Tags["Cleanup"] -ieq 'Enabled' }

    foreach ($vm in $vmList) {
        Write-Output "Removing VM '$($vm.Name)' in resource group '$($vm.ResourceGroupName)'..."

        $vmBootDiag = $vm.DiagnosticsProfile.BootDiagnostics.StorageUri
        if ($vmBootDiag) {
            $diagSa = [regex]::match($vmBootDiag, 'https[s]?://(.+?)\.').Groups[1].Value
            $vmDiagName = $vm.Name -replace '[^a-zA-Z0-9]', ''
            $diagContainerName = "bootdiagnostics-$($vmDiagName.ToLower().Substring(0, [Math]::Min(9, $vmDiagName.Length)))-$($vm.Id)"
            $diagSaRg = (Get-AzStorageAccount | Where-Object { $_.StorageAccountName -eq $diagSa }).ResourceGroupName
            $storageAccount = Get-AzStorageAccount -ResourceGroupName $diagSaRg -Name $diagSa
            $ctx = $storageAccount.Context

            Write-Output "Step 1: Removing boot diagnostics container '$diagContainerName' from storage account '$diagSa'..."
            Remove-AzStorageContainer -Name $diagContainerName -Context $ctx -Force
        }
        else {
            Write-Output "Step 1: No boot diagnostics configured for VM '$($vm.Name)'."
        }

        Write-Output "Step 2: Deleting VM '$($vm.Name)'..."
        Remove-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Force
        Write-Output "VM '$($vm.Name)' successfully deleted.`n"
    }

    # Remove NSGs
    $nsgList = Get-AzNetworkSecurityGroup | Where-Object { $_.Tags["Cleanup"] -ieq 'Enabled' }
    foreach ($nsg in $nsgList) {
        Write-Output "Step 3: Removing NSG '$($nsg.Name)' from resource group '$($nsg.ResourceGroupName)'..."
        Remove-AzNetworkSecurityGroup -Name $nsg.Name -ResourceGroupName $nsg.ResourceGroupName -Force
    }

    # Remove vNets
    $vnetList = Get-AzVirtualNetwork | Where-Object { $_.Tags["Cleanup"] -ieq 'Enabled' }
    foreach ($vnet in $vnetList) {
        Write-Output "Step 4: Removing virtual network '$($vnet.Name)' from resource group '$($vnet.ResourceGroupName)'..."
        Remove-AzVirtualNetwork -Name $vnet.Name -ResourceGroupName $vnet.ResourceGroupName -Force
    }

    Write-Output "`nAll tagged resources have been removed."
    $endTime = Get-Date
    $executionTime = New-TimeSpan -Start $start -End $endTime
    Write-Output "`n⏱Total execution time: $($executionTime.TotalMinutes) minutes.`n"
}
else {
    Write-Output "Cleanup flag not set. No resources were removed."
}
