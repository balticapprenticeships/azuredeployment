<#
.VERSION    4.3.1
.AUTHOR     Chris Langford
.COPYRIGHT  (c) 2025 Chris Langford. All rights reserved.
.TAGS       Azure Automation, PowerShell Runbook, DevOps
.SYNOPSIS   Cleans up Azure resources tagged Cleanup=Enabled, with advanced logging and Teams notifications.
.NOTES
    LASTEDIT: 18-08-2025
#>

param(
    # Master toggle for cleanup (required, must be $true or $false explicitly)
    [Parameter(Mandatory=$true)]
    [ValidateNotNull()]
    [bool] $cleanupEnabled,

    # Teams webhook URL (optional, must be https:// if provided)
    [Parameter(Mandatory=$false)]
    [ValidatePattern('^https://.*')]
    [string] $teamsWebhookUrl,

    # Execution mode: Sequential (safe) or Parallel (faster, riskier)
    [Parameter(Mandatory=$true)]
    [ValidateNotNull()]
    [bool] $ParallelMode,

    # Throttle for parallel jobs (only matters if ExecutionMode = Parallel)
    [Parameter(Mandatory=$false)]
    [ValidateRange(1, 20)]
    [int] $ThrottleLimit = 5  # <-- new parameter (default 5)
)

#–– Preferences ––
$ErrorActionPreference = 'Stop'
$WarningPreference     = 'Continue'
$VerbosePreference     = 'Continue'
$InformationPreference = 'Continue'

# Set teamsWebhookUrl from automation variable if not provided
if (-not $teamsWebhookUrl) {
    try {
        $teamsWebhookUrl = Get-AutomationVariable -Name 'TeamWebhookUrlWeeklyCleanup'
    }
    catch {
        Write-Verbose "No Teams webhook URL provided or found in automation variables."
    }
}

#–– Start Transcript ––
$transcript = Join-Path $env:TEMP "CleanupRun_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
Start-Transcript -Path $transcript -Force

# Log execution mode
if ($ParallelMode) {
    Write-Information "Execution Mode: Parallel (ThrottleLimit=$ThrottleLimit)" -Tags CleanupRun
}
else {
    Write-Information "Execution Mode: Sequential" -Tags CleanupRun
}

$global:cleanupResults = @{
    StartTime      = Get-Date
    EndTime        = $null
    Duration       = $null
    VMsTargeted    = 0
    VMsRemoved     = 0
    SkippedVMs     = @()
    SkippedNSGs    = @()
    FailedVMs      = @()
    SkippedVNets   = @()
    FailedNSGs     = @()
    Errors         = 0
}

Write-Information "Cleanup run started at $($global:cleanupResults.StartTime)" -Tags CleanupRun

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

if (-not $cleanupEnabled) {
    Write-Information "cleanupEnabled flag is False. No resources will be removed." -Tags CleanupRun
    Stop-Transcript
    return
}

#–– Functions ––
function Remove-BootDiagnostics {
    param($VM)

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
        $global:cleanupResults.FailedVMs += $VM.Name
        $global:cleanupResults.Errors++
    }
}

function Remove-VMAndDependencies {
    param($VM)

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
        $global:cleanupResults.VMsRemoved++
    }
    catch {
        Write-Warning "Error cleaning VM '$($VM.Name)': $_"
        $global:cleanupResults.FailedVMs += $VM.Name
        $global:cleanupResults.Errors++
    }
}

function Remove-NSGs {
    try {
        $nsgs = Get-AzNetworkSecurityGroup | Where-Object { $_.Tags -and $_.Tags['Cleanup'] -ieq 'Enabled' }
        foreach ($nsg in $nsgs) {
            Write-Information "Removing NSG '$($nsg.Name)' in RG '$($nsg.ResourceGroupName)'." -Tags NSG
            Remove-AzNetworkSecurityGroup -Name $nsg.Name -ResourceGroupName $nsg.ResourceGroupName -Force -ErrorAction SilentlyContinue
        }
    }
    catch {
        Write-Warning "NSG cleanup encountered an error: $_"
        $global:cleanupResults.FailedNSGs += $_.Exception.Message
        $global:cleanupResults.Errors++
    }
}

