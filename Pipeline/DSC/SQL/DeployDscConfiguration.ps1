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

 $VMname = "devwldsql001"
 $VMresourceGroup = "Automation"
 $VMlocation = "eastus2"
 $VMDesc = "SQL"

 $automationAccountName = "DSC-AzureAutomationAccount"
 $automationResourceGroupName = "Automation"
 $source = "C:\Projects\Github\Waldo\Dev-Studio-Waldo-MWS-FrW\Pipeline\DSC\$VMDesc\$($VMDesc)Install.ps1"
 $config = "C:\Projects\Github\Waldo\Dev-Studio-Waldo-MWS-FrW\Pipeline\DSC\$VMDesc\$($VMDesc)InstallConfigData.psd1"
 $configurationName = "$($VMDesc)Install"
 $configurationDescription = "Install and Configure $VMDesc"
 
 Import-AzAutomationDscConfiguration -ResourceGroupName $automationResourceGroupName -AutomationAccountName $automationAccountName -Description $configurationDescription -SourcePath $source -Force -Published -LogVerbose $true
 
 Start-AzAutomationDscCompilationJob -ResourceGroupName $automationResourceGroupName -AutomationAccountName $automationAccountName -ConfigurationName $configurationName  -ConfigurationData $(Import-PowerShellDataFile  -Path $config )
 
 $return = Get-AzAutomationDscCompilationJob -ResourceGroupName $automationResourceGroupName -AutomationAccountName $automationAccountName -ConfigurationName $configurationName 
 # status should return 'Completed'
 $return.Status
 
 <#
 
 Register-AzureRmAutomationDscNode -AzureVMName $VMname -NodeConfigurationName "$($configurationName).$($VMname)" -ConfigurationMode "ApplyAndAutocorrect" -ConfigurationModeFrequencyMins 15 -RefreshFrequencyMins 30 -RebootNodeIfNeeded $True -ActionAfterReboot "ContinueConfiguration" -AllowModuleOverwrite $True -AzureVMResourceGroup $VMresourceGroup -AzureVMLocation $VMlocation -ResourceGroupName $automationResourceGroupName -AutomationAccountName $automationAccountName
 
 Unregister-AzureRmAutomationDscNode -AutomationAccountName $automationAccountName -ResourceGroupName automationResourceGroupName -Id 064a8929-c98b-25e4-80hh-111ca86067j8
 
 Remove-AzAutomationDscNodeConfiguration -Name "$($configurationName).$($VMname)" -ResourceGroupName $automationResourceGroupName -AutomationAccountName $automationAccountName -Force -IgnoreNodeMappings
 
 Remove-AzAutomationDscConfiguration -Name $configurationName -ResourceGroupName $automationResourceGroupName -AutomationAccountName $automationAccountName -Force
 
 #>
 
 $node = Get-AzAutomationDscNode -ResourceGroupName $VMresourceGroup -Name $VMname -AutomationAccountName $automationAccountName | ? { $_.Name -eq $VMname }

Set-AzAutomationDscNode -ResourceGroupName $VMresourceGroup -AutomationAccountName $automationAccountName -Id $node.Id -NodeConfigurationName "$configurationName.$VMname" -Force
 