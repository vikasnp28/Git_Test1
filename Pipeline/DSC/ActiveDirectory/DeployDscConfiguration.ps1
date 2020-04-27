<#
    The commands below:
    - upload configuration
    - compile configuration
    - check status of compilation
    - register the DSC Node

    - unregister DSC Node (commented out)
    - unregister DSC Compilation (commented out)
    - unregister DSC Configuration (commented out)
 #>

 $VMname = "devwlddc001"
 $VMresourceGroup = "Automation"
 $VMlocation = "eastus2"
 
 $automationAccountName = "DSC-AzureAutomationAccount"
 $automationResourceGroupName = "Automation"
 $source = "C:\Projects\Github\Waldo\Dev-Studio-Waldo-MWS-FrW\Pipeline\DSC\ActiveDirectory\ADConfig.ps1"
 $config = "C:\Projects\Github\Waldo\Dev-Studio-Waldo-MWS-FrW\Pipeline\DSC\ActiveDirectory\ADConfigData.psd1"
 $configurationName = "ADConfig"
 $configurationDescription = "Install AD"
 
 Import-AzAutomationDscConfiguration -ResourceGroupName $automationResourceGroupName -AutomationAccountName $automationAccountName -Description $configurationDescription -SourcePath $source -Force -Published -LogVerbose $true

 Start-AzAutomationDscCompilationJob -ResourceGroupName $automationResourceGroupName -AutomationAccountName $automationAccountName -ConfigurationName $configurationName  -ConfigurationData $(Import-PowerShellDataFile  -Path $config )
 
 $return = Get-AzAutomationDscCompilationJob -ResourceGroupName $automationResourceGroupName -AutomationAccountName $automationAccountName -ConfigurationName $configurationName 
 # status should return 'Completed'
 $return.Status
 
<#

 Register-AzAutomationDscNode -AzureVMName $VMname -NodeConfigurationName "$($configurationName).$($VMname)" -ConfigurationMode "ApplyAndAutocorrect" -ConfigurationModeFrequencyMins 15 -RefreshFrequencyMins 30 -RebootNodeIfNeeded $True -ActionAfterReboot "ContinueConfiguration" -AllowModuleOverwrite $True -AzureVMResourceGroup $VMresourceGroup -AzureVMLocation $VMlocation -ResourceGroupName $automationResourceGroupName -AutomationAccountName $automationAccountName

 Unregister-AzAutomationDscNode -AutomationAccountName $automationAccountName -ResourceGroupName $automationResourceGroupName -Id 22c913a9-c2dd-11e9-a80e-000d3a7c43fb
 
 Remove-AzAutomationDscNodeConfiguration -Name "$($configurationName).$($VMname)" -ResourceGroupName $automationResourceGroupName -AutomationAccountName $automationAccountName -Force -IgnoreNodeMappings
 
 Remove-AzAutomationDscConfiguration -Name $configurationName -ResourceGroupName $automationResourceGroupName -AutomationAccountName $automationAccountName -Force
 
 #>
 
 $node = Get-AzAutomationDscNode -ResourceGroupName $VMresourceGroup -Name $VMname -AutomationAccountName $automationAccountName | ? { $_.Name -eq $VMname }

 Set-AzAutomationDscNode -ResourceGroupName $VMresourceGroup -AutomationAccountName $automationAccountName -Id $node.Id -NodeConfigurationName "$configurationName.$VMname" -Force
  