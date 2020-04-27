@{
    AllNodes = @(
        #Single Customer Domain data for Active Directory:
        @{
            #Single Customer Domain data for Active Directory that will be frequently updated for deployments:
            NodeName                           = 'devwlddc001'
            DomainName                         = 'wld.ad'
            DomainNetbiosName                  = 'WLD'
            CustCode                           = 'WLD'
            #SCCMPrimaryHostName                = 'devsfscfgmgr001'
            #SQLServerHostName                  = 'devsfssql001' 
            #PrestageDriveLetter                = 'F'
            ServiceAccounts                    = @('z-da-wld-install','z-da-sco-schedtsk')
            UserAccounts                       = @('LabAdmin')
            ArtifactoryURL                     = 'https://artifactory.csc.com/artifactory/dsmce-generic/'
            ArtifactoryKey                     = 'AKCp5cc72DjHsUPNNKC1VPcQwQdasfxNAa5MbRd8pu1pUnepBfjrQFaRSGXethBp6jbL4M5Mn'
            
            #Node data:
            Role                               = 'DC'
            
            #AD Roles data:
            EnsureString                       = 'Present'
            FeatureNames                       = @("AD-Domain-Services", "GPMC", "RSAT-ADDS")
            IncludeAllSubFeatureChoice         = $True

            #Domain & Wait for Domain data:
            DBAndLogPath                       = 'C:\Windows\NTDS'
            SysvolPath                         = 'C:\Windows\SYSVOL'
            DomainAndForestMode                = 'WinThreshold'
            RebootRetryCountDC                 = 2
            RetryCountDC                       = 10
            RetryIntervalSecDC                 = 60
            
            #DNS Server Address data:
            DNSServerAddressFamily             = 'IPv4'
            DNSServerAddressInterfaceAlias     = 'Ethernet'
            DNSServerAddress                   = '10.100.1.10' 
            DNSServerAddressValidate           = $True
            
            #Sites & Subnets data:
            ADSiteNames                        = @('Site1')
            ADSiteEnsureString                 = 'Present'
            ADSiteRenameDefaultFirstSiteName   = $True
            ADReplicationSubnetNames           = @('10.100.0.0/24')
            ADReplicationSubnetEnsureString    = 'Present'
            ADReplicationSubnetLocations       = @('DataCenter1') 
            
            #Common OUs data:
            ProtectedFromAccidentalDeletion    = $True
            OUEnsureString                     = 'Present'

            #Top Level OUs data:
            TopLevelOUs                        = 'Customer','Administration'

            #OU data under Administration OU:
            UnderAdministrationOUs             = 'Permissions','Roles'
            UnderAdministrationOUPath          = 'OU=Administration'

            #OU data under Customer OU:
            UnderCustomerOUs                   = 'Application Groups','Service Accounts','Workstations','Servers'
            UnderCustomerOUPath                = 'OU=Customer'

            #OU data under Application Groups OU:
            UnderApplicationGroupsOUs          = 'Entitlement Groups'
            UnderApplicationGroupsOUPath       = 'OU=Application Groups,OU=Customer'
            
            #OU data under Workstations OU:
            UnderWorkstationsOUs               = 'PC Devices','VDS','HorizonSuite'
            UnderWorkstationsOUPath            = 'OU=Workstations,OU=Customer'
            
            #OU data under Servers OU:
            UnderServersOUs                    = 'SCCM','Database'
            UnderServersOUPath                 = 'OU=Servers,OU=Customer'

            #OU data under PC Devices OU:
            UnderPCDevicesOUs                  = 'Desktop','Laptop','Tablet'
            UnderPCDevicesOUPath               = 'OU=PC Devices,OU=Workstations,OU=Customer'
            
            #OU data under VDS OU:
            UnderVDSOUs                        = 'Premium'
            UnderVDSOUPath                     = 'OU=VDS,OU=Workstations,OU=Customer'

            #Common Service Accounts & User Accounts data:
            AccountsEnsureString               = 'Present'
            AccountsOUPath                     = 'OU=Service Accounts,OU=Customer'
            AccountsEnabled                    = $True
            AccountsPasswordNeverExpires       = $True
            AccountsPasswordCannotChange       = $True
            AccountsPasswordNeverResets        = $True

            #ConfigMgr Computer Object data:
            CMComputerObjectEnabled            = $True
            CMComputerObjectEnsureString       = 'Present'
            CMComputerObjectPath               = 'OU=SCCM,OU=Servers,OU=Customer'

            #SQLServer Computer Object data:
            SQLComputerObjectEnabled           = $True
            SQLComputerObjectEnsureString      = 'Present'
            SQLComputerObjectPath              = 'OU=Database,OU=Servers,OU=Customer'

            #Common Groups data:
            GroupEnsureString                  = 'Present'
            DomainLocalGroupScope              = 'DomainLocal'
            UniversalGroupScope                = 'Universal'
            EntitlementGroupsOUPath            = 'OU=Entitlement Groups,OU=Application Groups,OU=Customer'
            PermissionsOUPath                  = 'OU=Permissions,OU=Administration'
            RolesOUPath                        = 'OU=Roles,OU=Administration'

            #ROLE-D Group data under Roles OU:
            RoleDName1                         = 'ROLE-D'
            RoleDName2                         = 'CLIENTSADMIN-CLIENTS'

            #ROLE-G Group data under Roles OU:
            RoleGName1                         = 'ROLE-G'
            RoleGName2                         = 'CMAGENT-SCCM'
            RoleGName3                         = 'CMPRESTAGE-SCCM'
            RoleGName4                         = 'ENTERPADMIN-SCCM'
            RoleGName5                         = 'IMAGESADMIN-SCCM'
            RoleGName6                         = 'PATCHADMIN-SCCM'
            RoleGName7                         = 'REPORTSVIEWERS-SCCM'
            RoleGName8                         = 'SVCCMNAA-ACCOUNT'
            RoleGName9                         = 'SVCCMPRESTAGE-ACCOUNT'
            RoleGName10                        = 'SVCJOINDOM-ACCOUNT'
            RoleGName11                        = 'SVCSRS-ACCOUNT'
            RoleGName12                        = 'SWDEPLADMIN-SCCM'
            RoleGName13                        = 'SWSUPPORT-SCCM'
            RoleGName14                        = 'WindowsWkstAdmin'
            RoleGName15                        = 'svc-cmnwmmc-account'
            
            #BUILTIN Group data under Builtin Container:
            BuiltinName1                       = 'Windows Authorization Access Group'

            #ROLE-U Group data under Roles OU:
            RoleUName1                         = 'ROLE-U'
            RoleUName2                         = 'SCCMSYSTEMGROUP-SCCM'

            #APPL-D Group data under Entitlement Groups OU:
            ApplDName1                         = 'APPL-D'
            ApplDName2                         = 'CSCCMAgent'

            #DATA-D Group data under Permissions OU:
            DataDName1                         = 'DATA-D'
            DataDName2                         = 'Prestage_M'
            DataDName3                         = 'SCCM-DebugFolder'
            DataDName4                         = 'SCCM-TEMP-Folder'
  
            #PERM-D Group data under Permissions OU:
            PermDName1                         = 'PERM-D'
            PermDName2                         = 'EnterpAdmin-SCCM'
            PermDName3                         = 'FullControlAll-SystemManagement'
            PermDName4                         = 'FullControlComp-PC Devices'
            PermDName5                         = 'FullControlComp-HorizonSuite'
            PermDName6                         = 'FullControlComp-VDS'
            PermDName7                         = 'FullControlGroup-SCCM'
            PermDName8                         = 'IMAGESADMIN-SCCM'
            PermDName9                         = 'LocalAdmin-SCCM'
            PermDName10                        = 'PATCHADMIN-SCCM'
            PermDName11                        = 'SQLSYSADMIN-SQL'
            PermDName12                        = 'SWDEPLADMIN-SCCM'
            PermDName13                        = 'SWSUPPORT-SCCM'

            #System Management Container Permissions data:
            # SMCPermissionsEnsureString         = 'Present'
            # SMCPermissionsPath                 = 'CN=System Management,CN=System'
            # SMCPermissionsADRights             = 'GenericAll'
            # SMCPermissionsAccessControlType    = 'Allow'
            # SMCPermissionsObjectType           = '00000000-0000-0000-0000-000000000000'
            # SMCPermissionsADSecurityInheritance= 'All'
            # SMCPermissionsInheritedObjectType  = '00000000-0000-0000-0000-000000000000'

            #PC Devices OU Permissions data:
            # PCDPermissionsEnsureString         = 'Present'
            # PCDPermissionsPath                 = 'OU=PC Devices,OU=Workstations,OU=Customer'
            # PCDPermissionsADRights             = 'CreateChild', 'DeleteChild'
            # PCDPermissionsAccessControlType    = 'Allow'
            # PCDPermissionsObjectType           = '00000000-0000-0000-0000-000000000000'
            # PCDPermissionsADSecurityInheritance= 'All'
            # PCDPermissionsInheritedObjectType  = '00000000-0000-0000-0000-000000000000'

            #HorizonSuite OU Permissions data:
            # HSPermissionsEnsureString          = 'Present'
            # HSPermissionsPath                  = 'OU=HorizonSuite,OU=Workstations,OU=Customer'
            # HSPermissionsADRights              = 'CreateChild', 'DeleteChild'
            # HSPermissionsAccessControlType     = 'Allow'
            # HSPermissionsObjectType            = '00000000-0000-0000-0000-000000000000'
            # HSPermissionsADSecurityInheritance = 'All'
            # HSPermissionsInheritedObjectType   = '00000000-0000-0000-0000-000000000000'

            #VDS OU Permissions data:
            # VDSPermissionsEnsureString         = 'Present'
            # VDSPermissionsPath                 = 'OU=VDS,OU=Workstations,OU=Customer'
            # VDSPermissionsADRights             = 'CreateChild', 'DeleteChild'
            # VDSPermissionsAccessControlType    = 'Allow'
            # VDSPermissionsObjectType           = '00000000-0000-0000-0000-000000000000'
            # VDSPermissionsADSecurityInheritance= 'All'
            # VDSPermissionsInheritedObjectType  = '00000000-0000-0000-0000-000000000000'

            #Workstations OU Permissions data:
            # WKSPermissionsEnsureString         = 'Present'
            # WKSPermissionsPath                 = 'OU=Workstations,OU=Customer'
            # WKSPermissionsADRights             = 'CreateChild', 'DeleteChild'
            # WKSPermissionsAccessControlType    = 'Allow'
            # WKSPermissionsObjectType           = '00000000-0000-0000-0000-000000000000'
            # WKSPermissionsADSecurityInheritance= 'All'
            # WKSPermissionsInheritedObjectType  = '00000000-0000-0000-0000-000000000000'

            #Entitlement Groups OU Permissions data:
            # EGPermissionsEnsureString          = 'Present'
            # EGPermissionsPath                  = 'OU=Entitlement Groups,OU=Application Groups,OU=Customer'
            # EGPermissionsADRights              = 'CreateChild', 'DeleteChild'
            # EGPermissionsAccessControlType     = 'Allow'
            # EGPermissionsObjectType            = '00000000-0000-0000-0000-000000000000'
            # EGPermissionsADSecurityInheritance = 'All'
            # EGPermissionsInheritedObjectType   = '00000000-0000-0000-0000-000000000000'

            #SCCM OU Permissions data:
            # SCCMPermissionsEnsureString        = 'Present'
            # SCCMPermissionsPath                = 'OU=SCCM,OU=Servers,OU=Customer'
            # SCCMPermissionsADRights            = 'GenericAll'
            # SCCMPermissionsAccessControlType   = 'Allow'
            # SCCMPermissionsObjectType          = '00000000-0000-0000-0000-000000000000'
            # SCCMPermsADSecurityInheritance     = 'All'
            # SCCMPermissionsInheritedObjectType = '00000000-0000-0000-0000-000000000000'

            #Packages Download, Extract & Execution data:
            ArtifactoryArray                   = @('CrowdStrikeFalconWindowsSensor_4.22.8504.zip', 'DXC-ENG-McAfeeEndpointSecurity-10.6.1-GBL-R1.zip', 'IEMResource_Client_9.2.5.130.zip', 'extadsch.zip', 'vcredist_x64.zip')
            CrowdStrikeFalconWindowsSensorZip  = 'CrowdStrikeFalconWindowsSensor_4.22.8504.zip'
            McAfeeZip                          = 'DXC-ENG-McAfeeEndpointSecurity-10.6.1-GBL-R1.zip'
            IEMResourceClientZip               = 'IEMResource_Client_9.2.5.130.zip'
            SchemaZip                          = 'extadsch.zip'
            VCRedistZip                        = 'vcredist_x64.zip'
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
            SchemaFile                         = 'extadsch.exe'
            SchemaLogFileName                  = 'extadsch.log'
            VCRedistFile                       = 'vcredist_x64.exe'
            VCRedistProductID                  = '929FBD26-9020-399B-9A7A-751D61F0B942'
            VCRedistArguments                  = "/install /quiet /norestart"
            VCRedistInstallEnsureString        = "Present"
            CrowdStrikeFalconWindowsSensorArgs = "/install /quiet /norestart CID=35C43E7262224DFB9AA9F142596987E5-E7"
            McAfeeArguments                    = "/nonsoe /quiet" # for SOE server just use '/quiet'
            ExtractEnsureString                = 'Present'
            ExtractForce                       = $True

            #Service Principal Names data:
            SPNPrefix                          = 'MSSQLSvc'
            SPN1                               = 'MWSSCENTER'
            SPN1Suffix                         = '02'
            SPN2                               = 'MWSSHARED'
            SPN2Suffix                         = '04'
            SPN3                               = 'MWSSSRS'
            SPN3Suffix                         = '05'
            SPN4                               = '49002'
            SPN5                               = '49004'
            SPN6                               = '49005'
            SPNEnsureString                    = 'Present'
        }
    )
}