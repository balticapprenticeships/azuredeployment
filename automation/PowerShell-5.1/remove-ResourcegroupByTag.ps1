<#PSScriptInfo

.VERSION 1.0.0

.GUID 28cf793b-4081-48c6-8da4-b5fdd0f09046

.AUTHOR Rob Goodridge

.COPYRIGHT (c) 2020 Rob Goodridge. All rights reserved.

.TAGS Azure Automation Azure Resource Group PowerShell Runbook DevOps Tag

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
1.0.1: - Add initial version
#>

<#
.SYNOPSIS
  Connects to Azure and removes resource groups that match the tag

.DESCRIPTION
  This runbook connects to Azure and removes resource groups with matching name and tag.
  All of the resources in each resource group are also removed.
  An important option is to run in preview mode to see which resource groups and resources will be removed without actually removing them.
  The Azure subscription that is assumed is the subscription that contains the Automation account that is running this runbook.
  The runbook will NOT remove the resource group that contains the Automation account that is running this runbook.

  REQUIRED AUTOMATION ASSETS
     An Automation connection asset that contains the Azure service principal, by default named AzureRunAsConnection.

.PARAMETER NameFilter
  Optional
  Allows you to specify a name filter to limit the resource groups that you will remove.
  Pass multiple name filters through a comma separated list.
  The filter is not case sensitive and will match any resource group

.PARAMETER Tag
  Optional
  Allows you to specify a single tag to limit the resource groups that you will remove.
  Specify as a key=value pair.
  The filter is not case sensitive and will match any resource group that is tagged.

.PARAMETER PreviewMode
  Optional, with default of $true (preview mode is on by default).
  Execute the runbook to see which resource groups would be deleted but take no action.
  Run the runbook in preview mode first to see which resource groups would be removed.

.NOTES
#>

#Requires -Modules Connect-AzureAutomation

workflow Remove-ResourceGroupByTag
{
    param (
        [parameter(Mandatory = $false)]
        [string] $NameFilter,

        [parameter(Mandatory = $false)]
        [string] $tag,

        [parameter(Mandatory = $false)]
        [bool] $PreviewMode = $true
    )

    $ErrorActionPreference = "Stop"
    $errorMessage = $null

    Connect-AzureAutomation

    if ( [string]::IsNullOrEmpty( $nameFilter ) -and  [string]::IsNullOrEmpty( $tag ) ) {
        throw ("Either NameFilter is required or a tags filter or both")
    }

    if ( -not [string]::IsNullOrEmpty( $tag ) ) {
        # Convert tags to a hastable
        Write-Output( "Only one tag must be entered")
        $Tags = [hashtable] (ConvertFrom-StringData ($tag))
        $tags
    }

    # Parse name filter list
    if ($NameFilter) {
        $nameFilterList = $NameFilter.Split(',')
        [regex]$nameFilterRegex = '(' + (($nameFilterList | foreach {[regex]::escape($_.ToLower())}) -join "|") + ')'
    }
    Write-Output( "PSPrivateMetadata")
    $PSPrivateMetadata

    $JobGuid = $PSPrivateMetadata.JobId.Guid
    Write-Output( "JobGuid")
    $JobGuid

    # Find the resource group that this Automation job is running in so that we can protect it from being removed
    if ( $JobGuid.Length -lt 5 ) {
        throw ("This is not running from the Automation service, so could not retrieve the resource group for the Automation account in order to protect it from being removed.")
    }
    else {
        $AutomationResource = Get-AzResource -ResourceType Microsoft.Automation/AutomationAccounts
        $KeepProcessing = $true
        foreach ($Automation in $AutomationResource) {
            if ( $KeepProcessing ) {
                # Loop through each Automation account to find this job
                $Job = Get-AzAutomationJob -ResourceGroupName $Automation.ResourceGroupName -AutomationAccountName $Automation.Name -Id $JobGuid -ErrorAction SilentlyContinue
                if (!([string]::IsNullOrEmpty($Job))) {
                    $thisResourceGroupName = $Job.ResourceGroupName
                    $KeepProcessing = $false
                }
            }
        }
    }

    Write-Output "Automation Job Resource Group = $thisResourceGroupName"

    # Process the resource groups
    try {
        # Find resource groups to remove based on passed in name filter
        $name_rg = @(Get-AzResourceGroup | `
                            ? { $nameFilterList.Count -eq 0 -or $_.ResourceGroupName.ToLower() -match $nameFilterRegex } )
        Write-Output("Name search resource groups...")
        $name_rg

        if ($tags.Count -gt 0 ) {
            Write-Output( "Get the resource groups that match the tag(s) $tags")
            $tag_rg = @(Get-AzResourceGroup  -Tag $Tags | select ResourceGroupName)
            $tag_rg

            if ( $name_rg.Count -gt 0 ) {
                Write-Output( "Find the intersection of the name search and tag search" )
                $groupsToRemove = $tag_rg | ? {$name_rg.resourcegroupname -contains $_.resourcegroupname}
            } else {
                $groupsToRemove = $tag_rg
            }
        } else {
            $groupsToRemove = $name_rg
        }

        # Assure the job resource group is not in the list
        if (!([string]::IsNullOrEmpty($thisResourceGroupName))) {
            Write-Output ("The resource group for this runbook job will not be removed.  Resource group: $thisResourceGroupName")
            $tempListOfGroups = @()
            foreach ($group in $groupsToRemove) {
                if ($($group.ResourceGroupName) -ne $thisResourceGroupName) {
                    # Add the group to a new list
                    $tempListOfGroups += $group
                }
            }
            $groupsToRemove = $tempListOfGroups
        }
        Write-Output( "Resource Groups which match the name search...")
        $groupsToRemove

        # No matching groups were found to remove
        if ($groupsToRemove.Count -eq 0) {
            Write-Output "No matching resource groups found."
        }
        # Matching groups were found to remove
        else
        {
            # In preview mode, so report what would be removed, but take no action.
            if ($PreviewMode -eq $true) {
                Write-Output "Preview Mode: The following resource groups would be removed:"
                foreach ($group in $groupsToRemove){
                    Write-Output $($group.ResourceGroupName)
                }
                Write-Output "Preview Mode: The following resources would be removed:"
                $resources = (Get-AzResource | foreach {$_} | Where-Object {$groupsToRemove.ResourceGroupName.Contains($_.ResourceGroupName)})
                foreach ($resource in $resources) {
                    Write-Output $resource
                }
            }
            # Remove the resource groups
            else {
                Write-Output "The following resource groups will be removed:"
                foreach ($group in $groupsToRemove){
                    Write-Output $($group.ResourceGroupName)
                }
                Write-Output "The following resources will be removed:"
                $resources = (Get-AzResource | foreach {$_} | Where-Object {$groupsToRemove.ResourceGroupName.Contains($_.ResourceGroupName)})
                foreach ($resource in $resources) {
                    Write-Output $resource
                }
                # Here is where the remove actions happen
                foreach -parallel ($resourceGroup in $groupsToRemove) {
                    Write-Output "Starting to remove resource group: $($resourceGroup.ResourceGroupName) ..."
                    Remove-AzResourceGroup -Name $($resourceGroup.ResourceGroupName) -Force
                    if ($null -eq (Get-AzResourceGroup -Name $($resourceGroup.ResourceGroupName) -ErrorAction SilentlyContinue) ) {
                        Write-Output "...successfully removed resource group: $($resourceGroup.ResourceGroupName)"
                    }
                }
            }
            Write-Output "Completed."
        }
    }
    catch {
        $errorMessage = $_
    }
    if ($errorMessage) {
        Write-Error $errorMessage
    }
}