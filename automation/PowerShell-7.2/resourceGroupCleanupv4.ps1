<#
.VERSION    4.0.0
.AUTHOR     Chris Langford
.COPYRIGHT  (c) 2025 Chris Langford. All rights reserved.
.TAGS       Azure Automation, PowerShell Runbook, DevOps
.SYNOPSIS   Cleans up Azure resources tagged Cleanup=Enabled, with advanced logging and Teams notifications.
.NOTES
    LASTEDIT: 18-08-2025
#>

param(
    [Parameter(Mandatory=$true)]
    [bool]   $performCleanup = $false,

    [Parameter(Mandatory=$false)]
    [string] $teamsWebhookUrl
)

#–– Preferences ––
$ErrorActionPreference = 'Stop'
$WarningPreference     = 'Continue'
$VerbosePreference     = 'Continue'
$InformationPreference = 'Continue'

# Set teamsWebhookUrl from automation variable if not provided
if (-not $teamsWebhookUrl) {
    $teamsWebhookUrl = Get-AzAutomationVariable -Name 'TeamsWebhookUrl'
}

#–– Start Transcript ––
$transcript = Join-Path $env:TEMP "CleanupRun_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
Start-Transcript -Path $transcript -Force

$startTime = Get-Date
Write-Information "Cleanup run started at $startTime" -Tags CleanupRun

try {
    Write-Verbose "Authenticating to Azure with managed identity..."
    Connect-AzAccount -Identity
    Write-Information "Azure authentication succeeded." -Tags Authentication
}
catch {
    Write-Error "Authentication failed: $_"
    Stop-Transcript
    throw
}

if (-not $performCleanup) {
    Write-Information "performCleanup flag is False. No resources will be removed." -Tags CleanupRun
    Stop-Transcript
    return
}

#–– Functions ––
function Remove-BootDiagnostics {
    param([Microsoft.Azure.Management.Compute.Models.VirtualMachine]$VM)

    try {
        $uri = $VM.DiagnosticsProfile.BootDiagnostics.StorageUri
        if (-not $uri) { return }
        $storageName = [regex]::Match($uri, 'https[s]?://(.+?)\.').Groups[1].Value
        $cleanName   = ($VM.Name -replace '[^0-9a-zA-Z]', '').ToLower()
        $shortName   = $cleanName.Substring(0, [Math]::Min(9, $cleanName.Length))
        $container   = "bootdiagnostics-$shortName-$($VM.Id)"
        $sa          = Get-AzStorageAccount -Name $storageName -ErrorAction Stop
        $ctx         = $sa.Context

        Write-Verbose "Removing boot diagnostics container '$container' from storage account '$storageName'."
        Remove-AzStorageContainer -Name $container -Context $ctx -Force -ErrorAction Ignore

        Write-Information "Boot diagnostics container cleaned up for VM '$($VM.Name)'." -Tags Diagnostics
    }
    catch {
        Write-Warning "Failed to remove boot diagnostics for '$($VM.Name)': $_"
    }
}

function Remove-VMAndDependencies {
    param([Microsoft.Azure.Management.Compute.Models.VirtualMachine]$VM)

    try {
        Write-Information "Starting cleanup for VM '$($VM.Name)' in RG '$($VM.ResourceGroupName)'." -Tags VM

        # 1. Boot diagnostics
        Remove-BootDiagnostics -VM $VM

        # 2. Network interfaces
        $nics = Get-AzNetworkInterface -ResourceGroupName $VM.ResourceGroupName |
                Where-Object { $_.VirtualMachine.Id -eq $VM.Id }
        foreach ($nic in $nics) {
            Write-Verbose "Removing NIC '$($nic.Name)'."
            Remove-AzNetworkInterface -Name $nic.Name -ResourceGroupName $VM.ResourceGroupName -Force -ErrorAction SilentlyContinue
        }

        # 3. VM itself
        Write-Verbose "Removing VM '$($VM.Name)'."
        Remove-AzVM -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName -Force

        # 4. OS disk
        $osDiskName = $VM.StorageProfile.OsDisk.Name
        $osDisk = Get-AzDisk -ResourceGroupName $VM.ResourceGroupName -Name $osDiskName -ErrorAction SilentlyContinue
        if ($osDisk -and -not $osDisk.ManagedBy) {
            Write-Verbose "Removing unattached OS disk '$osDiskName'."
            Remove-AzDisk -ResourceGroupName $VM.ResourceGroupName -Name $osDiskName -Force -ErrorAction SilentlyContinue
        }

        Write-Information "VM '$($VM.Name)' and dependencies removed." -Tags VM
    }
    catch {
        Write-Error "Error cleaning VM '$($VM.Name)': $_"
    }
}

function Remove-NSGs {
    try {
        $nsgs = Get-AzNetworkSecurityGroup | Where-Object { $_.Tags['Cleanup'] -ieq 'Enabled' }
        foreach ($nsg in $nsgs) {
            Write-Information "Removing NSG '$($nsg.Name)' in RG '$($nsg.ResourceGroupName)'." -Tags NSG
            Remove-AzNetworkSecurityGroup -Name $nsg.Name -ResourceGroupName $nsg.ResourceGroupName -Force -ErrorAction SilentlyContinue
        }
    }
    catch {
        Write-Warning "NSG cleanup encountered an error: $_"
    }
}

