<#
.SYNOPSIS
    Azure Automation Runbook to clean up resources based on CourseEndDay tag.
.DESCRIPTION
    Searches for resources tagged with CourseEndDay, deletes them according to schedule,
    cleans up DNS CNAME records for VMs, and posts a summary to Microsoft Teams.
    This version inlines all actions (no Execute-ActionCommand wrapper) and allows
    DNS zone and CourseEndDay to be passed as parameters.
#>

param (
    [string] $Mode = "Delete",                # Delete | Start | Stop
    [bool]   $SafeMode = $false,              # Dry run if true
    [int]    $DelayPeriod = 30,               # Delay between schedules
    [string] $DnsZoneResourceGroup = "InternalOMSRg",
    [string] $DnsZoneName = "balticlabs.co.uk",
    [string] $CourseEndDay = "Monday",        # Match CourseEndDay tag value
    [string] $TeamsWebhookUrl                 # Optional – pass manually or fallback to Automation Variable
)

# Load webhook from Automation variable if not supplied
if (-not $TeamsWebhookUrl) {
    $TeamsWebhookUrl = Get-AutomationVariable -Name "TEAMS_WEBHOOK_URL_DAILY_VM_DELETE"
}


# ========= Auth =========
try {
    Connect-AzAccount -Identity -ErrorAction Stop
    Write-Output "Authenticated successfully with Managed Identity."
}
catch {
    Write-Error "Failed to authenticate: $($_.Exception.Message)"
    exit 1
}

# ========= Helpers =========
function Log {
    param([string]$message)
    Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $message"
}

function Send-TeamsMessage {
    param (
        [string]$WebhookUrl,
        [string]$Title,
        [string]$Message,
        [string]$Color = "0078D7"
    )
    $payload = @{
        "@type"      = "MessageCard"
        "@context"   = "http://schema.org/extensions"
        "themeColor" = $Color
        "summary"    = $Title
        "sections"   = @(@{
            "activityTitle" = $Title
            "text"          = $Message
        })
    } | ConvertTo-Json -Depth 10

    try {
        Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $payload -ContentType 'application/json'
    }
    catch {
        Write-Error "Failed to send Teams message: $($_.Exception.Message)"
    }
}

# ========= Config =========
$teamsWebhookUrl = Get-AutomationVariable -Name "TEAMS_WEBHOOK_URL_DAILY_VM_DELETE"
if (-not $teamsWebhookUrl) {
    Log "ERROR: Teams webhook URL not found in Automation Variables."
    exit 1
}

$Deleting = $Mode -eq "Delete"

# ========= Resource Graph Query =========
$query = @"
Resources
| where type in~ ('Microsoft.Compute/virtualMachines','Microsoft.Compute/virtualMachineScaleSets','Microsoft.ContainerService/managedClusters','Microsoft.Network/publicIpAddresses','Microsoft.Network/bastionHosts')
| extend tags = iff(isnull(tags), bag_pack('key','', 'value',''), tags)
| mv-expand tags
| extend tagKey = tostring(tags.key), tagValue = tostring(tags.value)
| where tagKey =~ 'CourseEndDay'
| where tagValue =~ '$CourseEndDay'
| project name, type, tagValue, resourceGroup, id
"@

try {
    $resources = Search-AzGraph -Query $query
}
catch {
    Log "ERROR: Failed to query Azure Resource Graph: $($_.Exception.Message)"
    exit 1
}

if (-not $resources -or @($resources).Count -eq 0) {
    Log "No resources found matching the query."
    Send-TeamsMessage -WebhookUrl $teamsWebhookUrl -Title "Azure Cleanup Execution Report" -Message "No resources were processed." -Color "00FF00"
    exit 0
}

$resources = $resources | Sort-Object tagValue
Log "Discovered $(@($resources).Count) resources for deletion check."
$deleteSchedule = $resources[0].tagValue

# Preload DNS records if deleting (and not safe mode)
if ($Deleting -and -not $SafeMode) {
    try {
        $dnsRecords = Get-AzDnsRecordSet -ZoneName $DnsZoneName -ResourceGroupName $DnsZoneResourceGroup -RecordType CNAME -ErrorAction Stop
    }
    catch {
        Log "WARNING: Could not preload DNS CNAME records: $($_.Exception.Message)"
        $dnsRecords = @()
    }
}

# ========= Tracking =========
$deletedResources = @()
$failedResources  = @()
$skippedResources = @()

