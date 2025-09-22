# CleanupRunbook.Tests.ps1
# Requires -Version 5.0
# Pester tests for the modularized Azure Cleanup Runbook (CleanupRunbook.ps1)

# Dot-source the runbook script so its functions are available
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. "$scriptDir\resourceGroupCleanupV6.ps1"

Describe "Azure Cleanup Runbook" {

  Context "Connect-Azure" {
    BeforeEach {
      # Capture log messages
      $logged = @()
      Mock -CommandName Write-Log -MockWith { param($msg) $logged += $msg }
      Mock -CommandName Connect-AzAccount -MockWith { }
    }

    It "calls Connect-AzAccount once" {
      Connect-Azure
      Assert-MockCalled -CommandName Connect-AzAccount -Times 1
    }

    It "logs a success message" {
      Connect-Azure
      $logged | Should -Match "Azure authentication succeeded"
    }
  }

  Context "Get-TargetVMs" {
    BeforeEach {
      Mock -CommandName Write-Log -MockWith { }
    }

    It "returns only VMs tagged Cleanup=Enabled" {
      $vm1 = [pscustomobject]@{ Name='vm1'; Tags=@{ Cleanup='Enabled' } }
      $vm2 = [pscustomobject]@{ Name='vm2'; Tags=@{ Cleanup='Disabled' } }
      Mock -CommandName Get-AzVM -MockWith { @($vm1, $vm2) }

      $result = Get-TargetVMs

      $result.Count | Should -Be 1
      $result[0].Name | Should -Be 'vm1'
    }
  }

  Context "Cleanup-VM" {
    BeforeEach {
      # Construct a fake VM object
      $vm = [pscustomobject]@{
        Name               = 'testvm'
        Id                 = '/subscriptions/000/resourceGroups/rg/providers/Microsoft.Compute/virtualMachines/testvm'
        ResourceGroupName  = 'rg'
        DiagnosticsProfile = [pscustomobject]@{ BootDiagnostics = [pscustomobject]@{ StorageUri = 'https://sa.blob.core.windows.net/' } }
        StorageProfile     = [pscustomobject]@{
          OsDisk    = [pscustomobject]@{ Name = 'osdisk'; ManagedBy = $null }
          DataDisks = @([pscustomobject]@{ Name = 'datadisk1'; ManagedBy = $null })
        }
      }

      # Mock all Az cmdlets and log
      Mock -CommandName Get-AzStorageAccount -MockWith { param($Name) [pscustomobject]@{ Name = $Name; Context = 'CTX' } }
      Mock -CommandName Remove-AzStorageContainer
      Mock -CommandName Remove-AzVM
      Mock -CommandName Get-AzNetworkInterface -MockWith { @() }
      Mock -CommandName Remove-AzPublicIpAddress
      Mock -CommandName Remove-AzNetworkInterface
      Mock -CommandName Get-AzDisk -MockWith { param($ResourceGroupName,$Name) [pscustomobject]@{ Name = $Name; ManagedBy = $null } }
      Mock -CommandName Remove-AzDisk
    }

    It "removes the boot diagnostics container" {
      Cleanup-VM -vm $vm
      Assert-MockCalled -CommandName Remove-AzStorageContainer -Times 1
    }

    It "deletes the VM" {
      Cleanup-VM -vm $vm
      Assert-MockCalled -CommandName Remove-AzVM -Times 1
    }

    It "removes unattached OS and data disks" {
      Cleanup-VM -vm $vm
      Assert-MockCalled -CommandName Remove-AzDisk -Times 2
    }
  }

  Context "Cleanup-VMsParallel" {
    BeforeEach {
      Mock -CommandName Write-Log -MockWith { }
      Mock -CommandName Cleanup-VM -MockWith { }
    }

    It "invokes Cleanup-VM for each VM in the list" {
      $vms = 1..3 | ForEach-Object { "vm$_" }
      Cleanup-VMsParallel -vmList $vms
      Assert-MockCalled -CommandName Cleanup-VM -Times 3
    }

    It "does not error when VM list is empty" {
      { Cleanup-VMsParallel -vmList @() } | Should -Not -Throw
    }
  }

  Context "Cleanup-NSGs" {
    BeforeEach {
      $nsg1 = [pscustomobject]@{ Name='nsg1'; ResourceGroupName='rg1'; Tags=@{ Cleanup='Enabled' } }
      $nsg2 = [pscustomobject]@{ Name='nsg2'; ResourceGroupName='rg2'; Tags=@{ Cleanup='Disabled' } }
      Mock -CommandName Get-AzNetworkSecurityGroup -MockWith { @($nsg1, $nsg2) }
      Mock -CommandName Remove-AzNetworkSecurityGroup
    }

    It "removes only NSGs tagged Cleanup=Enabled" {
      Cleanup-NSGs
      Assert-MockCalled -CommandName Remove-AzNetworkSecurityGroup `
                        -ParameterFilter { $Name -eq 'nsg1' -and $ResourceGroupName -eq 'rg1' } `
                        -Times 1

      Assert-MockCalled -CommandName Remove-AzNetworkSecurityGroup `
                        -ParameterFilter { $Name -eq 'nsg2' } `
                        -Times 0
    }
  }

  Context "Cleanup-VirtualNetworks" {
    BeforeEach {
      $sub1 = [pscustomobject]@{ Id='sub1'; Name='sub1' }
      $sub2 = [pscustomobject]@{ Id='sub2'; Name='sub2' }

      $vnet1 = [pscustomobject]@{
        Name               = 'vnet1'
        ResourceGroupName  = 'rg1'
        Subnets            = @($sub1)
        Tags               = @{ Cleanup = 'Enabled' }
      }
      $vnet2 = [pscustomobject]@{
        Name               = 'vnet2'
        ResourceGroupName  = 'rg2'
        Subnets            = @($sub2)
        Tags               = @{ Cleanup = 'Enabled' }
      }

      # vnet1: no NICs attached; vnet2: one NIC attached to subnet sub2
      $nicAttached = [pscustomobject]@{ 
        IpConfigurations = @([pscustomobject]@{ Subnet = [pscustomobject]@{ Id='sub2' } }) 
      }

      Mock -CommandName Get-AzVirtualNetwork -MockWith { @($vnet1, $vnet2) }
      Mock -CommandName Get-AzNetworkInterface -MockWith { @($nicAttached) }
      Mock -CommandName Remove-AzVirtualNetwork
    }

    It "deletes vNet when no subnets are in use" {
      Cleanup-VirtualNetworks
      Assert-MockCalled -CommandName Remove-AzVirtualNetwork `
                        -ParameterFilter { $Name -eq 'vnet1' -and $ResourceGroupName -eq 'rg1' } `
                        -Times 1
    }

    It "skips vNet when any subnet has attached NICs" {
      Cleanup-VirtualNetworks
      Assert-MockCalled -CommandName Remove-AzVirtualNetwork `
                        -ParameterFilter { $Name -eq 'vnet2' } `
                        -Times 0
    }
  }

  Context "Send-TeamsNotification" {
    BeforeEach {
      Mock -CommandName Invoke-RestMethod
      Mock -CommandName Write-Log -MockWith { }
    }

    It "sends a green success card with correct VM count and duration" {
      $start = (Get-Date).AddMinutes(-15)
      $end   = Get-Date
      Send-TeamsNotification -success $true `
                             -vmCount 5 `
                             -webhookUrl 'https://example.com/webhook' `
                             -startTime $start `
                             -endTime $end

      Assert-MockCalled -CommandName Invoke-RestMethod `
        -ParameterFilter {
          $Uri -eq 'https://example.com/webhook' -and
          $Method -eq 'Post' -and
          ($Body -like '*Processed 5 VMs*') -and
          ($Body -like '*00FF00*')
        } `
        -Times 1
    }

    It "sends a red failure card when success is false" {
      $start = (Get-Date).AddMinutes(-5)
      $end   = Get-Date
      Send-TeamsNotification -success $false `
                             -vmCount 2 `
                             -webhookUrl 'https://example.com/webhook' `
                             -startTime $start `
                             -endTime $end

      Assert-MockCalled -CommandName Invoke-RestMethod `
        -ParameterFilter {
          $Uri -eq 'https://example.com/webhook' -and
          $Method -eq 'Post' -and
          ($Body -like '*Processed 2 VMs*') -and
          ($Body -like '*FF0000*')
        } `
        -Times 1
    }
  }

}
