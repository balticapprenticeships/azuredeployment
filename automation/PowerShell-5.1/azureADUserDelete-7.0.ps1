<#  
.SYNOPSIS  
  Connects to Azure and Azure AD user accounts that match the name filter 
  
.DESCRIPTION  
  This runbook connects to Azure and AzureAD user accounts with job titles that have substrings that match the parameter.
  All of the permissions and group memberships will be removed.
  An important option is to select whehter or not to allow the deletion of the user accounts from the recycle bin or to allow them to auto delete in 30 days.
  The Azure subscription that is assumed is the subscription that contains the Automation account that is running this runbook.
  The runbook will NOT remove the resource group that contains the Automation account that is running this runbook.
  
  REQUIRED AUTOMATION ASSETS 
     An Automation connection asset that contains the Azure service principal, by default named AzureRunAsConnection. 
  
.PARAMETER jobTitle  
  Required  
  Allows you to specify a job title to limit the the accounts to be removed. 
  Pass multiple name filters through a comma separated list.      
  The filter is not case sensitive and will match any resource group that contains the string.    
  
.PARAMETER removeFromRecyclebin
  Required
  Default is $false (accounts will be deleted in 30 days).  
  Execute the runbook to see which resource groups would be deleted but take no action.
  Run the runbook in preview mode first to see which resource groups would be removed.

.NOTES
   AUTHOR: Chris Langford 
   LASTEDIT: 03.04.2022
#>

param (   

    # Job title of users
    [Parameter(Mandatory=$true)]
    [string]
    $jobTitle
)

## Connect to Azure
"Please enable appropriate RBAC permissions to the system identity of this automation account. Otherwise, the runbook may fail..."

try {
    "Loggin in to Azure..."
    Connect-AzAccount -Identity
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}