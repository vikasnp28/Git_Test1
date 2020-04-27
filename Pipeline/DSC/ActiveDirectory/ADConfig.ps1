Configuration ADConfig
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xActiveDirectory -ModuleVersion 3.0.0.0
    #Import-DscResource -ModuleName xReleaseManagement -ModuleVersion 1.0.0.0
    Import-DscResource -ModuleName NetworkingDsc -ModuleVersion 7.3.0.0

    #Custom Resources
    Import-DscResource -ModuleName DXC_BuildAutomationCommonDsc
    Import-DscResource -ModuleName DXC_SecuritySWInstallDsc
    
    $DomainAdministratorCredential = Get-AutomationPSCredential -Name 'ADConfigCreds'
    $SafemodeAdministratorPassword = Get-AutomationPSCredential -Name 'ADConfigCreds'
    
    Node ($AllNodes.Where{$_.Role -eq 'DC'}).NodeName
    {
        File SourcesFolder
        {
            DestinationPath = $Node.SourcesFolderPath
            Ensure = $Node.SourcesFolderEnsureString
            Type = $Node.SourcesFolderType
        }

        #Download Security Related Software
        ArtifactoryDownload DownloadArtifactory
        {
            UniqueName              = 'DownloadArtifactory' 
            DownloadZipPath         = $Node.DownloadPath 
            ArtifactoryFiles        = $Node.ArtifactoryArray 
            ArtifactoryAccessKey    = $Node.ArtifactoryKey
            ArtifactoryRepoURL      = $Node.ArtifactoryURL
            DependsOn               = '[File]SourcesFolder'
        }

        Archive CrowdStrikeFalconWindowsSensorFileZipExtract
        {
            Destination = ($Node.SourcesFolderPath + '\')
            Path = ($Node.DownloadPath + '\' + $Node.CrowdStrikeFalconWindowsSensorZip)
            Ensure = $Node.ExtractEnsureString
            Force = $Node.ExtractForce
            DependsOn = '[ArtifactoryDownload]DownloadArtifactory'
        }

        CrowdStrikeInstall InstallCrowdStrikeFalconWindowsSensor
        {
            CrowdStrikeInstallFilename = ($Node.CrowdStrikeFalconWindowsSensorFile)
            CrowdStrikeInstallFolder = ($Node.SourcesFolderPath + '\' + 'CrowdStrikeFalconWindowsSensor')
            CrowdStrikeInstallArguments = $Node.CrowdStrikeFalconWindowsSensorArgs

            DependsOn = '[Archive]CrowdStrikeFalconWindowsSensorFileZipExtract'
        }

        Archive McAfeeFileZipExtract
        {
            Destination = ($Node.SourcesFolderPath + '\')
            Path = ($Node.DownloadPath + '\' + $Node.McAfeeZip)
            Ensure = $Node.ExtractEnsureString
            Force = $Node.ExtractForce
            DependsOn = '[ArtifactoryDownload]DownloadArtifactory'
        }

        McAfeeInstall InstallMcAfee
        {
            McAfeeInstallFilename = $Node.McAfeeFile 
            McAfeeInstallFolder = ($Node.SourcesFolderPath + '\McAfee\')
            McAfeeInstallArguments = $Node.McAfeeArguments

            DependsOn = '[Archive]McAfeeFileZipExtract'
        }

        WindowsFeatureSet InstallADRoles
        {
            Name = $Node.FeatureNames
            Ensure = $Node.EnsureString
            IncludeAllSubFeature = $Node.IncludeAllSubFeatureChoice
        }

        xADDomain InstallFirstDomain
        {
            DomainAdministratorCredential = $DomainAdministratorCredential
            DomainName = $Node.DomainName
            SafemodeAdministratorPassword = $SafemodeAdministratorPassword
            DatabasePath = $Node.DBAndLogPath
            DependsOn = '[WindowsFeatureSet]InstallADRoles'
            DomainMode = $Node.DomainAndForestMode
            DomainNetbiosName = $Node.DomainNetbiosName
            ForestMode = $Node.DomainAndForestMode
            LogPath = $Node.DBAndLogPath
            SysvolPath = $Node.SysvolPath
        }

        xWaitForADDomain WaitForADDomainOnDC
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $DomainAdministratorCredential
            RebootRetryCount = $Node.RebootRetryCountDC
            RetryCount = $Node.RetryCountDC
            RetryIntervalSec = $Node.RetryIntervalSecDC
            DependsOn = '[xADDomain]InstallFirstDomain'
        }

        DnsServerAddress SetDNSServerAddress
        {
            AddressFamily = $Node.DNSServerAddressFamily
            InterfaceAlias = $Node.DNSServerAddressInterfaceAlias
            Address = $Node.DNSServerAddress
            Validate = $Node.DNSServerAddressValidate
            DependsOn = '[xWaitForADDomain]WaitForADDomainOnDC'
        }

        @($Node.ServiceAccounts).ForEach({
            xADUser $_
            {
                DomainName = $Node.DomainName
                UserName = $_
                Password = $DomainAdministratorCredential
                Ensure = $Node.AccountsEnsureString
                #Path = ($ConfigurationData.AllNodes.AccountsOUPath + "," + 'DC={0},DC={1}' -f ($ConfigurationData.AllNodes.DomainName.split('.')[0]), ($ConfigurationData.AllNodes.DomainName.split('.')[1]))
                Enabled = $Node.AccountsEnabled
                PasswordNeverExpires = $Node.AccountsPasswordNeverExpires
                CannotChangePassword = $Node.AccountsPasswordCannotChange
                PasswordNeverResets = $Node.AccountsPasswordNeverResets
                DependsOn = '[DnsServerAddress]SetDNSServerAddress'
            }
        })

        xADGroup RoleDGroup
        {
            GroupName = "Perm-D-DIL-LocalAdmin-SCO"
            #Path = ($Node.RolesOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = $null
            Ensure = $Node.GroupEnsureString
            DependsOn = '[DnsServerAddress]SetDNSServerAddress'
        } 
<#
        Archive IEMFileZipExtract
        {
            Destination = ($Node.SourcesFolderPath + '\')
            Path = ($Node.DownloadPath + '\' + $Node.IEMResourceClientZip)
            Ensure = $Node.ExtractEnsureString
            Force = $Node.ExtractForce
            DependsOn = '[ArtifactoryDownload]DownloadArtifactory'
        }

        xTokenize IEMCFGTokenize
        {
            path = $Node.IEMCFGSourcePath
            tokens = @{Relay_Control_RootServer="$($Node.IEMRelayControlRootServer)";Relay_Control_Server1="$($Node.IEMRelayControlServer1)";Relay_Control_Server2="$($Node.IEMRelayControlServer2)";RelayServer1="$($Node.IEMRelayServer1)";RelayServer2="$($Node.IEMRelayServer2)";RelaySelect_Automatic="$($Node.IEMRelaySelectAutomatic)";BESClient_ActionManager_SkipVoluntaryOnForceShutdown="$($Node.BESCliActMgrSkipVolOnForShut)";CSC_CUSTOMER_ID="$($Node.IEMCSCCustomerID)";CSC_ENVIRONMENT="$($Node.IEMCSCEnvironment)";CSC_FLEXERA_MGSFT_DOMAIN_NAME="$($Node.IEMCSCFlexeraMGSFTDomainName)";CSC_FLEXERA_MGSFT_BOOTSTRAP_DOWNLOAD="$($Node.IEMFlexeraMGSFTBootstrapDownload)"}
            useTokenFiles = $Node.IEMUseTokenFiles
            DependsOn = '[Archive]IEMFileZipExtract'
        }

        File IEMCFGFileCopy
        {
            DestinationPath = $Node.IEMCFGDestinationPath
            SourcePath = $Node.IEMCFGSourcePath
            Checksum = $Node.IEMCFGChecksum
            Ensure = $Node.IEMCFGDestinationEnsureString
            Force = $Node.IEMCFGDestinationForce
            Type = $Node.IEMCFGType
            MatchSource = $Node.IEMCFGMatchSource
            DependsOn = '[xTokenize]IEMCFGTokenize'
        }

        xTokenize IEMAFXMTokenize
        {
            path = $Node.IEMAFXMPath
            tokens = @{Fixlet_Site_Gather_URL="$($Node.IEMFixletSiteGatherURL)";Fixlet_Site_Report_URL="$($Node.IEMFixletSiteReportURL)";Fixlet_Site_Registration_URL="$($Node.IEMFixletSiteRegistrationURL)";BES_Mirror_Gather_URL="$($Node.IEMBESMirrorGatherURL)";BES_Mirror_Download_URL="$($Node.IEMBESMirrorDownloadURL)"}
            useTokenFiles = $Node.IEMUseTokenFiles
            DependsOn = '[Archive]IEMFileZipExtract'
        }
        
        Package InstallIEM
        {
            Name = $Node.IEMResourceClientFile
            Path = ($Node.SourcesFolderPath + '\' + 'IEMResource_Client' + '\' + $Node.IEMResourceClientFile)
            ProductId = $Node.IEMProductID
            Arguments = $Node.IEMArguments
            Ensure = $Node.IEMInstallEnsureString
            DependsOn = '[Archive]IEMFileZipExtract','[xTokenize]IEMCFGTokenize','[File]IEMCFGFileCopy','[xTokenize]IEMAFXMTokenize'
        }

        @($ConfigurationData.AllNodes.ADSiteNames).ForEach({
            xADReplicationSite $_
            {
                Name = $_
                Ensure = $ConfigurationData.AllNodes.ADSiteEnsureString
                RenameDefaultFirstSiteName = $ConfigurationData.AllNodes.ADSiteRenameDefaultFirstSiteName
                DependsOn = '[DnsServerAddress]SetDNSServerAddress'
            }
        })

        xADReplicationSubnet ReplicationSubnet1
        {
            Name = ($Node.ADReplicationSubnetNames[0])
            Site = ($Node.ADSiteNames[0])
            Ensure = $Node.ADReplicationSubnetEnsureString
            Location = ($Node.ADReplicationSubnetLocations[0])
            DependsOn = '[DnsServerAddress]SetDNSServerAddress'
        }
        
        @($ConfigurationData.AllNodes.TopLevelOUs).ForEach({
            xADOrganizationalUnit $_
            {
                Name = ($_ -replace '-')
                Path = ('DC={0},DC={1}' -f ($ConfigurationData.AllNodes.DomainName -split '\.')[0], ($ConfigurationData.AllNodes.DomainName -split '\.')[1])
                ProtectedFromAccidentalDeletion = $ConfigurationData.AllNodes.ProtectedFromAccidentalDeletion
                Ensure = $ConfigurationData.AllNodes.OUEnsureString
                DependsOn = '[DnsServerAddress]SetDNSServerAddress'
            }
        })

        @($ConfigurationData.AllNodes.UnderAdministrationOUs).ForEach({
            xADOrganizationalUnit $_
            {
                Name = ($_ -replace '-')
                Path = ($ConfigurationData.AllNodes.UnderAdministrationOUPath + "," + 'DC={0},DC={1}' -f ($ConfigurationData.AllNodes.DomainName.split('.')[0]), ($ConfigurationData.AllNodes.DomainName.split('.')[1]))
                ProtectedFromAccidentalDeletion = $ConfigurationData.AllNodes.ProtectedFromAccidentalDeletion
                Ensure = $ConfigurationData.AllNodes.OUEnsureString
                DependsOn = '[DnsServerAddress]SetDNSServerAddress'
            }
        })

        @($ConfigurationData.AllNodes.UnderCustomerOUs).ForEach({
            xADOrganizationalUnit $_
            {
                Name = ($_ -replace '-')
                Path = ($ConfigurationData.AllNodes.UnderCustomerOUPath + "," + 'DC={0},DC={1}' -f ($ConfigurationData.AllNodes.DomainName.split('.')[0]), ($ConfigurationData.AllNodes.DomainName.split('.')[1]))
                ProtectedFromAccidentalDeletion = $ConfigurationData.AllNodes.ProtectedFromAccidentalDeletion
                Ensure = $ConfigurationData.AllNodes.OUEnsureString
                DependsOn = '[DnsServerAddress]SetDNSServerAddress'
            }
        })

        @($ConfigurationData.AllNodes.UnderApplicationGroupsOUs).ForEach({
            xADOrganizationalUnit $_
            {
                Name = ($_ -replace '-')
                Path = ($ConfigurationData.AllNodes.UnderApplicationGroupsOUPath + "," + 'DC={0},DC={1}' -f ($ConfigurationData.AllNodes.DomainName.split('.')[0]), ($ConfigurationData.AllNodes.DomainName.split('.')[1]))
                ProtectedFromAccidentalDeletion = $ConfigurationData.AllNodes.ProtectedFromAccidentalDeletion
                Ensure = $ConfigurationData.AllNodes.OUEnsureString
                DependsOn = '[DnsServerAddress]SetDNSServerAddress'
            }
        })
        
        @($ConfigurationData.AllNodes.UnderWorkstationsOUs).ForEach({
            xADOrganizationalUnit $_
            {
                Name = ($_ -replace '-')
                Path = ($ConfigurationData.AllNodes.UnderWorkstationsOUPath + "," + 'DC={0},DC={1}' -f ($ConfigurationData.AllNodes.DomainName.split('.')[0]), ($ConfigurationData.AllNodes.DomainName.split('.')[1]))
                ProtectedFromAccidentalDeletion = $ConfigurationData.AllNodes.ProtectedFromAccidentalDeletion
                Ensure = $ConfigurationData.AllNodes.OUEnsureString
                DependsOn = '[DnsServerAddress]SetDNSServerAddress'
            }
        })

        @($ConfigurationData.AllNodes.UnderServersOUs).ForEach({
            xADOrganizationalUnit $_
            {
                Name = ($_ -replace '-')
                Path = ($ConfigurationData.AllNodes.UnderServersOUPath + "," + 'DC={0},DC={1}' -f ($ConfigurationData.AllNodes.DomainName.split('.')[0]), ($ConfigurationData.AllNodes.DomainName.split('.')[1]))
                ProtectedFromAccidentalDeletion = $ConfigurationData.AllNodes.ProtectedFromAccidentalDeletion
                Ensure = $ConfigurationData.AllNodes.OUEnsureString
                DependsOn = '[DnsServerAddress]SetDNSServerAddress'
            }
        })

        @($ConfigurationData.AllNodes.UnderPCDevicesOUs).ForEach({
            xADOrganizationalUnit $_
            {
                Name = ($_ -replace '-')
                Path = ($ConfigurationData.AllNodes.UnderPCDevicesOUPath + "," + 'DC={0},DC={1}' -f ($ConfigurationData.AllNodes.DomainName.split('.')[0]), ($ConfigurationData.AllNodes.DomainName.split('.')[1]))
                ProtectedFromAccidentalDeletion = $ConfigurationData.AllNodes.ProtectedFromAccidentalDeletion
                Ensure = $ConfigurationData.AllNodes.OUEnsureString
                DependsOn = '[DnsServerAddress]SetDNSServerAddress'
            }
        })
        
        @($ConfigurationData.AllNodes.UnderVDSOUs).ForEach({
            xADOrganizationalUnit $_
            {
                Name = ($_ -replace '-')
                Path = ($ConfigurationData.AllNodes.UnderVDSOUPath + "," + 'DC={0},DC={1}' -f ($ConfigurationData.AllNodes.DomainName.split('.')[0]), ($ConfigurationData.AllNodes.DomainName.split('.')[1]))
                ProtectedFromAccidentalDeletion = $ConfigurationData.AllNodes.ProtectedFromAccidentalDeletion
                Ensure = $ConfigurationData.AllNodes.OUEnsureString
                DependsOn = '[DnsServerAddress]SetDNSServerAddress'
            }
        })

        @($ConfigurationData.AllNodes.ServiceAccounts).ForEach({
            xADUser $_
            {
                DomainName = $ConfigurationData.AllNodes.DomainName
                UserName = $_
                Password = $DomainAdministratorCredential
                Ensure = $ConfigurationData.AllNodes.AccountsEnsureString
                Path = ($ConfigurationData.AllNodes.AccountsOUPath + "," + 'DC={0},DC={1}' -f ($ConfigurationData.AllNodes.DomainName.split('.')[0]), ($ConfigurationData.AllNodes.DomainName.split('.')[1]))
                Enabled = $ConfigurationData.AllNodes.AccountsEnabled
                PasswordNeverExpires = $ConfigurationData.AllNodes.AccountsPasswordNeverExpires
                CannotChangePassword = $ConfigurationData.AllNodes.AccountsPasswordCannotChange
                PasswordNeverResets = $ConfigurationData.AllNodes.AccountsPasswordNeverResets
                DependsOn = '[DnsServerAddress]SetDNSServerAddress'
            }
        })
        
        @($ConfigurationData.AllNodes.UserAccounts).ForEach({
            xADUser $_
            {
                DomainName = $ConfigurationData.AllNodes.DomainName
                UserName = $_
                Password = $DomainAdministratorCredential
                Ensure = $ConfigurationData.AllNodes.AccountsEnsureString
                Enabled = $ConfigurationData.AllNodes.AccountsEnabled
                PasswordNeverExpires = $ConfigurationData.AllNodes.AccountsPasswordNeverExpires
                CannotChangePassword = $ConfigurationData.AllNodes.AccountsPasswordCannotChange
                PasswordNeverResets = $ConfigurationData.AllNodes.AccountsPasswordNeverResets
                DependsOn = '[DnsServerAddress]SetDNSServerAddress'
            }
        })

        xADComputer ConfigMgrComputerObject
        {
            ComputerName = $Node.SCCMPrimaryHostName
            DnsHostName = ($Node.SCCMPrimaryHostName + '.' + $Node.DomainName)
            DomainController = ($Node.NodeName + '.' + $Node.DomainName)
            Enabled = $Node.CMComputerObjectEnabled
            Ensure = $Node.CMComputerObjectEnsureString
            Path = ($Node.CMComputerObjectPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            DependsOn = '[DnsServerAddress]SetDNSServerAddress'
        }

        xADComputer SQLServerComputerObject
        {
            ComputerName = $Node.SQLServerHostName
            DnsHostName = ($Node.SQLServerHostName + '.' + $Node.DomainName)
            DomainController = ($Node.NodeName + '.' + $Node.DomainName)
            Enabled = $Node.SQLComputerObjectEnabled
            Ensure = $Node.SQLComputerObjectEnsureString
            Path = ($Node.SQLComputerObjectPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            DependsOn = '[DnsServerAddress]SetDNSServerAddress'
        }

        xADGroup RoleDGroup
        {
            GroupName = ($Node.RoleDName1 + "-" + $Node.CustCode + "-" + $Node.RoleDName2)
            Path = ($Node.RolesOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.ServiceAccounts[0])
            Ensure = $Node.GroupEnsureString
            DependsOn = '[DnsServerAddress]SetDNSServerAddress'
        }     
        
        xADGroup RoleGGroup1
        {
            GroupName = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName2)
            Path = ($Node.RolesOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.ServiceAccounts[1])
            Ensure = $Node.GroupEnsureString
            DependsOn = '[DnsServerAddress]SetDNSServerAddress'
        }

        xADGroup RoleGGroup2
        {
            GroupName = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName3)
            Path = ($Node.RolesOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = $Node.UserAccounts.ForEach({$_})
            Ensure = $Node.GroupEnsureString
            DependsOn = '[DnsServerAddress]SetDNSServerAddress'
        }

        xADGroup RoleGGroup3
        {
            GroupName = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName4)
            Path = ($Node.RolesOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.UserAccounts[0]),($Node.UserAccounts[1]),($Node.UserAccounts[2]),($Node.ServiceAccounts[1]),($Node.ServiceAccounts[3]),($Node.ServiceAccounts[4])
            Ensure = $Node.GroupEnsureString
            DependsOn = '[DnsServerAddress]SetDNSServerAddress'
        }

        xADGroup RoleGGroup4
        {
            GroupName = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName5)
            Path = ($Node.RolesOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = $Node.UserAccounts.ForEach({$_})
            Ensure = $Node.GroupEnsureString
            DependsOn = '[DnsServerAddress]SetDNSServerAddress'
        }

        xADGroup RoleGGroup5
        {
            GroupName = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName6)
            Path = ($Node.RolesOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = $Node.UserAccounts.ForEach({$_})
            Ensure = $Node.GroupEnsureString
            DependsOn = '[DnsServerAddress]SetDNSServerAddress'
        }

        xADGroup RoleGGroup6
        {
            GroupName = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName7)
            Path = ($Node.RolesOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = $Node.UserAccounts.ForEach({$_})
            Ensure = $Node.GroupEnsureString
            DependsOn = '[DnsServerAddress]SetDNSServerAddress'
        }

        xADGroup RoleGGroup7
        {
            GroupName = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName8)
            Path = ($Node.RolesOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.ServiceAccounts[2])
            Ensure = $Node.GroupEnsureString
            DependsOn = '[DnsServerAddress]SetDNSServerAddress'
        }

        xADGroup RoleGGroup8
        {
            GroupName = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName9)
            Path = ($Node.RolesOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.ServiceAccounts[3])
            Ensure = $Node.GroupEnsureString
            DependsOn = '[DnsServerAddress]SetDNSServerAddress'
        }

        xADGroup RoleGGroup9
        {
            GroupName = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName10)
            Path = ($Node.RolesOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.ServiceAccounts[0])
            Ensure = $Node.GroupEnsureString
            DependsOn = '[DnsServerAddress]SetDNSServerAddress'
        }

        xADGroup RoleGGroup10
        {
            GroupName = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName11)
            Path = ($Node.RolesOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.ServiceAccounts[4])
            Ensure = $Node.GroupEnsureString
            DependsOn = '[DnsServerAddress]SetDNSServerAddress'
        }

        xADGroup RoleGGroup11
        {
            GroupName = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName12)
            Path = ($Node.RolesOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = $Node.UserAccounts.ForEach({$_})
            Ensure = $Node.GroupEnsureString
            DependsOn = '[DnsServerAddress]SetDNSServerAddress'
        }

        xADGroup RoleGGroup12
        {
            GroupName = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName13)
            Path = ($Node.RolesOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = $Node.UserAccounts.ForEach({$_})
            Ensure = $Node.GroupEnsureString
            DependsOn = '[DnsServerAddress]SetDNSServerAddress'
        }

        xADGroup RoleGGroup13
        {
            GroupName = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName14)
            Path = ($Node.RolesOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Ensure = $Node.GroupEnsureString
            DependsOn = '[DnsServerAddress]SetDNSServerAddress'
        }

        xADGroup RoleGGroup14
        {
            GroupName = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName15)
            Path = ($Node.RolesOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Ensure = $Node.GroupEnsureString
            DependsOn = '[DnsServerAddress]SetDNSServerAddress'
        }

        xADGroup BuiltInGroup1
        {
            GroupName = $Node.BuiltinName1
            Members = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName11),($Node.ServiceAccounts[4]),($Node.ServiceAccounts[5]),($Node.ServiceAccounts[6]),($Node.SCCMPrimaryHostName + '$')
            Ensure = $Node.GroupEnsureString
            DependsOn = '[xADGroup]RoleGGroup10','[xADComputer]ConfigMgrComputerObject'
        }

        xADGroup RoleUGroup
        {
            GroupName = ($Node.RoleUName1 + "-" + $Node.CustCode + "-" + $Node.RoleUName2)
            GroupScope = $Node.UniversalGroupScope
            Path = ($Node.RolesOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.SCCMPrimaryHostName + '$')
            Ensure = $Node.GroupEnsureString
            DependsOn = '[xADComputer]ConfigMgrComputerObject'
        }

        xADGroup ApplDGroup
        {
            GroupName = ($Node.ApplDName1 + "-" + $Node.CustCode + "-" + $Node.ApplDName2)
            Path = ($Node.EntitlementGroupsOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Ensure = $Node.GroupEnsureString
            DependsOn = '[DnsServerAddress]SetDNSServerAddress'
        }

        xADGroup DataDGroup1
        {
            GroupName = ($Node.DataDName1 + "-" + $Node.CustCode + "-" + $Node.SCCMPrimaryHostName + "_" + $Node.PrestageDriveLetter + "_" + $Node.DataDName2)
            GroupScope = $Node.DomainLocalGroupScope
            Path = ($Node.PermissionsOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName3),($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName9)
            Ensure = $Node.GroupEnsureString
            DependsOn = '[xADGroup]RoleGGroup2','[xADGroup]RoleGGroup8'
        }

        xADGroup DataDGroup2
        {
            GroupName = ($Node.DataDName1 + "-" + $Node.CustCode + "-" + $Node.DataDName3)
            GroupScope = $Node.DomainLocalGroupScope
            Path = ($Node.PermissionsOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName4),($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName11)
            Ensure = $Node.GroupEnsureString
            DependsOn = '[xADGroup]RoleGGroup3','[xADGroup]RoleGGroup10'
        }

        xADGroup DataDGroup3
        {
            GroupName = ($Node.DataDName1 + "-" + $Node.CustCode + "-" + $Node.DataDName4)
            GroupScope = $Node.DomainLocalGroupScope
            Path = ($Node.PermissionsOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName4)
            Ensure = $Node.GroupEnsureString
            DependsOn = '[xADGroup]RoleGGroup3'
        }

        xADGroup PermDGroup1
        {
            GroupName = ($Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName2)
            GroupScope = $Node.DomainLocalGroupScope
            Path = ($Node.PermissionsOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName4),($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName2),($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName9)
            Ensure = $Node.GroupEnsureString
            DependsOn = '[xADGroup]RoleGGroup3','[xADGroup]RoleGGroup1','[xADGroup]RoleGGroup8'
        }

        xADGroup PermDGroup2
        {
            GroupName = ($Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName3)
            GroupScope = $Node.DomainLocalGroupScope
            Path = ($Node.PermissionsOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.RoleUName1 + "-" + $Node.CustCode + "-" + $Node.RoleUName2)
            Ensure = $Node.GroupEnsureString
            DependsOn = '[xADGroup]RoleUGroup'
        }

        xADGroup PermDGroup3
        {
            GroupName = ($Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName4)
            GroupScope = $Node.DomainLocalGroupScope
            Path = ($Node.PermissionsOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.RoleDName1 + "-" + $Node.CustCode + "-" + $Node.RoleDName2),($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName3),($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName4),($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName9),($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName10),($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName14)
            Ensure = $Node.GroupEnsureString
            DependsOn = '[xADGroup]RoleDGroup','[xADGroup]RoleGGroup2','[xADGroup]RoleGGroup3','[xADGroup]RoleGGroup8','[xADGroup]RoleGGroup9','[xADGroup]RoleGGroup13'
        }

        xADGroup PermDGroup4
        {
            GroupName = ($Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName5)
            GroupScope = $Node.DomainLocalGroupScope
            Path = ($Node.PermissionsOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName3),($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName4),($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName9)
            Ensure = $Node.GroupEnsureString
            DependsOn = '[xADGroup]RoleGGroup2','[xADGroup]RoleGGroup3','[xADGroup]RoleGGroup8'
        }

        xADGroup PermDGroup5
        {
            GroupName = ($Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName6)
            GroupScope = $Node.DomainLocalGroupScope
            Path = ($Node.PermissionsOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName3),($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName4),($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName9)
            Ensure = $Node.GroupEnsureString
            DependsOn = '[xADGroup]RoleGGroup2','[xADGroup]RoleGGroup3','[xADGroup]RoleGGroup8'
        }

        xADGroup PermDGroup6
        {
            GroupName = ($Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName7)
            GroupScope = $Node.DomainLocalGroupScope
            Path = ($Node.PermissionsOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName4),($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName12),($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName9)
            Ensure = $Node.GroupEnsureString
            DependsOn = '[xADGroup]RoleGGroup3','[xADGroup]RoleGGroup11','[xADGroup]RoleGGroup8'
        }

        xADGroup PermDGroup7
        {
            GroupName = ($Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName8)
            GroupScope = $Node.DomainLocalGroupScope
            Path = ($Node.PermissionsOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName5)
            Ensure = $Node.GroupEnsureString
            DependsOn = '[xADGroup]RoleGGroup4'
        }

        xADGroup PermDGroup8
        {
            GroupName = ($Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName9)
            GroupScope = $Node.DomainLocalGroupScope
            Path = ($Node.PermissionsOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.RoleUName1 + "-" + $Node.CustCode + "-" + $Node.RoleUName2),($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName4),($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName9),($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName2),($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName15)
            Ensure = $Node.GroupEnsureString
            DependsOn = '[xADGroup]RoleUGroup','[xADGroup]RoleGGroup3','[xADGroup]RoleGGroup8','[xADGroup]RoleGGroup1','[xADGroup]RoleGGroup14'
        }

        xADGroup PermDGroup9
        {
            GroupName = ($Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName10)
            GroupScope = $Node.DomainLocalGroupScope
            Path = ($Node.PermissionsOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName6)
            Ensure = $Node.GroupEnsureString
            DependsOn = '[xADGroup]RoleGGroup5'
        }

        xADGroup PermDGroup10
        {
            GroupName = ($Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName11)
            GroupScope = $Node.DomainLocalGroupScope
            Path = ($Node.PermissionsOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName4),($Node.RoleUName1 + "-" + $Node.CustCode + "-" + $Node.RoleUName2)
            Ensure = $Node.GroupEnsureString
            DependsOn = '[xADGroup]RoleGGroup3','[xADGroup]RoleUGroup'
        }

        xADGroup PermDGroup11
        {
            GroupName = ($Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName12)
            GroupScope = $Node.DomainLocalGroupScope
            Path = ($Node.PermissionsOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName12)
            Ensure = $Node.GroupEnsureString
            DependsOn = '[xADGroup]RoleGGroup11'
        }

        xADGroup PermDGroup12
        {
            GroupName = ($Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName13)
            GroupScope = $Node.DomainLocalGroupScope
            Path = ($Node.PermissionsOUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            Members = ($Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName13)
            Ensure = $Node.GroupEnsureString
            DependsOn = '[xADGroup]RoleGGroup12'
        }

        Script CreateSystemManagementContainer
        {
            GetScript = 
            {
                Import-Module ActiveDirectory
                $Root = (Get-ADRootDSE).defaultNamingContext
                $Container = (Get-ADObject "CN=System Management,CN=System,$Root").Name
                return @{'Result' = "$Container"}
            }
            TestScript = 
            {
                Import-Module ActiveDirectory
                $Root = (Get-ADRootDSE).defaultNamingContext
                $Container = $Null
                Try
                {
                    $Container = (Get-ADObject "CN=System Management,CN=System,$Root").Name
                }
                Catch
                {
                    #Suppressing the exception error when AD Object is not found
                }
                
                If ($Container -eq "System Management")
                {
                    return $true
                }
                Else
                {
                    return $false
                }     
            }
            SetScript = 
            {
                Import-Module ActiveDirectory
                $Root = (Get-ADRootDSE).defaultNamingContext
                New-ADObject -Type Container -name "System Management" -Path "CN=System,$Root" -Passthru
            }
            DependsOn = '[DnsServerAddress]SetDNSServerAddress'
        }

        xADObjectPermissionEntry SystemManagementContainerPermissions
        {
            Ensure = $Node.SMCPermissionsEnsureString
            Path = ($Node.SMCPermissionsPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            IdentityReference = ($Node.DomainName + "\" + $Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName3)
            ActiveDirectoryRights = $Node.SMCPermissionsADRights
            AccessControlType = $Node.SMCPermissionsAccessControlType
            ObjectType = $Node.SMCPermissionsObjectType
            ActiveDirectorySecurityInheritance = $Node.SMCPermissionsADSecurityInheritance
            InheritedObjectType = $Node.SMCPermissionsInheritedObjectType
            DependsOn = '[Script]CreateSystemManagementContainer','[xADGroup]PermDGroup2'
        }

        xADObjectPermissionEntry PCDOUPermissions
        {
            Ensure = $Node.PCDPermissionsEnsureString
            Path = ($Node.PCDPermissionsPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            IdentityReference = ($Node.DomainName + "\" + $Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName4)
            ActiveDirectoryRights = $Node.PCDPermissionsADRights
            AccessControlType = $Node.PCDPermissionsAccessControlType
            ObjectType = $Node.PCDPermissionsObjectType
            ActiveDirectorySecurityInheritance = $Node.PCDPermissionsADSecurityInheritance
            InheritedObjectType = $Node.PCDPermissionsInheritedObjectType
            DependsOn = '[xADGroup]PermDGroup3'
        }

        xADObjectPermissionEntry HSOUPermissions
        {
            Ensure = $Node.HSPermissionsEnsureString
            Path = ($Node.HSPermissionsPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            IdentityReference = ($Node.DomainName + "\" + $Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName5)
            ActiveDirectoryRights = $Node.HSPermissionsADRights
            AccessControlType = $Node.HSPermissionsAccessControlType
            ObjectType = $Node.HSPermissionsObjectType
            ActiveDirectorySecurityInheritance = $Node.HSPermissionsADSecurityInheritance
            InheritedObjectType = $Node.HSPermissionsInheritedObjectType
            DependsOn = '[xADGroup]PermDGroup4'
        }

        xADObjectPermissionEntry VDSOUPermissions
        {
            Ensure = $Node.VDSPermissionsEnsureString
            Path = ($Node.VDSPermissionsPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            IdentityReference = ($Node.DomainName + "\" + $Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName6)
            ActiveDirectoryRights = $Node.VDSPermissionsADRights
            AccessControlType = $Node.VDSPermissionsAccessControlType
            ObjectType = $Node.VDSPermissionsObjectType
            ActiveDirectorySecurityInheritance = $Node.VDSPermissionsADSecurityInheritance
            InheritedObjectType = $Node.VDSPermissionsInheritedObjectType
            DependsOn = '[xADGroup]PermDGroup5'
        }

        xADObjectPermissionEntry WKSOUPermissions1
        {
            Ensure = $Node.WKSPermissionsEnsureString
            Path = ($Node.WKSPermissionsPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            IdentityReference = ($Node.DomainName + "\" + $Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName3)
            ActiveDirectoryRights = $Node.WKSPermissionsADRights
            AccessControlType = $Node.WKSPermissionsAccessControlType
            ObjectType = $Node.WKSPermissionsObjectType
            ActiveDirectorySecurityInheritance = $Node.WKSPermissionsADSecurityInheritance
            InheritedObjectType = $Node.WKSPermissionsInheritedObjectType
            DependsOn = '[xADGroup]RoleGGroup2'
        }

        xADObjectPermissionEntry WKSOUPermissions2
        {
            Ensure = $Node.WKSPermissionsEnsureString
            Path = ($Node.WKSPermissionsPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            IdentityReference = ($Node.DomainName + "\" + $Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName2)
            ActiveDirectoryRights = $Node.WKSPermissionsADRights
            AccessControlType = $Node.WKSPermissionsAccessControlType
            ObjectType = $Node.WKSPermissionsObjectType
            ActiveDirectorySecurityInheritance = $Node.WKSPermissionsADSecurityInheritance
            InheritedObjectType = $Node.WKSPermissionsInheritedObjectType
            DependsOn = '[xADGroup]PermDGroup1'
        }
        
        xADObjectPermissionEntry WKSOUPermissions3
        {
            Ensure = $Node.WKSPermissionsEnsureString
            Path = ($Node.WKSPermissionsPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            IdentityReference = ($Node.DomainName + "\" + $Node.RoleGName1 + "-" + $Node.CustCode + "-" + $Node.RoleGName10)
            ActiveDirectoryRights = $Node.WKSPermissionsADRights
            AccessControlType = $Node.WKSPermissionsAccessControlType
            ObjectType = $Node.WKSPermissionsObjectType
            ActiveDirectorySecurityInheritance = $Node.WKSPermissionsADSecurityInheritance
            InheritedObjectType = $Node.WKSPermissionsInheritedObjectType
            DependsOn = '[xADGroup]RoleGGroup9'
        }

        xADObjectPermissionEntry EGOUPermissions
        {
            Ensure = $Node.EGPermissionsEnsureString
            Path = ($Node.EGPermissionsPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            IdentityReference = ($Node.DomainName + "\" + $Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName7)
            ActiveDirectoryRights = $Node.EGPermissionsADRights
            AccessControlType = $Node.EGPermissionsAccessControlType
            ObjectType = $Node.EGPermissionsObjectType
            ActiveDirectorySecurityInheritance = $Node.EGPermissionsADSecurityInheritance
            InheritedObjectType = $Node.EGPermissionsInheritedObjectType
            DependsOn = '[xADGroup]PermDGroup6'
        }

        xADObjectPermissionEntry SCCMOUPermissions
        {
            Ensure = $Node.SCCMPermissionsEnsureString
            Path = ($Node.SCCMPermissionsPath + "," + 'DC={0},DC={1}' -f ($Node.DomainName.split('.')[0]), ($Node.DomainName.split('.')[1]))
            IdentityReference = ($Node.DomainName + "\" + $Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName9)
            ActiveDirectoryRights = $Node.SCCMPermissionsADRights
            AccessControlType = $Node.SCCMPermissionsAccessControlType
            ObjectType = $Node.SCCMPermissionsObjectType
            ActiveDirectorySecurityInheritance = $Node.SCCMPermsADSecurityInheritance
            InheritedObjectType = $Node.SCCMPermissionsInheritedObjectType
            DependsOn = '[xADGroup]PermDGroup8'
        }
                
        Archive SchemaFileZipExtract
        {
            Destination = ($Node.SourcesFolderPath + '\')
            Path = ($Node.DownloadPath + '\' + $Node.SchemaZip)
            Ensure = $Node.ExtractEnsureString
            Force = $Node.ExtractForce
            DependsOn = '[ArtifactoryDownload]DownloadArtifactory'
        }

        Archive VCRedistFileZipExtract
        {
            Destination = ($Node.SourcesFolderPath + '\')
            Path = ($Node.DownloadPath + '\' + $Node.VCRedistZip)
            Ensure = $Node.ExtractEnsureString
            Force = $Node.ExtractForce
            DependsOn = '[ArtifactoryDownload]DownloadArtifactory'
        }

        Package InstallVCRedist
        {
            Name = $Node.VCRedistFile
            Path = ($Node.SourcesFolderPath + '\' + $Node.VCRedistFile)
            ProductId = $Node.VCRedistProductID
            Arguments = $Node.VCRedistArguments
            Ensure = $Node.VCRedistInstallEnsureString
            DependsOn = '[Archive]VCRedistFileZipExtract'
        }
        
        Script SchemaExtend
        {
            GetScript = 
            {
                $Schema = [DirectoryServices.ActiveDirectory.ActiveDirectorySchema]::GetCurrentSchema()
                $Schema.RefreshSchema()
                return @{'Result' = $Schema}
            }
            TestScript = 
            {
                $Schema = $Null
                $Schema = [DirectoryServices.ActiveDirectory.ActiveDirectorySchema]::GetCurrentSchema()
                Try
                {
                    $GetSMSSchema = $Schema.FindClass("mSSMSSite")
                }
                Catch
                {
                    #Suppressing the exception error when Class is not found
                }
                If ($GetSMSSchema)
                {
                    return $true
                }
                Else
                {
                    return $false
                }
            }
            SetScript = 
            {
                Start-Process -FilePath ($Using:Node.SourcesFolderPath + '\' + $Using:Node.SchemaFile) -Wait
            }
            DependsOn = '[Archive]SchemaFileZipExtract'
        }

        Script MoveSchemaLog
        {
            GetScript = 
            {
                $Files = Get-ChildItem -Path $Using:Node.SourcesFolderPath -File $Using:Node.SchemaLogFileName
                return @{'Result' = $Files}
            }
            TestScript = 
            {
                $FileExists = $Null
                $FileExists = Test-Path -Path ($Using:Node.SourcesFolderPath + '\' + $Using:Node.SchemaLogFileName)
                return $FileExists
            }
            SetScript = 
            {
                Move-Item -Path 'C:\extadsch.log' -Destination $Using:Node.SourcesFolderPath -Force
            }
            DependsOn = '[Script]SchemaExtend'
        }

        xADServicePrincipalName SQLServicePrincipalName1
        {
            ServicePrincipalName = ($Node.SPNPrefix + '/' + $Node.SQLServerHostName + '.' + $Node.DomainName + ':' + $Node.SPN1 + $Node.CustCode + $Node.SPN1Suffix)
            Account = ($Node.ServiceAccounts[5])
            Ensure = $Node.SPNEnsureString
            DependsOn = '[xADComputer]SQLServerComputerObject'
        }

        xADServicePrincipalName SQLServicePrincipalName2
        {
            ServicePrincipalName = ($Node.SPNPrefix + '/' + $Node.SQLServerHostName + '.' + $Node.DomainName + ':' + $Node.SPN2 + $Node.CustCode + $Node.SPN2Suffix)
            Account = ($Node.ServiceAccounts[5])
            Ensure = $Node.SPNEnsureString
            DependsOn = '[xADComputer]SQLServerComputerObject'
        }

        xADServicePrincipalName SQLServicePrincipalName3
        {
            ServicePrincipalName = ($Node.SPNPrefix + '/' + $Node.SQLServerHostName + '.' + $Node.DomainName + ':' + $Node.SPN3 + $Node.CustCode + $Node.SPN3Suffix)
            Account = ($Node.ServiceAccounts[5])
            Ensure = $Node.SPNEnsureString
            DependsOn = '[xADComputer]SQLServerComputerObject'
        }

        xADServicePrincipalName SQLServicePrincipalName4
        {
            ServicePrincipalName = ($Node.SPNPrefix + '/' + $Node.SQLServerHostName + '.' + $Node.DomainName + ':' + $Node.SPN4)
            Account = ($Node.ServiceAccounts[5])
            Ensure = $Node.SPNEnsureString
            DependsOn = '[xADComputer]SQLServerComputerObject'
        }

        xADServicePrincipalName SQLServicePrincipalName5
        {
            ServicePrincipalName = ($Node.SPNPrefix + '/' + $Node.SQLServerHostName + '.' + $Node.DomainName + ':' + $Node.SPN5)
            Account = ($Node.ServiceAccounts[5])
            Ensure = $Node.SPNEnsureString
            DependsOn = '[xADComputer]SQLServerComputerObject'
        }

        xADServicePrincipalName SQLServicePrincipalName6
        {
            ServicePrincipalName = ($Node.SPNPrefix + '/' + $Node.SQLServerHostName + '.' + $Node.DomainName + ':' + $Node.SPN6)
            Account = ($Node.ServiceAccounts[5])
            Ensure = $Node.SPNEnsureString
            DependsOn = '[xADComputer]SQLServerComputerObject'
        }

        xADServicePrincipalName CMServicePrincipalName1
        {
            ServicePrincipalName = ($Node.SCCMPrimaryHostName + '/' + $Node.SCCMPrimaryHostName + '.' + $Node.DomainName)
            Account = ($Node.ServiceAccounts[4])
            Ensure = $Node.SPNEnsureString
            DependsOn = '[xADComputer]ConfigMgrComputerObject'
        }
#>        
    }
}