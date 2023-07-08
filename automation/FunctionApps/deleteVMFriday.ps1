$mode="Delete"

$delayPeriod = 180 

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

# Delete, set 'where tagValue to CourseEndDate'.
$query = @"
Resources
| where type in~ ('Microsoft.Compute/virtualMachines','microsoft.compute/virtualmachinescalesets','Microsoft.ContainerService/managedClusters')
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
#Find the courseEndDay
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
            if($deleting)
            { executeActionCommand "Remove-AzVM -Name $($resource.name) -ResourceGroupName $($resource.resourceGroup) -NoWait -ErrorAction Stop -Force" $resource.name "VM" "Delete"}
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

            if(!$skipExecution)
            {
                if($deleting)
                { executeActionCommand "Remove-AzVmss -VMScaleSetName $($resource.name) -ResourceGroupName $($resource.resourceGroup) -NoWait -ErrorAction Stop -Force" $resource.name 'VMSS' 'Delete'}
            }
        }
        'Microsoft.ContainerService/managedClusters'
        {
            if($deleting)
            #{ executeActionCommand "Remove-AzAksCluster -Name $($resource.name) -ResourceGroupName $($resource.resourceGroup) -NoWait -ErrorAction Stop" $resource.name 'AKS' 'Start' }
            #else
            { executeActionCommand "Remove-AzAksCluster -Name $($resource.name) -ResourceGroupName $($resource.resourceGroup) -NoWait -ErrorAction Stop" $resource.name 'AKS' 'Delete' }
        }
        Default
        {
            Write-Output "Resource $($resource.name) of type $($resource.type) not handled"
        }
    }
}