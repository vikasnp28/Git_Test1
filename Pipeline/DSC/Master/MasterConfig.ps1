Configuration MasterConfig
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    # Import-DscResource -ModuleName cNtfsAccessControl -ModuleVersion 1.4.1
    Import-DscResource -ModuleName xActiveDirectory -ModuleVersion 3.0.0.0
    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 6.4.0.0
    # Import-DscResource -ModuleName SecurityPolicyDsc -ModuleVersion 2.8.0.0
    Import-DscResource -ModuleName xReleaseManagement -ModuleVersion 1.0.0.0
    Import-DscResource -ModuleName NetworkingDsc -ModuleVersion 7.3.0.0

    #Custom Resources
    Import-DscResource -ModuleName DXC_BuildAutomationCommonDsc
    Import-DscResource -ModuleName DXC_SecuritySWInstallDsc
    
    $DomainJoinCredential = Get-AutomationPSCredential -Name 'DomainJoinCreds'

    Node ($AllNodes.Where{$_.Role -eq 'Master'}).NodeName
    {
        <#
        # Enable TLS 1.2 Server
        Registry EnableTLS12Server 
        {
            Ensure      = $Node.TLSServerEnsureString
            Key         = $Node.TLSServerKey
            ValueName   = $Node.TLSpropertyName
            ValueData   = $Node.TLSpropertyValue
            ValueType   = $Node.TLSpropertyType 
        }

        # Enable TLS 1.2 Client
        Registry EnableTLS12Client 
        {
            Ensure      = $Node.TLSClientEnsureString
            Key         = $Node.TLSClientKey
            ValueName   = $Node.TLSpropertyName
            ValueData   = $Node.TLSpropertyValue
            ValueType   = $Node.TLSpropertyType 
        }
        #>                      
        DnsServerAddress SetDNSServerAddress
        {
            AddressFamily = $Node.DNSServerAddressFamily
            InterfaceAlias = $Node.DNSServerAddressInterfaceAlias
            Address = $Node.DNSServerAddress
            Validate = $Node.DNSServerAddressValidate
        }

        File SourcesFolder
        {
            DestinationPath = $Node.SourcesFolderPath
            Ensure = $Node.SourcesFolderEnsureString
            Type = $Node.SourcesFolderType
        }

        # Download Artifactory Files
        ArtifactoryDownload SQLinstallationfiles
        {
            UniqueName              = 'SQLSoftware'
            DownloadZipPath         = $Node.DownloadPath
            ArtifactoryFiles        = $Node.ArtifactorySqlSWArray
            ArtifactoryAccessKey    = $Node.ArtifactoryKey
            ArtifactoryRepoURL      = $Node.ArtifactoryURLSql
        
            DependsOn       = '[File]SourcesFolder'
        }
        
        #Download Security Related Software
        ArtifactoryDownload SecuritySoftwareDownload
        {
            UniqueName              = 'SecuritySoftwareDownload' 
            DownloadZipPath         = $Node.DownloadPath
            ArtifactoryFiles        = $Node.ArtifactorySecuritySWArray
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
            DependsOn = '[ArtifactoryDownload]SecuritySoftwareDownload'
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
            DependsOn = '[ArtifactoryDownload]SecuritySoftwareDownload'
        }

        McAfeeInstall InstallMcAfee
        {
            McAfeeInstallFilename = $Node.McAfeeFile 
            McAfeeInstallFolder = ($Node.SourcesFolderPath + '\McAfee\')
            McAfeeInstallArguments = $Node.McAfeeArguments
            DependsOn = '[Archive]McAfeeFileZipExtract'
        }

        xWaitForADDomain WaitForADDomainOnMaster
        {
            DomainName = $Node.DomainToJoin
            DomainUserCredential = $DomainJoinCredential
            RebootRetryCount = $Node.RebootRetryCount
            RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = '[DnsServerAddress]SetDNSServerAddress'
        }
        
        $SplitDomain = $Node.DomainToJoin.split('.')[0]
        Computer DomainJoin
        {
            Name = $Node.NodeName
            Credential = $DomainJoinCredential
            DomainName = $Node.DomainToJoin
            #JoinOU = ($Node.OUPath + "," + 'DC={0},DC={1}' -f ($SplitDomain), ($Node.DomainToJoin.split('.')[1]))
            Server = ($Node.ADDomainController + '.' + $Node.DomainToJoin)
            PsDscRunAsCredential = $DomainJoinCredential
            DependsOn = '[xWaitForADDomain]WaitForADDomainOnMaster'
        }
<#
        Archive IEMFileZipExtract
        {
            Destination = ($Node.SourcesFolderPath + '\')
            Path = ($Node.DownloadPath + '\' + $Node.IEMResourceClientZip)
            Ensure = $Node.ExtractEnsureString
            Force = $Node.ExtractForce
            DependsOn = '[ArtifactoryDownload]SecuritySoftwareDownload', '[Computer]ConfigMgrDomainJoin'
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
        
        File PrestageFolder
        {
            DestinationPath = ($Node.PrestageDriveLetter + ':' + '\' + $Node.DestinationPath)
            Ensure = $Node.EnsureString
            Type = $Node.Type
            DependsOn = '[Computer]ConfigMgrDomainJoin'
        }

        Group LocalAdministratorGroupPermissions
        {
            GroupName = $Node.LAGroupName
            Credential = $DomainJoinCredential
            Ensure = $Node.LAGroupEnsureString
            MembersToInclude = "$SplitDomain\$($Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName2)"
            DependsOn = '[Computer]ConfigMgrDomainJoin'
            PsDscRunAsCredential = $DomainJoinCredential
        }

        cNtfsPermissionEntry PrestageFolderPermissions
        {
            Ensure = $Node.PFPermissionsEnsureString
            Path = ($Node.PrestageDriveLetter + ':' + '\' + $Node.DestinationPath)
            Principal = "$SplitDomain\$($Node.DataDName1 + "-" + $Node.CustCode + "-" + $Node.NodeName + "_" + $Node.PrestageDriveLetter + "_" + $Node.DataDName2)"
            AccessControlInformation = @(
                cNtfsAccessControlInformation
                {
                    AccessControlType = $Node.PFPermissionsAccessControlType
                    FileSystemRights = $Node.PFPermissionsFileSystemRights
                    Inheritance = $Node.PFPermissionsInheritance
                    NoPropagateInherit = $Node.PFPermissionsNoPropagateInherit
                }
            )
            ItemType = $Node.PFPermissionsItemType
            DependsOn = '[File]PrestageFolder'
        }

        cNtfsPermissionEntry DebugFolderPermissions
        {
            Ensure = $Node.DFPermissionsEnsureString
            Path = $Node.DFPermissionsPath
            Principal = "$SplitDomain\$($Node.DataDName1 + "-" + $Node.CustCode + "-" + $Node.DataDName3)"
            AccessControlInformation = @(
                cNtfsAccessControlInformation
                {
                    AccessControlType = $Node.DFPermissionsAccessControlType
                    FileSystemRights = $Node.DFPermissionsFileSystemRights
                    Inheritance = $Node.DFPermissionsInheritance
                    NoPropagateInherit = $Node.DFPermissionsNoPropagateInherit
                }
            )
            ItemType = $Node.DFPermissionsItemType
            DependsOn = '[Computer]ConfigMgrDomainJoin'
        }

        cNtfsPermissionEntry TempFolderPermissions
        {
            Ensure = $Node.TFPermissionsEnsureString
            Path = $Node.TFPermissionsPath
            Principal = "$SplitDomain\$($Node.DataDName1 + "-" + $Node.CustCode + "-" + $Node.DataDName4)"
            AccessControlInformation = @(
                cNtfsAccessControlInformation
                {
                    AccessControlType = $Node.TFPermissionsAccessControlType
                    FileSystemRights = $Node.TFPermissionsFileSystemRights
                    Inheritance = $Node.TFPermissionsInheritance
                    NoPropagateInherit = $Node.TFPermissionsNoPropagateInherit
                }
            )
            ItemType = $Node.TFPermissionsItemType
            DependsOn = '[Computer]ConfigMgrDomainJoin'
        }

        File SMSLoadFolder
        {
            DestinationPath = ($Node.SMSLoadDriveLetter + ':' + '\' + $Node.SMSLoadFolder)
            Ensure = $Node.SMSLoadEnsureString
            Type = $Node.SMSLoadType
            DependsOn = '[Computer]ConfigMgrDomainJoin'
        }
        
        Archive SFSBinaries
        {
            Destination = ($Node.SourcesFolderPath + '\')
            Path = ($Node.DownloadPath + '\' + $Node.SFSZip)
            Ensure = $Node.ExtractEnsureString
            Force = $Node.ExtractForce
            DependsOn = '[ArtifactoryDownload]SecuritySoftwareDownload', '[Computer]ConfigMgrDomainJoin'
        }

        If ($Node.SFSFoundationRequired)
        {
            Script SFSFoundationCopyAndFoldersRename
            {
                GetScript = 
                {
                    $FullSMSLoadPath = ($Using:Node.SMSLoadDriveLetter + ':' + '\' + $Using:Node.SMSLoadFolder)
                    $SFSFoundationContentExistence = $Null
                    $SFSFoundationContentExistence = (Test-Path -Path "$FullSMSLoadPath\Config") -and (Test-Path -Path "$FullSMSLoadPath\MPConfig*") -and (Test-Path -Path "$FullSMSLoadPath\MPPackages*") -and (Test-Path -Path "$FullSMSLoadPath\*.txt")
                    return @{'Result' = $SFSFoundationContentExistence}
                }
                TestScript = 
                {
                    $FullSMSLoadPath = ($Using:Node.SMSLoadDriveLetter + ':' + '\' + $Using:Node.SMSLoadFolder)
                    $SFSFoundationContentExistence = $Null
                    $SFSFoundationContentExistence = (Test-Path -Path "$FullSMSLoadPath\Config") -and (Test-Path -Path "$FullSMSLoadPath\MPConfig*") -and (Test-Path -Path "$FullSMSLoadPath\MPPackages*") -and (Test-Path -Path "$FullSMSLoadPath\*.txt")
                    If ($SFSFoundationContentExistence)
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
                    $CustCode = $Using:Node.CustCode
                    $SFSFoundationSourcePath = ($Using:Node.SourcesFolderPath + '\' + $Using:Node.SFSRelease + '\' + $Using:Node.SFSFoundationSourceFolder)
                    $FullSMSLoadPath = ($Using:Node.SMSLoadDriveLetter + ':' + '\' + $Using:Node.SMSLoadFolder)
                    Copy-Item -Path "$SFSFoundationSourcePath\*" -Destination $FullSMSLoadPath -Force -Recurse
                    Rename-Item -Path "$FullSMSLoadPath\MPConfig.YYY" -NewName ("MPConfig" + '.' + $CustCode) -Force
                    Rename-Item -Path "$FullSMSLoadPath\MPPackages.YYY" -NewName ("MPPackages" + '.' + $CustCode) -Force
                }
                DependsOn = '[File]SMSLoadFolder', '[Archive]SFSBinaries'
            }

            Script SMSLoadAndConfigBasicShares
            {
                GetScript = 
                {
                    $SMSLoadShare = $Null
                    $ConfigShare = $Null
                    $SMSLoadShare = Get-SmbShare -Name ($Using:Node.SMSLoadFolder + '$') -ErrorAction SilentlyContinue
                    $ConfigShare = Get-SmbShare -Name $Using:Node.ConfigFolder -ErrorAction SilentlyContinue
                    return @{'Result' = ($SMSLoadShare).Name, ($ConfigShare).Name}
                }
                TestScript = 
                {
                    $SMSLoadShare = $Null
                    $ConfigShare = $Null
                    $SMSLoadShare = Get-SmbShare -Name ($Using:Node.SMSLoadFolder + '$') -ErrorAction SilentlyContinue
                    $ConfigShare = Get-SmbShare -Name $Using:Node.ConfigFolder -ErrorAction SilentlyContinue
                    If (($SMSLoadShare).Name -eq ($Using:Node.SMSLoadFolder + '$') -and ($ConfigShare).Name -eq $Using:Node.ConfigFolder)
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
                    New-SmbShare -Name ($Using:Node.SMSLoadFolder + '$') -Path ($using:Node.SMSLoadDriveLetter + ':' + '\' + $Using:Node.SMSLoadFolder) -FullAccess $Using:Node.BasicSharesFullAccessPermissionsTo -ErrorAction SilentlyContinue
                    New-SmbShare -Name $Using:Node.ConfigFolder -Path ($using:Node.SMSLoadDriveLetter + ':' + '\' + $Using:Node.SMSLoadFolder + '\' + $Using:Node.ConfigFolder) -FullAccess $Using:Node.BasicSharesFullAccessPermissionsTo -ErrorAction SilentlyContinue
                }
                DependsOn = '[Script]SFSFoundationCopyAndFoldersRename'
            }

            File CMTraceCopy
            {
                DestinationPath = $Node.CMTraceDestinationPath
                SourcePath = ('\\' + $Node.NodeName + '\' + $Node.ConfigFolder + '\' + $Node.CMTraceSourcePath)
                Ensure = $Node.CMTraceDestinationEnsureString
                Force = $Node.CMTraceDestinationForce
                Type = $Node.CMTraceType
                DependsOn = '[Script]SMSLoadAndConfigBasicShares'
            }

            Registry CMTraceRegistrySetting1
            {
                Key = $Node.CMTraceKey1
                ValueName = $Node.CMTraceValueName1
                Ensure = $Node.CMTraceRegistryEnsureString
                Force = $Node.CMTraceRegistryForce
                ValueData = $Node.CMTraceValueData1
                ValueType = $Node.CMTraceValueType
                DependsOn = '[File]CMTraceCopy'
                PsDscRunAsCredential = $DomainJoinCredential
            }

            Registry CMTraceRegistrySetting2
            {
                Key = $Node.CMTraceKey2
                ValueName = $Node.CMTraceValueNameBlank
                Ensure = $Node.CMTraceRegistryEnsureString
                Force = $Node.CMTraceRegistryForce
                ValueData = $Node.CMTraceValueData2And3
                ValueType = $Node.CMTraceValueType
                DependsOn = '[File]CMTraceCopy'
                PsDscRunAsCredential = $DomainJoinCredential
            }

            Registry CMTraceRegistrySetting3
            {
                Key = $Node.CMTraceKey3
                ValueName = $Node.CMTraceValueNameBlank
                Ensure = $Node.CMTraceRegistryEnsureString
                Force = $Node.CMTraceRegistryForce
                ValueData = $Node.CMTraceValueData2And3
                ValueType = $Node.CMTraceValueType
                DependsOn = '[File]CMTraceCopy'
                PsDscRunAsCredential = $DomainJoinCredential
            }

            Registry CMTraceRegistrySetting4
            {
                Key = $Node.CMTraceKey4
                ValueName = $Node.CMTraceValueNameBlank
                Ensure = $Node.CMTraceRegistryEnsureString
                Force = $Node.CMTraceRegistryForce
                ValueData = $Node.CMTraceValueData4
                ValueType = $Node.CMTraceValueType
                DependsOn = '[File]CMTraceCopy'
                PsDscRunAsCredential = $DomainJoinCredential
            }

            Archive SXSBinaries
            {
                Destination = ($Node.SourcesFolderPath + '\')
                Path = ($Node.DownloadPath + '\' + $Node.SXSZip)
                Ensure = $Node.ExtractEnsureString
                Force = $Node.ExtractForce
                DependsOn = '[ArtifactoryDownload]SecuritySoftwareDownload', '[Computer]ConfigMgrDomainJoin'
            }

            WindowsFeatureSet InstallDotNetFramework
            {
                Name = $Node.FeatureNames
                Ensure = $Node.FeaturesEnsureString
                Source = $Node.DotNetFramework35Source
                IncludeAllSubFeature = $Node.IncludeAllSubFeatureChoice
                DependsOn = '[Archive]SXSBinaries'
            }

            File CSCCMPSModuleCopy1
            {
                DestinationPath = $Node.CSCCMPSModuleDestinationPath1
                Ensure = $Node.CSCCMPSModuleEnsureString
                Force = $Node.CSCCMPSModuleForce
                Recurse = $Node.CSCCMPSModuleRecurse
                SourcePath = ('\\' + $Node.NodeName + '\' + $Node.ConfigFolder + '\' + $Node.CSCCMPSModuleSourcePath)
                Type = $Node.CSCCMPSModuleType
                DependsOn = '[Script]SMSLoadAndConfigBasicShares'
            }

            File CSCCMPSModuleCopy2
            {
                DestinationPath = $Node.CSCCMPSModuleDestinationPath2
                Ensure = $Node.CSCCMPSModuleEnsureString
                Force = $Node.CSCCMPSModuleForce
                Recurse = $Node.CSCCMPSModuleRecurse
                SourcePath = ('\\' + $Node.NodeName + '\' + $Node.ConfigFolder + '\' + $Node.CSCCMPSModuleSourcePath)
                Type = $Node.CSCCMPSModuleType
                DependsOn = '[Script]SMSLoadAndConfigBasicShares'
            }

            xTokenize ADResourcesXMLTokenize
            {
                path = ('\\' + $Node.NodeName + '\' + $Node.ConfigFolder + '\' + $Node.ADResourcesXMLPath)
                tokens = @{Domain_Name="$($Node.DomainToJoin)";YYY="$($Node.CustCode)"}
                useTokenFiles = $Node.ADResourceXMLUseTokenFiles
                DependsOn = '[Script]SMSLoadAndConfigBasicShares'
            }

            xTokenize CMConfigXMLTokenize
            {
                path = ('\\' + $Node.NodeName + '\' + $Node.ConfigFolder + '\' + $Node.CMConfigXMLPath)
                tokens = @{CENTRALSERVER="$($Node.NodeName).$($Node.DomainToJoin)";LOADSERVER="$($Node.NodeName).$($Node.DomainToJoin)";COMPANY="$($Node.CustCode)";GROUP_DOMAINS="$($Node.DomainToJoin)";IPADDRESS_PORT="$($Node.KMSServerIPAddressAndPort)";WIN7PRODUCTKEY="$($Node.Win7ProductKey)";WIN81PRODUCTKEY="$($Node.Win81ProductKey)";WIN10ENTPRODUCTKEY="$($Node.Win10EntProductKey)";WIN10PROPRODUCTKEY="$($Node.Win10ProProductKey)";WIN10LTSBPRODUCTKEY="$($Node.Win10LTSBProductKey)"}
                useTokenFiles = $Node.CMConfigXMLUseTokenFiles
                DependsOn = '[Script]SMSLoadAndConfigBasicShares'
            }

            File CopyConfigMgrUnattendedFileTemplate
            {
                DestinationPath = ('\\' + $Node.NodeName + '\' + $Node.ConfigFolder + '\' + $Node.UnattendedFileDestinationPath + '\' + $Node.NodeName + '.TXT')
                Ensure = $Node.UnattendedFileEnsureString
                Force = $Node.UnattendedFileForce
                SourcePath = ('\\' + $Node.NodeName + '\' + $Node.ConfigFolder + '\' + $Node.UnattendedFileSourcePath)
                Type = $Node.UnattendedFileType
                DependsOn = '[Script]SMSLoadAndConfigBasicShares'
            }

            xTokenize ConfigMgrUnattendedFileTokenize
            {
                path = ('\\' + $Node.NodeName + '\' + $Node.ConfigFolder + '\' + $Node.UnattendedFileDestinationPath + '\' + $Node.NodeName + '.TXT')
                tokens = 
                @{
                    Action="$($Node.Action)";
                    SAActive="$($Node.SAActive)";
                    CurrentBranch="$($Node.CurrentBranch)";
                    ProductID="$($Node.ProductID)";
                    SiteCode="$($Node.CustCode)";
                    SiteName="$($Node.NodeName)";
                    SMSInstallDir="$($Node.SMSLoadDriveLetter):\$($Node.SMSInstallDir)";
                    SDKServer="$($Node.NodeName).$($Node.DomainToJoin)";
                    RoleCommunicationProtocol="$($Node.RoleCommunicationProtocol)";
                    ClientsUsePKICertificate="$($Node.ClientsUsePKICertificate)";
                    PrerequisiteComp="$($Node.PrerequisiteComp)";
                    PrerequisitePath="\\$($Node.NodeName)\$($Node.ConfigFolder)\$($Node.PrerequisitePath)";
                    MobileDeviceLanguage="$($Node.MobileDeviceLanguage)";
                    ManagementPoint="$($Node.NodeName).$($Node.DomainToJoin)";
                    ManagementPointProtocol="$($Node.ManagementPointProtocol)";
                    DistributionPoint="$($Node.NodeName).$($Node.DomainToJoin)";
                    DistributionPointProtocol="$($Node.DistributionPointProtocol)";
                    DistributionPointInstallIIS="$($Node.DistributionPointInstallIIS)";
                    AdminConsole="$($Node.AdminConsole)";
                    JoinCEIP="$($Node.JoinCEIP)";
                    SQLServerName="$($Node.SQLServerName).$($Node.DomainToJoin)";
                    DatabaseName="$($Node.DatabaseName)";
                    SQLSERVERPORT="$($Node.SQLSERVERPORT)";
                    SQLSSBPort="$($Node.SQLSSBPort)";
                    CloudConnector="$($Node.CloudConnector)";
                    CloudConnectorServer="$($Node.NodeName).$($Node.DomainToJoin)";
                    UseProxy="$($Node.UseProxy)";
                    ProxyName="$($Node.ProxyName)";
                    ProxyPort="$($Node.ProxyPort)";
                    CCARSiteServer="$($Node.CCARSiteServer)";
                    MPOP_SMS_ENTERPADMIN="$($Node.MPOP_SMS_ENTERPADMIN)";
                    MPOP_SMS_IMAGESADMIN="$($Node.MPOP_SMS_IMAGESADMIN)";
                    MPOP_SMS_PATCHADMIN="$($Node.MPOP_SMS_PATCHADMIN)";
                    MPOP_SW_DEPLADMIN="$($Node.MPOP_SW_DEPLADMIN)";
                    MPOP_SW_SUPPORT="$($Node.MPOP_SW_SUPPORT)";
                    Lastrow="$($Node.Lastrow)"
                }
                useTokenFiles = $Node.UnattendedFileUseTokenFiles
                DependsOn = '[File]CopyConfigMgrUnattendedFileTemplate'
            }

            cNtfsPermissionsInheritance SMSLoadBlockInheritance
            {
                Path = ($Node.SMSLoadDriveLetter + ':' + '\' + $Node.SMSLoadFolder)
                Enabled = $Node.SMSLoadNTFSPermsInheritanceEnabled
                PreserveInherited = $Node.SMSLoadNTFSPreserveInherited
                DependsOn = '[xTokenize]ConfigMgrUnattendedFileTokenize'
            }

            cNtfsPermissionEntry SMSLoadPermissions1
            {
                Ensure = $Node.SFSLoadPermissionsEnsureString
                Path = ($Node.SMSLoadDriveLetter + ':' + '\' + $Node.SMSLoadFolder)
                Principal = "$SplitDomain\$($Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName3)"
                AccessControlInformation = @(
                    cNtfsAccessControlInformation
                    {
                        AccessControlType = $Node.SFSLoadPermissionsAccessControlType
                        FileSystemRights = $Node.SFSLoadPermissionsFileSystemRights2
                        Inheritance = $Node.SFSLoadPermissionsInheritance
                        NoPropagateInherit = $Node.SFSLoadPermsNoPropagateInherit
                    }
                )
                DependsOn = '[cNtfsPermissionsInheritance]SMSLoadBlockInheritance'
            }

            cNtfsPermissionEntry SMSLoadPermissions2
            {
                Ensure = $Node.SFSLoadPermissionsEnsureString
                Path = ($Node.SMSLoadDriveLetter + ':' + '\' + $Node.SMSLoadFolder)
                Principal = $Node.SystemIdentity
                AccessControlInformation = @(
                    cNtfsAccessControlInformation
                    {
                        AccessControlType = $Node.SFSLoadPermissionsAccessControlType
                        FileSystemRights = $Node.SFSLoadPermissionsFileSystemRights2
                        Inheritance = $Node.SFSLoadPermissionsInheritance
                        NoPropagateInherit = $Node.SFSLoadPermsNoPropagateInherit
                    }
                )
                DependsOn = '[cNtfsPermissionsInheritance]SMSLoadBlockInheritance'
            }

            cNtfsPermissionEntry SMSLoadPermissions3
            {
                Ensure = $Node.SFSLoadPermissionsEnsureString
                Path = ($Node.SMSLoadDriveLetter + ':' + '\' + $Node.SMSLoadFolder)
                Principal = "$SplitDomain\$($Node.RoleUName1 + "-" + $Node.CustCode + "-" + $Node.RoleUName2)"
                AccessControlInformation = @(
                    cNtfsAccessControlInformation
                    {
                        AccessControlType = $Node.SFSLoadPermissionsAccessControlType
                        FileSystemRights = $Node.SFSLoadPermissionsFileSystemRights2
                        Inheritance = $Node.SFSLoadPermissionsInheritance
                        NoPropagateInherit = $Node.SFSLoadPermsNoPropagateInherit
                    }
                )
                DependsOn = '[cNtfsPermissionsInheritance]SMSLoadBlockInheritance'
            }

            cNtfsPermissionEntry SMSLoadPermissions4
            {
                Ensure = $Node.SFSLoadPermissionsEnsureString
                Path = ($Node.SMSLoadDriveLetter + ':' + '\' + $Node.SMSLoadFolder)
                Principal = $Node.UsersIdentity
                AccessControlInformation = @(
                    cNtfsAccessControlInformation
                    {
                        AccessControlType = $Node.SFSLoadPermissionsAccessControlType
                        FileSystemRights = $Node.SFSLoadPermissionsFileSystemRights1
                        Inheritance = $Node.SFSLoadPermissionsInheritance
                        NoPropagateInherit = $Node.SFSLoadPermsNoPropagateInherit
                    }
                )
                DependsOn = '[cNtfsPermissionsInheritance]SMSLoadBlockInheritance'
            }

            cNtfsPermissionEntry MPPackagesPermissions1
            {
                Ensure = $Node.SFSLoadPermissionsEnsureString
                Path = ($Node.SMSLoadDriveLetter + ':' + '\' + $Node.SMSLoadFolder + '\' + "MPPackages.$($Node.CustCode)")
                Principal = "$SplitDomain\$($Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName5)"
                AccessControlInformation = @(
                    cNtfsAccessControlInformation
                    {
                        AccessControlType = $Node.SFSLoadPermissionsAccessControlType
                        FileSystemRights = $Node.SFSLoadPermissionsFileSystemRights2
                        Inheritance = $Node.SFSLoadPermissionsInheritance
                        NoPropagateInherit = $Node.SFSLoadPermsNoPropagateInherit
                    }
                )
                DependsOn = '[cNtfsPermissionsInheritance]SMSLoadBlockInheritance'
            }

            cNtfsPermissionEntry MPPackagesPermissions2
            {
                Ensure = $Node.SFSLoadPermissionsEnsureString
                Path = ($Node.SMSLoadDriveLetter + ':' + '\' + $Node.SMSLoadFolder + '\' + "MPPackages.$($Node.CustCode)")
                Principal = "$SplitDomain\$($Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName4)"
                AccessControlInformation = @(
                    cNtfsAccessControlInformation
                    {
                        AccessControlType = $Node.SFSLoadPermissionsAccessControlType
                        FileSystemRights = $Node.SFSLoadPermissionsFileSystemRights2
                        Inheritance = $Node.SFSLoadPermissionsInheritance
                        NoPropagateInherit = $Node.SFSLoadPermsNoPropagateInherit
                    }
                )
                DependsOn = '[cNtfsPermissionsInheritance]SMSLoadBlockInheritance'
            }
        }

        If ($Node.NomadFoundationRequired)
        {
            Script NomadFoundationCopyAndFolderRename
            {
                GetScript = 
                {
                    $FullNomadFoundationConfigSourcePath = ($Using:Node.SMSLoadDriveLetter + ':' + '\' + $Using:Node.SMSLoadFolder + '\' + $Using:Node.NomadFoundationConfigSourceString)
                    $FullNomadFoundationConfigUtilsPath = ($Using:Node.SMSLoadDriveLetter + ':' + '\' + $Using:Node.SMSLoadFolder + '\' + $Using:Node.NomadFoundationConfigUtilsString)
                    $FullSMSLoadPath = ($Using:Node.SMSLoadDriveLetter + ':' + '\' + $Using:Node.SMSLoadFolder)
                    $NomadFoundationContentExistence = $Null
                    $NomadFoundationContentExistence = (Test-Path -Path "$FullNomadFoundationConfigSourcePath\1E_Active_Efficiency") -and (Test-Path -Path "$FullNomadFoundationConfigSourcePath\1E_Nomadbranch") -and (Test-Path -Path "$FullNomadFoundationConfigSourcePath\1E_PXELite") -and (Test-Path -Path "$FullNomadFoundationConfigUtilsPath\1EActiveEfficiencyJob") -and (Test-Path -Path "$FullSMSLoadPath\MPApplModel*") -and (Test-Path -Path "$FullSMSLoadPath\*.txt")
                    return @{'Result' = $NomadFoundationContentExistence}
                }
                TestScript = 
                {
                    $FullNomadFoundationConfigSourcePath = ($Using:Node.SMSLoadDriveLetter + ':' + '\' + $Using:Node.SMSLoadFolder + '\' + $Using:Node.NomadFoundationConfigSourceString)
                    $FullNomadFoundationConfigUtilsPath = ($Using:Node.SMSLoadDriveLetter + ':' + '\' + $Using:Node.SMSLoadFolder + '\' + $Using:Node.NomadFoundationConfigUtilsString)
                    $FullSMSLoadPath = ($Using:Node.SMSLoadDriveLetter + ':' + '\' + $Using:Node.SMSLoadFolder)
                    $NomadFoundationContentExistence = $Null
                    $NomadFoundationContentExistence = (Test-Path -Path "$FullNomadFoundationConfigSourcePath\1E_Active_Efficiency") -and (Test-Path -Path "$FullNomadFoundationConfigSourcePath\1E_Nomadbranch") -and (Test-Path -Path "$FullNomadFoundationConfigSourcePath\1E_PXELite") -and (Test-Path -Path "$FullNomadFoundationConfigUtilsPath\1EActiveEfficiencyJob") -and (Test-Path -Path "$FullSMSLoadPath\MPApplModel*") -and (Test-Path -Path "$FullSMSLoadPath\*.txt")
                    If ($NomadFoundationContentExistence)
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
                    $CustCode = $Using:Node.CustCode
                    $NomadFoundationSourcePath = ($Using:Node.SourcesFolderPath + '\' + $Using:Node.SFSRelease + '\' + $Using:Node.NomadFoundationSourceFolder)
                    $FullSMSLoadPath = ($Using:Node.SMSLoadDriveLetter + ':' + '\' + $Using:Node.SMSLoadFolder)
                    Copy-Item -Path "$NomadFoundationSourcePath\*" -Destination $FullSMSLoadPath -Force -Recurse
                    Rename-Item -Path "$FullSMSLoadPath\MPApplModel.YYY" -NewName ("MPApplModel" + '.' + $CustCode)
                }
                DependsOn = '[File]SMSLoadFolder', '[Archive]SFSBinaries'
            }

            cNtfsPermissionEntry MPApplModelPermissions
            {
                Ensure = $Node.SFSLoadPermissionsEnsureString
                Path = ($Node.SMSLoadDriveLetter + ':' + '\' + $Node.SMSLoadFolder + '\' + "MPApplModel.$($Node.CustCode)")
                Principal = "$SplitDomain\$($Node.PermDName1 + "-" + $Node.CustCode + "-" + $Node.PermDName4)"
                AccessControlInformation = @(
                    cNtfsAccessControlInformation
                    {
                        AccessControlType = $Node.SFSLoadPermissionsAccessControlType
                        FileSystemRights = $Node.SFSLoadPermissionsFileSystemRights2
                        Inheritance = $Node.SFSLoadPermissionsInheritance
                        NoPropagateInherit = $Node.SFSLoadPermsNoPropagateInherit
                    }
                )
                DependsOn = '[cNtfsPermissionsInheritance]SMSLoadBlockInheritance'
            }
        }

        If ($Node.LAPMRequired)
        {
            Script LAPMCopy
            {
                GetScript = 
                {
                    $CustCode = $Using:Node.CustCode
                    $FullLAPMConfigUtilsPath = ($Using:Node.SMSLoadDriveLetter + ':' + '\' + $Using:Node.SMSLoadFolder + '\' + $Using:Node.LAPMConfigUtilsString)
                    $FullSMSLoadPath = ($Using:Node.SMSLoadDriveLetter + ':' + '\' + $Using:Node.SMSLoadFolder)
                    $LAPMContentExistence = $Null
                    $LAPMContentExistence = (Test-Path -Path "$FullLAPMConfigUtilsPath\GPO_Binaries") -and (Test-Path -Path "$FullSMSLoadPath\MPPackages.$CustCode\LAPM_LAPS_Installer") -and (Test-Path -Path "$FullSMSLoadPath\*.txt")
                    return @{'Result' = $LAPMContentExistence}
                }
                TestScript = 
                {
                    $CustCode = $Using:Node.CustCode
                    $FullLAPMConfigUtilsPath = ($Using:Node.SMSLoadDriveLetter + ':' + '\' + $Using:Node.SMSLoadFolder + '\' + $Using:Node.LAPMConfigUtilsString)
                    $FullSMSLoadPath = ($Using:Node.SMSLoadDriveLetter + ':' + '\' + $Using:Node.SMSLoadFolder)
                    $LAPMContentExistence = $Null
                    $LAPMContentExistence = (Test-Path -Path "$FullLAPMConfigUtilsPath\GPO_Binaries") -and (Test-Path -Path "$FullSMSLoadPath\MPPackages.$CustCode\LAPM_LAPS_Installer") -and (Test-Path -Path "$FullSMSLoadPath\*.txt")
                    If ($LAPMContentExistence)
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
                    $CustCode = $Using:Node.CustCode
                    $LAPMSourcePath = ($Using:Node.SourcesFolderPath + '\' + $Using:Node.SFSRelease + '\' + $Using:Node.LAPMSourceFolder)
                    $FullSMSLoadPath = ($Using:Node.SMSLoadDriveLetter + ':' + '\' + $Using:Node.SMSLoadFolder)
                    Copy-Item -Path "$LAPMSourcePath\Config" -Destination $FullSMSLoadPath -Force -Recurse
                    Copy-Item -Path "$LAPMSourcePath\MPPackages.YYY\*" -Destination "$FullSMSLoadPath\MPPackages.$CustCode" -Force -Recurse
                    Copy-Item -Path "$LAPMSourcePath\*.txt" -Destination $FullSMSLoadPath -Force -Recurse
                }
                DependsOn = '[File]SMSLoadFolder', '[Archive]SFSBinaries'
            }
        }
        #>
    }
}