# ========= Processing =========
foreach ($resource in $resources) {
    if ($resource.tagValue -ne $deleteSchedule) {
        Log "Schedule changed: $deleteSchedule → $($resource.tagValue). Sleeping for $DelayPeriod seconds..."
        Start-Sleep -Seconds $DelayPeriod
        $deleteSchedule = $resource.tagValue
    }

    switch ($resource.type.ToLower()) {
        'microsoft.compute/virtualmachines' {
            if (-not $Deleting) { break }

            # DNS CNAME cleanup
            if ($SafeMode) {
                Log "[SAFE MODE] Would delete DNS CNAME '$($resource.name)' in zone '$DnsZoneName' (if it exists)."
            } else {
                try {
                    $matchingRecord = $dnsRecords | Where-Object { $_.Name -ieq $resource.name }
                    if ($matchingRecord) {
                        Log "Deleting DNS CNAME '$($resource.name)' in zone '$DnsZoneName'..."
                        Remove-AzDnsRecordSet -Name $resource.name -ZoneName $DnsZoneName -ResourceGroupName $DnsZoneResourceGroup -RecordType CNAME -Force -ErrorAction Stop
                        Log "Deleted DNS CNAME '$($resource.name)'."
                    } else {
                        Log "No matching DNS CNAME record found for VM '$($resource.name)'."
                    }
                }
                catch {
                    $failedResources += "DNS CNAME: $($resource.name) - $($_.Exception.Message)"
                }
            }

            # VM deletion
            if ($SafeMode) {
                Log "[SAFE MODE] Would delete VM '$($resource.name)' in RG '$($resource.resourceGroup)'."
                $deletedResources += "VM (WhatIf): $($resource.name)"
            } else {
                try {
                    Log "Deleting VM '$($resource.name)'..."
                    Remove-AzVM -Name $resource.name -ResourceGroupName $resource.resourceGroup -Force -NoWait -ErrorAction Stop
                    $deletedResources += "VM: $($resource.name)"
                }
                catch {
                    $failedResources += "VM: $($resource.name) - $($_.Exception.Message)"
                }
            }
        }

        'microsoft.compute/virtualmachinescalesets' {
            if (-not $Deleting) { break }

            $skipExecution = $false
            try {
                $vmssInfo = Get-AzVmss -VMScaleSetName $resource.name -ResourceGroupName $resource.resourceGroup -ErrorAction Stop
                $extensions = @()
                if ($vmssInfo.VirtualMachineProfile.ExtensionProfile.Extensions) {
                    $extensions = $vmssInfo.VirtualMachineProfile.ExtensionProfile.Extensions.Type
                }
                if ($extensions -contains "Compute.AKS.Linux.Billing" -or $extensions -contains "Compute.AKS.Windows.Billing") {
                    Log "SKIP: VMSS '$($resource.name)' is part of AKS. Use AKS resource for actions."
                    $skipExecution = $true
                    $skippedResources += "VMSS (AKS): $($resource.name)"
                }
            }
            catch {
                Log "ERROR: Failed to retrieve VMSS '$($resource.name)' info. Skipping."
                $skipExecution = $true
                $skippedResources += "VMSS: $($resource.name)"
            }

            if (-not $skipExecution) {
                if ($SafeMode) {
                    Log "[SAFE MODE] Would delete VMSS '$($resource.name)' in RG '$($resource.resourceGroup)'."
                    $deletedResources += "VMSS (WhatIf): $($resource.name)"
                } else {
                    try {
                        Log "Deleting VMSS '$($resource.name)'..."
                        Remove-AzVmss -VMScaleSetName $resource.name -ResourceGroupName $resource.resourceGroup -Force -NoWait -ErrorAction Stop
                        $deletedResources += "VMSS: $($resource.name)"
                    }
                    catch {
                        $failedResources += "VMSS: $($resource.name) - $($_.Exception.Message)"
                    }
                }
            }
        }

        'microsoft.network/publicipaddresses' {
            if (-not $Deleting) { break }

            if ($SafeMode) {
                Log "[SAFE MODE] Would delete Public IP '$($resource.name)' in RG '$($resource.resourceGroup)'."
                $deletedResources += "Public IP (WhatIf): $($resource.name)"
            } else {
                try {
                    Log "Deleting Public IP '$($resource.name)'..."
                    Remove-AzPublicIpAddress -Name $resource.name -ResourceGroupName $resource.resourceGroup -Force -ErrorAction Stop
                    $deletedResources += "Public IP: $($resource.name)"
                }
                catch {
                    $failedResources += "Public IP: $($resource.name) - $($_.Exception.Message)"
                }
            }
        }

        'microsoft.network/bastionhosts' {
            if (-not $Deleting) { break }

            if ($SafeMode) {
                Log "[SAFE MODE] Would delete Bastion Host '$($resource.name)' in RG '$($resource.resourceGroup)'."
                $deletedResources += "Bastion (WhatIf): $($resource.name)"
            } else {
                try {
                    Log "Deleting Bastion Host '$($resource.name)'..."
                    Remove-AzBastion -Name $resource.name -ResourceGroupName $resource.resourceGroup -Force -ErrorAction Stop
                    $deletedResources += "Bastion: $($resource.name)"
                }
                catch {
                    $failedResources += "Bastion: $($resource.name) - $($_.Exception.Message)"
                }
            }
        }

        default {
            Log "UNHANDLED: Resource '$($resource.name)' of type '$($resource.type)' not supported."
            $skippedResources += "$($resource.type): $($resource.name)"
        }
    }
}

# ========= Report =========
$summary = @()
if ($deletedResources.Count -gt 0) { $summary += "**Deleted:**`n- " + ($deletedResources -join "`n- ") }
if ($failedResources.Count  -gt 0) { $summary += "**Failed:**`n- "  + ($failedResources  -join "`n- ") }
if ($skippedResources.Count -gt 0) { $summary += "**Skipped:**`n- " + ($skippedResources -join "`n- ") }

$summaryText = if ($summary.Count -eq 0) { "No resources were processed." } else { $summary -join "`n`n" }

Send-TeamsMessage -WebhookUrl $teamsWebhookUrl `
    -Title "Azure Cleanup Execution Report" `
    -Message $summaryText `
    -Color ($(if ($failedResources.Count -gt 0) {"FF0000"} else {"00FF00"}))
