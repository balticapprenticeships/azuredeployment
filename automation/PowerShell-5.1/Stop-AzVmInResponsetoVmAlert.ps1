[OutputType("PSAzureOperationResponse")]
param(
    [Parameter(Mandatory=$false)]
    [object] $webhookData
)
$ErrorActionPreference = "stop"

if ($webhookData)
{
    # Get the data object from the WebhookData
    $webhookData = (ConvertFrom-Json -InputObject $webhookData.RequestBody)

    # Get the info needed to identify the VM (depends on the payload schema)
    $schemaId = $webhookBody.$schemaId
    Write-Verbose "schemaId: $schemaId" -Verbose
    if ($schemaId -eq "azureMonitorCommonAlertSchema"){
        # This is the common Metric Alert Schema (released March 2019)
        $essentials = [object] ($webhookBody.data).essentials
        # Get the first target only as the script doesn't handle multiple
        $alertTargetIdArray = (($essentials.$alertTargetIds)[0]).Split("/")
        $subId = ($alertTargetIdArray)[2]
        $resourceGroupName = ($alertTargetIdArray)[4]
        $resourceType = ($alertTargetIdArray)[6] + "/" + ($alertTargetIdArray)[7]
        $resourceName = ($alertTargetIdArray)[-1]
        $status = $essentials.monitorCondition
    }
    elseif ($schemaId -eq "AzureMonitorMetricAlert") {
        # This is the near-real-time Metric Alert Schema
        $alertContext = [object] ($webhookBody.data).context
        $subId = $alertContext.subscriptionId
        $resourceGroupName = $alertContext.resourceGroupName
        $resourceType = $alertContext.resourceType
        $resourceName = $alertContext.resourceName
        $status = ($webhookBody.data).status
    }
    elseif ($schemaId -eq "Microsoft.Insights/activityLogs") {
        # This is the Activity Log Alert schema
        $alertContext = [object] (($webhookBody.data).context).activityLog
        $subId = $alertContext.subscriptionId
        $resourceGroupName = $alertContext.resourceGroupName
        $resourceType = $alertContext.resourceType
        $resourceName = (($alertContext.resourceId).Split("/"))[-1]
        $status = ($webhookBody.data).status
    }
    elseif ($schemaId -eq $null) {
        ## This is the original Metric Alert schema
        $alertContext = [object] $webhookBody.context
        $subId = $alertContext.subscriptionId
        $resourceGroupName = $alertContext.resourceGroupName
        $resourceType = $alertContext.resourceType
        $resourceName = $alertContext.resourceName
        $status = $webhookBody.status
    }
    else {
        # Schema not supported
        Write-Error "The alert data schema - $schemaId - is not supported."
    }

    Write-Verbose "status: $status" -Verbose
    if (($status -eq "Activated") -or ($status -eq "Fired"))
    {
        Write-Verbose "ResourceType: $resourceType" -Verbose
        Write-Verbose "ResourceName: $resourceName" -Verbose
        Write-Verbose "ResourceGroupName: $resourceGroupName" -Verbose
        Write-Verbose "SubscriptionId: $subId" -Verbose

        # Determine code path depending on the resourceType
        if ($resourceType -eq "Microsoft.Compute/virtualMachines")
        {
            # This is a Resource Manager VM
            Write-Verbose "This is a Resource Manager VM." -Verbose

            # Ensures you do not inherit an AzContext in your runbook
            Disable-AzContextAutosave -Scope Process

            # Connect to Azure with system-assigned managed identity
            $azureContext = (Connect-AzAccount -Identity).context

            # Set and Store context
            $azureContext = Set-AzContext -SubscriptionName $azureContext.Subscription -DefaultProfile $azureContext

            # Stop the Resource Manager VM
            $idleTag = (Get-AzResource -ResourceType "Microsoft.Compute/virtualMachines" -TagName "Idle").Tags.Values
            if ($idleTag -eq "Yes")
            {
                Write-Verbose "Stopping the VM - $resourceName - in the resource group - $resourceGroupName -" -Verbose
                Stop-AzVM -Name $resourceName -ResourceGroupName $resourceGroupName -DefaultProfile $azureContext -Force
                # [OutputType("PSAzureOperationResponse")]
            }
        }
        else {
            # ResourceType not supported
            Write-Error "$resourceType is not a supported resource type for this runbook."
        }
    }
    else {
        # The alert status was not 'Activated' or 'Fired' so no action taken
        Write-Verbose ("No action taken. Alert status: " + $status) -Verbose
    }
}
else {
    # Error
    Write-Error "This runbook is meant to be started from an Azure alert webhook only."
}