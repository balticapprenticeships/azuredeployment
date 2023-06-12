# BulkStopStart.ps1
# Chris Langford
#
# To download the Azure Resource Graph module to your machine ready for upload run the command below
# ensuring that the destination folder exists:
# Save-Module Az.ResourceGraph .\modules
# You can then zip it up and zip deploy into your function app
#
# This function definition must be placed in the profile.ps1 file and NOT the run.ps1
# also the az.resourcegraph needs to be uploaded into the modules child folder main function app
# restart the app after changes to dependencies and the upload
# at the start import the az.resourcegraph
import-module az.resourcegraph

# Past the executeActionCommand at the end of profile.ps1
function executeActionCommand
{
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(Mandatory=$true)]
        [String]
        $commandToRun,
        [Parameter(Mandatory=$true)]
        [String]
        $resourceName,
        [Parameter(Mandatory=$true)]
        [String]
        $resourceType,
        [Parameter(Mandatory=$true)]
        [String]
        $actionType
    )

    #Being very lazy
    if($actionType -eq 'Delete'){
        $outputBit = 'Delet'
    }
    elseif ($actionType -eq 'Start') {
        $outputBit = 'Start'
    }
    elseif ($actionType -eq 'Stop') {
        $outputBit = 'Stopp'
    }

    Write-Output "$($outputBit)ing $resourceType $resourceName"
    try {
        $commandBlock = [Scriptblock]::Create($commandToRun) #Need to make it a script block
        $status = & $commandBlock
        if(($status.StatusCode -ne 'Accepted') -and ($resourceType -eq 'VM'))   #would be Succeeded if not using NoWait against Status property when starting VM. AKS and VMSS are different and not checking currently
        {
            Write-Error "   * Error response $($outputBit)ing $resourceName - $($status.status)"
            Write-Output "   * Executing - $commandToRun"
            Write-Output "  * Status - $status"
        }
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Error "   * Error $($outputBit)ing $resourceType $resourceName"
        Write-Output $errorMessage
    }
}


$mode="Delete"

$delayPeriod = 180 #wait 2 minutes between schedule changes or whatever you need

if($mode -eq "Delete")
{
    #$sortMode = "desc"
    $deleting = $true
}
else
{
    #$sortMode = "asc"
    $deleting = $false
}

# Start, set 'where tagValue to StartDaily'. Stop set 'where tagValue to NoShedule' (look at updating this query to auto set the tagValue)
$query = @"
Resources
| where type in~ ('Microsoft.Compute/virtualMachines','microsoft.compute/virtualmachinescalesets','Microsoft.ContainerService/managedClusters','Microsoft.Network/virtualNetworks','Microsoft.Network/networkSecurityGroups')
| mv-expand tags
| extend tagKey = tostring(bag_keys(tags)[0])
| extend tagValue = tostring(tags[tagKey])
| where tagKey =~ 'CourseEndDay'
| extend courseEndDay = tagValue
| where tagValue =~ 'Thursday'
| project name, type, courseEndDay, resourceGroup, id
"@

#Find the resources
$resources = Search-AzGraph -Query $query
#Find the current courseEndDay
$deleteSchedule = $resources[0].courseEndDay

