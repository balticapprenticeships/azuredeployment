<#
.VERSION 1.0.0

.AUTHOR Chris Langford

.COPYRIGHT (c) 2023 Chris Langford. All rights reserved.

.TAGS Azure Automation Azure Resource Group PowerShell Runbook DevOps 

.SYNOPSIS  
  Connects to Azure and get the name and creation date of all VMs within the subscription
  
.DESCRIPTION  
  This runbook connects to Azure and get the name and creation date of all VMs in the subscription.
  
  REQUIRED AUTOMATION ASSETS 
   
  
.NOTES
   AUTHOR: Chris Langford 
   LASTEDIT: 20.01.23
#>

param(

)


"Please enable appropriate RBAC permissions to the system identity of this automation account. Otherwise, the runbook may fail..."
try {
    "logging in to Azure....."
    Connect-AzAccount -Identity
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

# Get the dateCreated usingthe the API
try {
    # $token = Get-AzAccessToken
    # $authHeader = @{
    #     'Content-Type'='application/json'
    #     'Authorization'='Bearer ' + $token.Token
    # }

    # $currentAzContext = Get-AzContext

    # $subId = $currentAzContext.Subscription.Id

    # $vmList = Invoke-RestMethod -Uri https://management.azure.com/subscriptions/$subId/providers/Microsoft.Compute/locations/ukwest/virtualMachines?api-version=2022-03-01 -Method GET -Headers $authHeader
    $vmList = Get-AzVM
    #$currentDate = Get-Date -Format F

    if($vmList){
        foreach($vm in $vmList){
            if(($vm.Tags.Cleanup -ieq 'Enabled') -and ($vm.timeCreated -lt (Get-Date).AddDays(-2))){
                Write-Output "VM $($vm.name) was created on $($vm.timeCreated) and will be deleted."
                Remove-AzVM -ForceDeletion
            }else{
                #do nothing
            }
        }
    }
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}