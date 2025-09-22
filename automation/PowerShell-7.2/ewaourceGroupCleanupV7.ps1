<#
.VERSION 7.1.0
.AUTHOR Chris Langford
.COPYRIGHT (c) 2023 Chris Langford. All rights reserved.
.TAGS Azure Automation Azure Resource Group PowerShell Runbook DevOps
.SYNOPSIS Deletes Azure VMs and related resources tagged with Cleanup
.DESCRIPTION Connects to Azure, deletes VMs, NSGs, vNets tagged Cleanup, and sends Teams notification
.NOTES LASTEDIT: 26.08.25
#>

param (
    [Parameter(Mandatory = $true)]
    [bool]$performCleanup
)

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

function Write-Log {
    param([string]$Message)
    Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
}

Write-Log "Starting cleanup runbook..."

try {
    Write-Log "Authenticating with Azure..."
    Connect-AzAccount -Identity
}
catch {
    Write-Error "Azure login failed: $_"
    throw
}

$startTime = Get-Date
$teamsWebhook = Get-AutomationVariable -Name "TeamsWebhookUrl"
$jobs = @()

if ($performCleanup) {
    Write-Log "Searching for VMs tagged Cleanup..."

    $vmList = Get-AzVM | Where-Object { $_.Tags["Cleanup"] -ieq "Enabled" }

    foreach ($vm in $vmList) {
        $jobs += Start-Job -ScriptBlock {
            param($vm)

            function Write-JobLog {
                param([string]$msg)
                Write-Output "$(Get-Date -Format 'HH:mm:ss') [VM: $($vm.Name)] - $msg"
            }

            Write-JobLog "Starting cleanup..."

            $vmBootDiag = $vm.DiagnosticsProfile.BootDiagnostics.StorageUri
            if ($vmBootDiag) {
                $diagSa = [regex]::match($vmBootDiag, 'https[s]?://(.+?)\.').Groups[1].Value
                $vmDiagName = $vm.Name -replace '[^a-zA-Z0-9]', ''
                $diagContainerName = "bootdiagnostics-$($vmDiagName.ToLower().Substring(0, [Math]::Min(9, $vmDiagName.Length)))-$($vm.Id)"
                $diagSaRg = (Get-AzStorageAccount | Where-Object { $_.StorageAccountName -eq $diagSa }).ResourceGroupName
                $storageAccount = Get-AzStorageAccount -ResourceGroupName $diagSaRg -Name $diagSa
                $ctx = $storageAccount.Context

                Write-JobLog "Removing boot diagnostics container $diagContainerName..."
                Remove-AzStorageContainer -Name $diagContainerName -Context $ctx -Force
            }

            Write-JobLog "Deleting VM..."
            Remove-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Force

            Write-JobLog "VM $($vm.Name) deleted successfully."
        } -ArgumentList $vm
    }

    Write-Log "Waiting for VM deletion jobs to complete..."
    $jobs | Wait-Job | Receive-Job | ForEach-Object { Write-Output $_ }
    $jobs | Remove-Job

    Write-Log "Cleaning up NSGs..."
    $nsgList = Get-AzNetworkSecurityGroup | Where-Object { $_.Tags["Cleanup"] -ieq "Enabled" }
    foreach ($nsg in $nsgList) {
        Write-Log "Removing NSG $($nsg.Name)..."
        Remove-AzNetworkSecurityGroup -Name $nsg.Name -ResourceGroupName $nsg.ResourceGroupName -Force
    }

    Write-Log "Cleaning up Virtual Networks..."
    $vnetList = Get-AzVirtualNetwork | Where-Object { $_.Tags["Cleanup"] -ieq "Enabled" }
    foreach ($vnet in $vnetList) {
        Write-Log "Removing vNet $($vnet.Name)..."
        Remove-AzVirtualNetwork -Name $vnet.Name -ResourceGroupName $vnet.ResourceGroupName -Force
    }

    Write-Log "Cleanup complete."
}
else {
    Write-Log "Cleanup flag not set. Exiting."
    exit
}

$endTime = Get-Date
$duration = ($endTime - $startTime).TotalMinutes
Write-Log "Total execution time: $([math]::Round($duration,2)) minutes."

# Send Teams notification
$payload = @{
    title = "Azure Cleanup Runbook"
    text  = "Cleanup completed successfully in $([math]::Round($duration,2)) minutes."
} | ConvertTo-Json -Depth 3

Invoke-RestMethod -Uri $teamsWebhook -Method Post -Body $payload -ContentType 'application/json'
Write-Log "Teams notification sent."
