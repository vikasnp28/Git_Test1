@{
    AllNodes = @(
        #ConfigMgr Server data:
        @{
            #ConfigMgr Server data for Active Directory that will be frequently updated for deployments:
            NodeName                           = 'devwldspt001'
            CustCode                           = 'MWS'
            DomainToJoin                       = 'mws.ad'
            ADDomainController                 = 'devsfsdc001'
            PrestageDriveLetter                = 'F'
            
            #Node data:
            Role                               = 'CM'
            
            #DNS Server Address data:
            DNSServerAddressFamily             = 'IPv4'
            DNSServerAddressInterfaceAlias     = 'Ethernet'
            DNSServerAddress                   = '10.100.1.4'
            DNSServerAddressValidate           = $True
            
            #Domain Join and Wait for Domain data:
            OUPath                             = 'OU=SCCM,OU=Servers,OU=Customer'
            RebootRetryCountCM                 = 2
            RetryCountCM                       = 10
            RetryIntervalSecCM                 = 60

            #Prestage Folder data:
            DestinationPath                    = 'MWSPrestage\Prestage'
            EnsureString                       = 'Present'
            Type                               = 'Directory'

            #Local Administrator Group data:
            LAGroupName                        = 'Administrators'
            LAGroupEnsureString                = 'Present'
            PermDName1                         = 'PERM-D'
            PermDName2                         = 'LocalAdmin-SCCM'

            #Prestage Folder Permissions data:
            PFPermissionsEnsureString          = 'Present'
            PFPermissionsAccessControlType     = 'Allow'
            PFPermissionsFileSystemRights      = 'Modify'
            PFPermissionsInheritance           = 'ThisFolderSubfoldersAndFiles'
            PFPermissionsNoPropagateInherit    = $false
            PFPermissionsItemType              = 'Directory'
            DataDName1                         = 'DATA-D'
            DataDName2                         = 'Prestage_M'
            
            #Debug Folder Permissions data:
            DFPermissionsEnsureString          = 'Present'
            DFPermissionsPath                  = 'C:\Windows\Debug'
            DFPermissionsAccessControlType     = 'Allow'
            DFPermissionsFileSystemRights      = 'Modify'
            DFPermissionsInheritance           = 'ThisFolderSubfoldersAndFiles'
            DFPermissionsNoPropagateInherit    = $false
            DFPermissionsItemType              = 'Directory'
            DataDName3                         = 'SCCM-DebugFolder'

            #Temp Folder Permissions data:
            TFPermissionsEnsureString          = 'Present'
            TFPermissionsPath                  = 'C:\Windows\Temp'
            TFPermissionsAccessControlType     = 'Allow'
            TFPermissionsFileSystemRights      = 'FullControl'
            TFPermissionsInheritance           = 'ThisFolderSubfoldersAndFiles'
            TFPermissionsNoPropagateInherit    = $false
            TFPermissionsItemType              = 'Directory'
            DataDName4                         = 'SCCM-TEMP-Folder'

            #Packages Download, Extract & Execution  data:
            ArtifactorySecuritySWArray         = @('CrowdStrikeFalconWindowsSensor_4.22.8504.zip', 'DXC-ENG-McAfeeEndpointSecurity-10.6.1-GBL-R1.zip', 'IEMResource_Client_9.2.5.130.zip', 'SFS8.0_Automation.zip', 'sxs.zip')
            ArtifactoryKey                     = 'AKCp5cckfBtRN2taRZtjvJRV85HqNkt4n1FsCnNMrJ8MFSEDTS5idqF1eAA21ww5REjJ9ErxX'
            ArtifactoryURL                     = 'https://artifactory.csc.com/artifactory/dsmce-generic/'
            CrowdStrikeFalconWindowsSensorZip  = 'CrowdStrikeFalconWindowsSensor_4.22.8504.zip'
            McAfeeZip                          = 'DXC-ENG-McAfeeEndpointSecurity-10.6.1-GBL-R1.zip'
            IEMResourceClientZip               = 'IEMResource_Client_9.2.5.130.zip'
            SFSZip                             = 'SFS8.0_Automation.zip'
            SXSZip                             = 'sxs.zip'
            DownloadPath                       = 'C:\Windows\Temp'
            SourcesFolderPath                  = 'C:\Sources'
            SourcesFolderEnsureString          = 'Present'
            SourcesFolderType                  = 'Directory'
            CrowdStrikeFalconWindowsSensorFile = 'CrowdStrikeFalconWindowsSensor_4.22.8504.exe'
            McAfeeFile                         = 'DXC-ENG-McAfeeEndpointSecurity-10.6.1-GBL-R1.exe'
            IEMResourceClientFile              = 'setup.exe'
            IEMProductID                       = '4C0151B6-7CB8-4F72-B07B-A70FF0066B0E'
            IEMArguments                       = "/S /v/qn"
            IEMInstallEnsureString             = "Present"
            IEMCFGSourcePath                   = 'C:\Sources\IEMResource_Client\clientsettings.cfg'
            IEMCFGDestinationPath              = 'C:\Sources\IEMResource_Client\clientsettings cfg files\RES\clientsettings.cfg'
            IEMCFGChecksum                     = 'ModifiedDate'
            IEMCFGDestinationEnsureString      = 'Present'
            IEMCFGDestinationForce             = $True
            IEMCFGType                         = 'File'
            IEMCFGMatchSource                  = $True
            IEMAFXMPath                        = 'C:\Sources\IEMResource_Client\masthead.afxm'
            IEMUseTokenFiles                   = $False
            IEMRelayControlRootServer          = 'http://cscesmiemott03v.bmwslab.net:52311/cgi-bin/bfgather.exe/actionsite'
            IEMRelayControlServer1             = 'http://cscesmiemott03v.bmwslab.net:52311'
            IEMRelayControlServer2             = ''
            IEMRelayServer1                    = 'http://CSCESMFLEXOTT05.DILMWS.CSCMWS.com:52311/bfmirror/downloads/'
            IEMRelayServer2                    = 'http://CSCESMFLEXOTT05.DILMWS.CSCMWS.com:52311/bfmirror/downloads/'
            IEMRelaySelectAutomatic            = '0'
            BESCliActMgrSkipVolOnForShut       = '1'
            IEMCSCCustomerID                   = 'DIL'
            IEMCSCEnvironment                  = ''
            IEMCSCFlexeraMGSFTDomainName       = 'DILMWS.CSCMWS.com'
            IEMFlexeraMGSFTBootstrapDownload   = 'cscesmflexott06.DILMWS.CSCMWS.com'
            IEMFixletSiteGatherURL             = 'http://cscesmiemott03v.bmwslab.net:52311/cgi-bin/bfgather.exe/actionsite'
            IEMFixletSiteReportURL             = 'http://cscesmiemott03v.bmwslab.net:52311/cgi-bin/bfenterprise/PostResults.exe'
            IEMFixletSiteRegistrationURL       = 'http://cscesmiemott03v.bmwslab.net:52311/cgi-bin/bfenterprise/clientregister.exe'
            IEMBESMirrorGatherURL              = 'http://cscesmiemott03v.bmwslab.net:52311/cgi-bin/bfenterprise/besgathermirror.exe'
            IEMBESMirrorDownloadURL            = 'http://cscesmiemott03v.bmwslab.net:52311/bfmirror/downloads/'
            CrowdStrikeFalconWindowsSensorArgs = "/install /quiet /norestart CID=35C43E7262224DFB9AA9F142596987E5-E7"
            McAfeeArguments                    = "/nonsoe /quiet"
            ExtractEnsureString                = 'Present'
            ExtractForce                       = $True

            #SMSLoad Folder data:
            SMSLoadDriveLetter                 = 'F'
            SMSLoadFolder                      = 'SMSLoad'
            SMSLoadEnsureString                = 'Present'
            SMSLoadType                        = 'Directory'
            SFSRelease                         = '8.0'
            SFSFoundationSourceFolder          = 'SFS Foundation'
            SFSFoundationRequired              = $True
            NomadFoundationSourceFolder        = 'Nomad Foundation'
            NomadFoundationConfigSourceString  = 'Config\Source'
            NomadFoundationConfigUtilsString   = 'Config\Utils'
            NomadFoundationRequired            = $True
            LAPMSourceFolder                   = 'LAPM'
            LAPMConfigUtilsString              = 'Config\Utils'
            LAPMRequired                       = $True
            BasicSharesFullAccessPermissionsTo = 'Everyone'
            ConfigFolder                       = 'Config'
            CMTraceSourcePath                  = 'Source\CMInstall\CMTrace.exe'
            CMTraceDestinationPath             = 'C:\Windows\CMTrace.exe'
            CMTraceDestinationEnsureString     = 'Present'
            CMTraceDestinationForce            = $True
            CMTraceType                        = 'File'
            CMTraceKey1                        = 'HKCU:\SOFTWARE\Microsoft\Trace32'
            CMTraceKey2                        = 'HKCU:\SOFTWARE\Classes\.log'
            CMTraceKey3                        = 'HKCU:\SOFTWARE\Classes\.lo'
            CMTraceKey4                        = 'HKCU:\SOFTWARE\Classes\Log.File\shell\open\command'
            CMTraceValueName1                  = 'Register File Types'
            CMTraceValueNameBlank              = ''
            CMTraceValueType                   = 'String'
            CMTraceValueData1                  = '0'
            CMTraceValueData2And3              = 'Log.File'
            CMTraceValueData4                  = '"C:\windows\CMTrace.exe" "%1"'
            CMTraceRegistryEnsureString        = 'Present'
            CMTraceRegistryForce               = $True

            #.Net Framework data:
            FeatureNames                       = @("NET-Framework-Features", "NET-Framework-45-Features", "NET-WCF-Services45")
            FeaturesEnsureString               = 'Present'
            DotNetFramework35Source            = 'C:\Sources\sxs'
            IncludeAllSubFeatureChoice         = $True

            #CSCCM PowerShell Module data:
            CSCCMPSModuleDestinationPath1      = 'C:\Windows\System32\WindowsPowerShell\v1.0\Modules\CSCCM'
            CSCCMPSModuleDestinationPath2      = 'C:\Windows\SysWOW64\WindowsPowerShell\v1.0\Modules\CSCCM'
            CSCCMPSModuleEnsureString          = 'Present'
            CSCCMPSModuleForce                 = $True
            CSCCMPSModuleRecurse               = $True
            CSCCMPSModuleSourcePath            = 'Utils\PSModules\CSCCM'
            CSCCMPSModuleType                  = 'Directory'

            #ADResources.xml data:
            ADResourcesXMLPath                 = 'Settings\ADResources.xml'
            ADResourceXMLUseTokenFiles         = $False

            #CMConfig.xml data:
            CMConfigXMLPath                    = 'Settings\CMConfig.xml'
            CMConfigXMLUseTokenFiles           = $False
            KMSServerIPAddressAndPort          = ''
            Win7ProductKey                     = ''
            Win81ProductKey                    = ''
            Win10EntProductKey                 = ''
            Win10ProProductKey                 = ''
            Win10LTSBProductKey                = ''

            #ConfiMgr Unattended File data:
            UnattendedFileDestinationPath      = 'Settings\Parameters'
            UnattendedFileEnsureString         = 'Present'
            UnattendedFileForce                = $True
            UnattendedFileSourcePath           = 'Settings\Parameters\NAME-OF-THIS-SERVER(PRI).TXT'
            UnattendedFileType                 = 'File'
            UnattendedFileUseTokenFiles        = $False
            Action                             = 'InstallPrimarySite'
            SAActive                           = '1'
            CurrentBranch                      = '1'
            ProductID                          = 'BXH69-M62YX-QQD6R-3GPWX-8WMFY'
            SMSInstallDir                      = 'Microsoft Configuration Manager'
            RoleCommunicationProtocol          = 'HTTPorHTTPS'
            ClientsUsePKICertificate           = '1'
            PrerequisiteComp                   = '1'
            PrerequisitePath                   = 'Source\CMInstall\Updates'
            MobileDeviceLanguage               = '0'
            ManagementPointProtocol            = 'HTTP'
            DistributionPointProtocol          = 'HTTP'
            DistributionPointInstallIIS        = '1'
            AdminConsole                       = '1'
            JoinCEIP                           = '0'
            SQLServerName                      = 'devsfssql001'
            DatabaseName                       = 'MWSCENTERMWS02\CM'
            SQLSERVERPORT                      = '49002'
            SQLSSBPort                         = '4022'
            CloudConnector                     = '1'
            UseProxy                           = '0'
            ProxyName                          = ''
            ProxyPort                          = ''
            CCARSiteServer                     = ''
            MPOP_SMS_ENTERPADMIN               = 'FULL ADMINISTRATOR'
            MPOP_SMS_IMAGESADMIN               = 'Operating System Deployment Manager'
            MPOP_SMS_PATCHADMIN                = 'Endpoint Protection Manager,Software Update Manager'
            MPOP_SW_DEPLADMIN                  = 'Application Administrator,Application Deployment Manager,Application Author'
            MPOP_SW_SUPPORT                    = 'Read-only Analyst,Remote Tools Operator'
            Lastrow                            = 'TRUE'

            #SMSLoad, MPApplModel & MPPackages Folders Advanced Permissions data:
            SMSLoadNTFSPermsInheritanceEnabled = $False
            SMSLoadNTFSPreserveInherited       = $False
            SFSLoadPermissionsEnsureString     = 'Present'
            PermDName3                         = 'EnterpAdmin-SCCM'
            PermDName4                         = 'SWDEPLADMIN-SCCM'
            PermDName5                         = 'PATCHADMIN-SCCM'
            RoleUName1                         = 'ROLE-U'
            RoleUName2                         = 'SCCMSYSTEMGROUP-SCCM'
            SystemIdentity                     = 'System'
            UsersIdentity                      = 'Users'
            SFSLoadPermissionsAccessControlType= 'Allow'
            SFSLoadPermissionsFileSystemRights1= 'ReadAndExecute'
            SFSLoadPermissionsFileSystemRights2= 'FullControl'
            SFSLoadPermissionsInheritance      = 'ThisFolderSubfoldersAndFiles'
            SFSLoadPermsNoPropagateInherit     = $False

            # SQL files are in the same repo but nested in the SQL folder
            ArtifactoryURLSql                  = 'https://artifactory.csc.com/artifactory/dsmce-generic/SQL/'
            ArtifactorySqlSWArray              = @('sqlncli.msi')

            # SQL Native Client 
            SQLNativeClientMsi                 = 'C:\Windows\Temp\sqlncli.msi'       # this must be the full path to the MSI
            SQLNativeClientProductID           = 'B9274744-8BAE-4874-8E59-2610919CD419'
            SQLNativeClientArguments           = '/qn IACCEPTSQLNCLILICENSETERMS=YES'
            SQLNativeClientName                = 'Microsoft SQL Server 2012 Native Client ' # space at end of name is required
            
            # TLS 1.2 registry settings
            TLSServerEnsureString              = "Present"
            TLSClientEnsureString              = "Present"
            TLSpropertyName                    = 'Enabled'
            TLSpropertyValue                   = '1'
            TLSpropertyType                    = 'Dword'
            TLSServerKey                       = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server"    
            TLSClientKey                       = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client"    


        }
    )
}