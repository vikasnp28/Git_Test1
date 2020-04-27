
<#
    Use this script to create the Azure Credentials required by SFS.
    The same password is used for all credentials.
#>
function CreateAzureCredential
{
    Param (
        $domain,
        $automationAccountName,
        $automationResourceGroupName,
        $CredentialName,
        $CredentialUsername,
        $CredentialPassword,
        $CredentialDescription)

    if($domain -eq "")
    {
        $user = "$($CredentialUsername)"        
    }
    else 
    {
        $user = "$($domain)\$($CredentialUsername)"        
    }
    $pw = ConvertTo-SecureString $CredentialPassword -AsPlainText -Force
    $Credential = New-Object –TypeName System.Management.Automation.PSCredential –ArgumentList $user, $pw

    if($null -ne (Get-AzAutomationCredential -AutomationAccountName $automationAccountName -Name $CredentialName -ResourceGroupName $automationResourceGroupName))
    {
        Remove-AzAutomationCredential -AutomationAccountName $automationAccountName -Name $CredentialName -ResourceGroupName $automationResourceGroupName
    }
    New-AzAutomationCredential -AutomationAccountName $automationAccountName -Name $CredentialName -Value $Credential -ResourceGroupName $automationResourceGroupName -Description $CredentialDescription
}

$CredentialPassword = "" # <===== enter pwd here and DO NOT COMMIT to GitHub with the password.

$domain = "mws"
$automationAccountName = "DSC-AzureAutomationAccount"
$automationResourceGroupName = "Automation"

$CredentialName = "SQLServiceAccountCreds"
$CredentialUsername = "z-da-csccm-sql-svc"
$CredentialDescription = "SQL service domain service account"

CreateAzureCredential $domain $automationAccountName $automationResourceGroupName $CredentialName $CredentialUsername $CredentialPassword $CredentialDescription

$CredentialName = "SQLAgentAccountCreds"
$CredentialUsername = "z-da-csccm-sql-agent"
$CredentialDescription = "SQL agent domain service account"

CreateAzureCredential $domain $automationAccountName $automationResourceGroupName $CredentialName $CredentialUsername $CredentialPassword $CredentialDescription

$CredentialName = "SQLRSAccountCreds"
$CredentialUsername = "z-da-csccm-sqlssrs"
$CredentialDescription = "SQL SSRS domain service account"

CreateAzureCredential $domain $automationAccountName $automationResourceGroupName $CredentialName $CredentialUsername $CredentialPassword $CredentialDescription

$CredentialName = "ADConfigCreds"
$CredentialUsername = "LabAdmin"
$CredentialDescription = ""

CreateAzureCredential "" $automationAccountName $automationResourceGroupName $CredentialName $CredentialUsername $CredentialPassword $CredentialDescription

$CredentialName = "DomainJoinCreds"
$CredentialUsername = "LabAdmin"
$CredentialDescription = "Used to join computer to domain"

CreateAzureCredential $domain $automationAccountName $automationResourceGroupName $CredentialName $CredentialUsername $CredentialPassword $CredentialDescription