function Remove-VirtualNetworks {
    try {
        $vnets = Get-AzVirtualNetwork | Where-Object { $_.Tags -and $_.Tags['Cleanup'] -ieq 'Enabled' }
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
            else {
                $global:cleanupResults.SkippedVNets += $vnet.Name
            }
        }
    }
    catch {
        Write-Warning "VNet cleanup encountered an error: $_"
        $global:cleanupResults.Errors++
    }
}

#–– VM Cleanup ––
$vmList = Get-AzVM | Where-Object { $_.Tags -and $_.Tags['Cleanup'] -ieq 'Enabled' }
$global:cleanupResults.VMsTargeted = $vmList.Count

if ($vmList) {
    if ($ParallelMode) {
        Write-Information "Running VM cleanup in PARALLEL mode (ThrottleLimit=$ThrottleLimit)." -Tags VM

        # Export the function bodies as ScriptBlocks so they can be recreated inside parallel runspaces
        $removeVMScript   = (Get-Item -Path Function:\Remove-VMAndDependencies).ScriptBlock
        $removeBootScript = (Get-Item -Path Function:\Remove-BootDiagnostics).ScriptBlock

        $vmList | ForEach-Object -Parallel {
            param($vm, $removeVMScript, $removeBootScript)

            # Recreate the functions in this runspace so they can be invoked normally
            Set-Item -Path Function:\Remove-BootDiagnostics -Value $removeBootScript
            Set-Item -Path Function:\Remove-VMAndDependencies -Value $removeVMScript

            # Run cleanup
            Remove-VMAndDependencies -VM $vm
        } -ArgumentList $using:removeVMScript, $using:removeBootScript -ThrottleLimit $ThrottleLimit
    }
    else {
        Write-Information "Running VM cleanup in SEQUENTIAL mode." -Tags VM
        foreach ($vm in $vmList) {
            Remove-VMAndDependencies -VM $vm
        }
    }
}
else {
    Write-Information "No VMs found with Cleanup=Enabled tag." -Tags VM
}

#–– NSG and VNet Cleanup ––
Remove-NSGs
Remove-VirtualNetworks

#–– Wrap Up ––
$global:cleanupResults.EndTime  = Get-Date
$global:cleanupResults.Duration = [math]::Round((New-TimeSpan -Start $global:cleanupResults.StartTime -End $global:cleanupResults.EndTime).TotalMinutes, 2)

Write-Information "Cleanup completed at $($global:cleanupResults.EndTime) (Duration: $($global:cleanupResults.Duration) min)" -Tags CleanupRun

Stop-Transcript