function Remove-VirtualNetworks {
    try {
        $vnets = Get-AzVirtualNetwork | Where-Object { $_.Tags['Cleanup'] -ieq 'Enabled' }
        foreach ($vnet in $vnets) {
            Write-Information "Checking subnets for VNet '$($vnet.Name)'." -Tags VNet
            $busy = $false

            foreach ($sub in $vnet.Subnets) {
                $attached = (Get-AzNetworkInterface -SubnetId $sub.Id -ErrorAction SilentlyContinue).Count
                if ($attached -gt 0) {
                    Write-Warning "Subnet '$($sub.Name)' still has $attached NIC(s); skipping VNet deletion."
                    $busy = $true
                    break
                }
            }

            if (-not $busy) {
                Write-Information "Removing VNet '$($vnet.Name)' in RG '$($vnet.ResourceGroupName)'." -Tags VNet
                Remove-AzVirtualNetwork -Name $vnet.Name -ResourceGroupName $vnet.ResourceGroupName -Force -ErrorAction SilentlyContinue
            }
        }
    }
    catch {
        Write-Warning "VNet cleanup encountered an error: $_"
    }
}

#–– Parallel VM Cleanup ––
$vmList = Get-AzVM | Where-Object { $_.Tags['Cleanup'] -ieq 'Enabled' }

if ($vmList) {
    $vmList | ForEach-Object -Parallel {
        param($vm)
        Remove-VMAndDependencies -VM $vm
    } -ThrottleLimit 5
}
else {
    Write-Information "No VMs found with Cleanup=Enabled tag." -Tags VM
}

#–– NSG and VNet Cleanup ––
Remove-NSGs
Remove-VirtualNetworks

#–– Wrap Up ––
$endTime = Get-Date
$duration = New-TimeSpan -Start $startTime -End $endTime

Write-Information "Cleanup completed at $endTime (Duration: $([math]::Round($duration.TotalMinutes,2)) min)" -Tags CleanupRun

Stop-Transcript

#–– Teams Notification ––
if ($teamsWebhookUrl) {
    $payload = @{
        title = 'Azure Cleanup Run Report'
        text  = @"
**Status:** Completed  
**Start:** $startTime  
**End:** $endTime  
**Duration (min):** $([math]::Round($duration.TotalMinutes,2))  
**VMs targetted:** $($vmList.Count)
"@
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Method Post `
                         -Uri $teamsWebhookUrl `
                         -ContentType 'application/json' `
                         -Body $payload
        Write-Information "Teams notification sent." -Tags Notification
    }
    catch {
        Write-Warning "Failed to send Teams notification: $_"
    }
}

# Success card template
# $successCard = @{
#   "@type"       = "MessageCard"
#   "@context"    = "https://schema.org/extensions"
#   summary       = "Runbook Succeeded"
#   themeColor    = "00FF00"       # green
#   title         = "Cleanup Runbook Completed"
#   text          = "All resources were removed without errors."
#   sections      = @(
#     @{ facts = @(
#         @{ name = "Start Time"; value = $startTime }
#         @{ name = "End Time";   value = $endTime }
#         @{ name = "Duration";   value = ("{0:N2} min" -f $duration.TotalMinutes) }
#       )
#     }
#   )
# }

# # Failure card template
# $failureCard = @{
#   "@type"       = "MessageCard"
#   "@context"    = "https://schema.org/extensions"
#   summary       = "Runbook Failed"
#   themeColor    = "FF0000"       # red
#   title         = "Cleanup Runbook Encountered Errors"
#   text          = "Some resources could not be removed. Please review the logs."
#   sections      = @(
#     @{ facts = @(
#         @{ name = "Start Time"; value = $startTime }
#         @{ name = "Error";      value = $errorMessage }
#       )
#     }
#   )
# }

# try {
#     $payload = if ($runbookSucceeded) {
#         $successCard
#     } else {
#         $failureCard
#     }

#     $payloadJson = $payload | ConvertTo-Json -Depth 4
#     Invoke-RestMethod -Uri $teamsWebhookUrl -Method Post -Body $payloadJson -ContentType 'application/json'

# }
# catch {
#     Write-Warning "Failed to send Teams notification: $_"
# }

# if ($teamsWebhookUrl){
#     # Common values
#     $commonProps = @{
#     startTime    = $startTime
#     endTime      = $endTime
#     duration     = ("{0:N2} min" -f $duration.TotalMinutes)
#     }

#     if ($runbookSucceeded) {
#     $commonProps += @{
#         title        = "Cleanup Succeeded"
#         titleColor   = "Good"         # theme colors supported by Adaptive Cards
#         message      = "All tagged resources have been removed."
#         messageColor = "Default"
#     }
#     } else {
#     $commonProps += @{
#         title        = "Cleanup Failed"
#         titleColor   = "Attention"
#         message      = "Errors occurred during resource removal. Check logs."
#         messageColor = "Warning"
#     }
#     }

#     # Read the JSON template, replace placeholders, and send
#     $templateJson = Get-Content -Raw '.\adaptive-template.json'
#     foreach ($k in $commonProps.Keys) {
#     $templateJson = $templateJson -replace "\$\{$k\}", $commonProps[$k]
#     }

#     try {
#         Invoke-RestMethod -Uri $teamsWebhookUrl `
#                         -Method Post `
#                         -Body $templateJson `
#                         -ContentType 'application/json'
#         Write-Information "Teams notification sent successfully." -Tags Notification
#     }
#     catch {
#         Write-Warning "Failed to send Teams notification: $_"
#     }
# }