#Enumerate
foreach($resource in $resources)
{
    #If we are on a new courseEndDay batch
    if($resource.courseEndDay -ne $deleteSchedule)
    {
        Write-Output "Schedule $deleteSchedule -> $($resource.courseEndDay) so sleeping for $delayPeriod seconds"
        Start-Sleep($delayPeriod) #wait
        $deleteSchedule = $resource.courseEndDay #set as the new
    }

    #For each resource type
    switch ($resource.type) {
        'microsoft.compute/virtualmachines'
        {
            if($deleting) { 
                executeActionCommand "Remove-AzVM -Name $($resource.name) -ResourceGroupName $($resource.resourceGroup) -NoWait -ErrorAction Stop -Force" $resource.name "VM" "Delete"
            }
        }
        'microsoft.compute/virtualmachinescalesets'
        {
            $skipExecution=$false
            try {
                #Check if this VMSS is actually owned by AKS in which case we need to skip
                $vmssInfo = Get-AzVmss -VMScaleSetName $resource.name -ResourceGroupName $resource.resourceGroup -ErrorAction Stop

                if(($vmssInfo.VirtualMachineProfile.ExtensionProfile.Extensions.Type -contains "Compute.AKS.Linux.Billing") -or
                    ($vmssInfo.VirtualMachineProfile.ExtensionProfile.Extensions.Type -contains "Compute.AKS.Windows.Billing"))
                {
                    Write-Output "!! This VMSS is part of an AKS cluster and will be skipped. Action should be via the AKS resource"
                    $skipExecution=$true
                }
            }
            catch {
                $errorMessage = $_.Exception.Message
                Write-Error "   * Error getting VMSS information on $($resource.name)"
                Write-Output $errorMessage
            }

            if(!$skipExecution) {
                if($deleting) { 
                    executeActionCommand "Remove-AzVmss -VMScaleSetName $($resource.name) -ResourceGroupName $($resource.resourceGroup) -NoWait -ErrorAction Stop -Force" $resource.name 'VMSS' 'Delete'
                }
            }
        }
        'Microsoft.ContainerService/managedClusters'
        {
            if($deleting) { 
                executeActionCommand "Remove-AzAksCluster -Name $($resource.name) -ResourceGroupName $($resource.resourceGroup) -NoWait -ErrorAction Stop" $resource.name 'AKS' 'Delete' 
            }
        }
        'Microsoft.Network/networkSecurityGroups'
        {
            Start-Sleep($delayPeriod)
            $skipNsgDelete = $false
            try {
                # Check if the VMs have been deleted                
                $vmExists = Get-AzVM -ResourceGroupName $($resource.resourceGroup) | Where-Object {$_.Tags.CourseEndDay -ieq $deleteSchedule}
                if($vmExists){
                    Write-Output "VMs still present that match the delete schedule. Deletion will be skipped."
                    $skipNsgDelete = $true
                }                
            }
            catch {
                $errorMessage = $_.Exception.Message
                Write-Error "   * Error deleting Network Security Group. VMs present in resource group"
                Write-Output $errorMessage
            }
            if(!$skipNsgDelete){
                if($deleting){
                    executeActionCommand "Remove-AzNetworkSecurityGroup -Name $($resource.name) -ResourceGroupName $($resource.resourceGroup) -NoWait -ErrorAction Stop -Force" $resource.name 'NSG' 'Delete'
                }
            }
        }
        'Microsoft.Network/virtualNetwork'
        {
            Start-Sleep($delayPeriod)
            $skipVnetDelete = $false
            try {
                # Check if the VMs and NSG have been deleted                
                $vmExists = Get-AzVM -ResourceGroupName $($resource.resourceGroup) | Where-Object {$_.Tags.CourseEndDay -ieq $deleteSchedule}
                $nsgExists = Get-AzNetworkSecurityGroup -ResourceGroupName $($resource.resourceGroup) | Where-Object {$_.Tags.CourseEndDay -ieq $deleteSchedule}
                if(($vmExists) -or ($nsgExists)){
                    Write-Output "VMs or NSG still present that match the delete schedule. Deletion will be skipped."
                    $skipVnetDelete = $true
                }                
            }
            catch {
                $errorMessage = $_.Exception.Message
                Write-Error "   * Error deleting Virtual network. VMs or NSG still present in resource group"
                Write-Output $errorMessage
            }
            if(!$skipVnetDelete){
                if($deleting){
                    executeActionCommand "Remove-AzVirtualNetwork -Name $($resource.name) -ResourceGroupName $($resource.resourceGroup) -NoWait -ErrorAction Stop -Force" $resource.name 'VNET' 'Delete'
                }
            }
        }
        Default
        {
            Write-Output "Resource $($resource.name) of type $($resource.type) not handled"
        }
    }
}