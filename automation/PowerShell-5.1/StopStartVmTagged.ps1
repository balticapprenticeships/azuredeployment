## Parameters
param(
    [Parameter(Mandatory=$true)]
    [string]
    $action,

    [Parameter(Mandatory=$true)]
    [string]
    $tagName,

    [Parameter(Mandatory=$true)]
    [string]
    $tagValue
)

## Authentication
try {
    Write-Output "Connecting to Azure"
    Connect-AzAccount -Identity
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}
## Get the VMs
Write-Output "Getting all virtual machines from resource group with the tag of $tagValue"

try {
    if ($tagName) {
        $instances = Get-AzResource -TagName $tagName -TagValue $tagValue -ResourceType "Microsoft.Compute/virtualMachines"

        if ($instances) {
            foreach ($instance in $instances) {
                $instancePowerState = (((Get-AzVM -ResourceGroupName $($instance.ResourceGroupName) -Name $($instance.Name) -Status).Statuses.Code[1]) -replace "PowerState/", "")
            }
        } else {
            # Do nothing
        }
    }else {
        $instances = Get-AzResource -ResourceType "Microsoft.Compute/virtualMachines"
        
        if($instances) {
            foreach($instance in $instances){
                $instancePowerState = (((Get-AzVM -ResourceGroupName $($instance.ResourceGroupName) -Name $($instance.Name) -Status).Statuses.Code[1]) -replace "PowerState/", "")

                $instanceState = ([System.Threading.Thread]::CurrentThread.CurrentCulture.TextInfo.ToTitleCase($instancePowerState))
            }
        }else {
            # Do nothing
        }
    }
}
catch {
    Write-Output -Message $-.Exception
    throw $_.Exception
}
## Start VMs
$runningInstance = ($resource)
## Stop VMs