#–– Teams Notification with collapsible sections ––
if ($teamsWebhookUrl) {

    # Build summary line
    $summaryLine = "$($global:cleanupResults.VMsRemoved) removed"
    if ($global:cleanupResults.SkippedVMs.Count -gt 0) { $summaryLine += ", $($global:cleanupResults.SkippedVMs.Count) skipped" }
    if ($global:cleanupResults.FailedVMs.Count -gt 0)   { $summaryLine += ", $($global:cleanupResults.FailedVMs.Count) failed" }
    if ($global:cleanupResults.FailedNSGs.Count -gt 0)  { $summaryLine += ", $($global:cleanupResults.FailedNSGs.Count) NSG errors" }
    if ($global:cleanupResults.SkippedVNets.Count -gt 0) { $summaryLine += ", $($global:cleanupResults.SkippedVNets.Count) VNets skipped" }

    # Determine status and color
    if ($global:cleanupResults.Errors -gt 0 -or $global:cleanupResults.FailedVMs.Count -gt 0 -or $global:cleanupResults.FailedNSGs.Count -gt 0) {
        $statusText  = "❌ Completed with Errors — $summaryLine"
        $statusColor = "Attention"
    }
    elseif ($global:cleanupResults.SkippedVMs.Count -gt 0 -or $global:cleanupResults.SkippedVNets.Count -gt 0) {
        $statusText  = "⚠️ Completed with Skipped Items — $summaryLine"
        $statusColor = "Warning"
    }
    else {
        $statusText  = "✅ Completed Successfully — $summaryLine"
        $statusColor = "Good"
    }

    # Execution mode string
    $executionModeText = if ($ParallelMode) { "Parallel (ThrottleLimit=$ThrottleLimit)" } else { "Sequential" }

    # Adaptive Card body
    $cardBody = @(
        @{
            type  = "TextBlock"
            text  = "Azure Cleanup Run Report"
            weight= "Bolder"
            size  = "Large"
        },
        @{
            type  = "TextBlock"
            text  = $statusText
            color = $statusColor
            weight= "Bolder"
            size  = "Medium"
            wrap  = $true
            spacing = "Small"
        },
        @{
            type  = "TextBlock"
            text  = "Execution Mode: $executionModeText"
            weight= "Bolder"
            size  = "Small"
            wrap  = $true
            spacing = "Small"
        },
        @{
            type = "FactSet"
            facts = @(
                @{ title = "Start:";        value = "$($global:cleanupResults.StartTime)" },
                @{ title = "End:";          value = "$($global:cleanupResults.EndTime)" },
                @{ title = "Duration:";     value = "$($global:cleanupResults.Duration) min" },
                @{ title = "VMs targeted:"; value = "$($global:cleanupResults.VMsTargeted)" },
                @{ title = "VMs removed:";  value = "$($global:cleanupResults.VMsRemoved)" },
                @{ title = "Errors:";       value = "$($global:cleanupResults.Errors)" }
            )
        }
    )

    # Function to add collapsible sections
    function Add-CollapsibleSection {
        param($title, $items)
        if ($items.Count -gt 0) {
            $itemList = $items | ForEach-Object { @{ type="TextBlock"; text="• $_"; wrap=$true; spacing="None" } }
            $toggleId = ($title -replace '[^0-9a-zA-Z]', '') + "_toggle"

            return @{
                type = "Container"
                items = @(
                    @{
                        type = "ActionSet"
                        actions = @(
                            @{
                                type = "Action.ToggleVisibility"
                                title = $title
                                target = @(@{ elementId = $toggleId })
                            }
                        )
                    },
                    @{
                        type      = "Container"
                        id        = $toggleId
                        isVisible = $false
                        items     = $itemList
                    }
                )
            }
        }
        return $null
    }

    $sections = @(
        Add-CollapsibleSection -title "❌ Failed VMs"     -items $global:cleanupResults.FailedVMs
        Add-CollapsibleSection -title "⚠️ Skipped VMs"   -items $global:cleanupResults.SkippedVMs
        Add-CollapsibleSection -title "❌ NSG Errors"    -items $global:cleanupResults.FailedNSGs
        Add-CollapsibleSection -title "⚠️ Skipped VNets" -items $global:cleanupResults.SkippedVNets
    ) | Where-Object { $_ -ne $null }

    $cardBody += $sections

    $payload = @{
        type       = "message"
        attachments= @(@{
            contentType = "application/vnd.microsoft.card.adaptive"
            content     = @{
                type     = "AdaptiveCard"
                version  = "1.5"
                body     = $cardBody
                msteams  = @{ width = "Full" }
            }
        })
    } | ConvertTo-Json -Depth 10 -Compress

    try {
        Invoke-RestMethod -Uri $teamsWebhookUrl -Method Post -Body $payload -ContentType 'application/json'
        Write-Information "Teams notification sent successfully." -Tags Teams
    }
    catch {
        Write-Warning "Failed to send Teams notification: $_"
    }
}
