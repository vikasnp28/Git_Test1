@{
  AllNodes = @(
    @{
        # Node Specific Data
        NodeName                           = 'devwldsql001' 
        Role                               = 'SQL'

        executeSecuritySWinstallConfig     = $true
        executeADConfig                    = $true
        executeSQLConfig                   = $true
        
        #SQL Server data for Active Directory:
        CustCode                           = 'WLD' 
        DomainToJoin                       = 'wld.ad' 
        ADDomainController                 = 'devwlddc001' 

        # Computer objects - Note: append $ symbol to end of computer name
        PRIserver                          = 'devsfscfgmgr001$' 
        # The CAS server is optional based on size of deployment
        # As empty strings are not allowed set this to the PRI server instead of empty string
        CASserver                          = 'devsfscfgmgr001$'
                
        #DNS Server Address data:
        DNSServerAddressFamily             = 'IPv4'
        DNSServerAddressInterfaceAlias     = 'Ethernet'
        DNSServerAddress                   = '10.100.1.10'
        DNSServerAddressValidate           = $True
    
        #Packages Download, Extract & Execution data:
        ArtifactorySecuritySWArray         = @('CrowdStrikeFalconWindowsSensor_4.22.8504.zip', 'DXC-ENG-McAfeeEndpointSecurity-10.6.1-GBL-R1.zip', 'IEMResource_Client_9.2.5.130.zip')
        CrowdStrikeFalconWindowsSensorZip  = 'CrowdStrikeFalconWindowsSensor_4.22.8504.zip'
        McAfeeZip                          = 'DXC-ENG-McAfeeEndpointSecurity-10.6.1-GBL-R1.zip'
        IEMResourceClientZip               = 'IEMResource_Client_9.2.5.130.zip'
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
                
        #Domain Join and Wait for Domain data:
        OUPath                             = 'OU=Database,OU=Servers,OU=Customer'
        RebootRetryCountSQL                = 2
        RetryCountSQL                      = 10
        RetryIntervalSecSQL                = 60

        #Local Administrator Group data:
        # AJ: remove my equiv vars
        LAGroupName                        = 'Administrators'
        LAGroupEnsureString                = 'Present'
        PermDName1                         = 'PERM-D'
        PermDName2                         = 'LocalAdmin-SCCM'

        #User Rights Assignment data:
        # AJ: merge with sql vars and values hosting these same accounts
        #ServiceAccounts                    = @('z-da-CSCCM-sql-agent','z-da-CSCCM-sql-brw','z-da-csccm-sql-svc','z-da-csccm-sqlssrs')
        LogOnAsAService                    = 'Log_on_as_a_service'
        LogOnAsABatchJob                   = 'Log_on_as_a_batch_job'
        DenyLogOnLocally                   = 'Deny_log_on_locally'
        UserRightsEnsureString             = 'Present'
        UserRightsEnforcement              = $False

        #Accounts - Note: Domain name will be prefixed in the configuration so not required here
        InstallerAccount                   = 'z-da-wld-install'
        #CMsvcReportAccount                 = 'z-da-cmsvcreport'             # also acts as the identity for the SSRS service
        #WebstoreAdmAccount                 = 'z-da-webstore-adm'

        # SQL related Service Accounts - Note: Domain name will be prefixed in the configuration so not required here
        # AJ: the below should be replaced with the AD keys in the AD config
        #SQLEngineServiceAccountKey         = 'sqlServiceAccount'  # 'z-da-csccm-sql-svc'
        #SQLAgentServiceAccountKey          = 'sqlAgentAccount'    # 'z-da-csccm-sql-agent'
        #SQLRsServiceAccountKey             = 'sqlRsAccount'       # 'z-da-csccm-sqlssrs'

        # Product ID used to support install of SQL Server Management Studio
        SSMSproductID                      = '91a1b895-c621-4038-b34a-01e7affbcb6b'

        # the list of drives that the NO_SMS_ON_DRIVE.SMS will only be created on 
        validNoSMSDrives                   = @("C:\")                 
        
        # Artifactory 
        ArtifactoryDownloadPath            = 'C:\SQL2016'
        ArtifactorySqlSWArray              = @('en_sql_server_2016_standard_with_service_pack_1_x64_dvd_9540929.iso', 'SSMS-Setup-ENU.exe', 'sqlncli.msi')
        ArtifactorySqlSPArray              = @('SQLServer2016SP2-KB4052908-x64-ENU.exe', 'SQLServer2016-KB4495256-x64.exe')
        ArtifactSQLiso                     = 'en_sql_server_2016_standard_with_service_pack_1_x64_dvd_9540929.iso'
        ArtifactSSMS                       = 'SSMS-Setup-ENU.exe'
        ArtifactSQLSP                      = 'SQLServer2016SP2-KB4052908-x64-ENU.exe'
        ArtifactSQLCU                      = 'SQLServer2016-KB4495256-x64.exe'
        Artifact7ZipExe                    = '7z.exe'
        Artifact7ZipDll                    = '7z.dll'
        ArtifactoryKey                     = 'AKCp5cckfBtRN2taRZtjvJRV85HqNkt4n1FsCnNMrJ8MFSEDTS5idqF1eAA21ww5REjJ9ErxX'
        # Root of the Artifactory repo
        ArtifactoryURL                     = 'https://artifactory.csc.com/artifactory/dsmce-generic/'
        # SQL files are in the same repo but nested in the SQL folder
        ArtifactoryURLSql                  = 'https://artifactory.csc.com/artifactory/dsmce-generic/SQL/'
        # SQL files are in the same repo but nested in the SQL folder
        ArtifactoryURLTools                = 'https://artifactory.csc.com/artifactory/dsmce-generic/Tools/'
        
        # SQL related windows Features:
        EnsureString                       = 'Present'
        SQLDependentFeatures               = @("NET-Framework-45-Core")
#        SQLDependentFeatures               = @("NET-Framework-Core", "NET-Framework-45-Core")
        #FeatureSourcePath                  = 'C:\Windows\WinSxs'
               
        # AD Groups
        LocalAdministratorsGroupName       = 'Administrators'

        # Unzip
        ExtractPath                        = 'C:\SQL2016'

        #region SQL installation

        # SQL Features
        Action                             = 'Install'

        sqlFeaturesStd                     = 'SQLENGINE,DQ,FullText'     
        sqlFeaturesSSRS                    = 'SQLENGINE,DQ,FullText,RS'

        # Install media - REPLACE SQLiso and SSMSiso with Artifactoruy DL related vars
        # SQLiso                             = 'C:\SQL2016'                    # this must be to the folder where the SQL iso has been unzipped to
        SSMSiso                            = 'C:\SQL2016\SSMS-Setup-ENU.exe' # this must be the full path to the SSMS executable
        UpdateSource                       = '.\Updates'                     # path to the SQL Servce Pack and/or CU relative to the SQLiso variable above
        UpdateEnabled                      = 'True'
        SQLSetUpExe                        = 'SSMS-Setup-ENU'

        NO_SMS_ON_DRIVE_Filename           = 'NO_SMS_ON_DRIVE.SMS'

        # SQL install file and binary paths, eg F:\SQL Server\MWSCENTERSFS02\MSSQL\
        # Note that the SQL instance name forms part of the path
        # We do not want the 'NO_SMS_ON_DRIVE.SMS' to be created on this driver
        SQLInstallSharedDrive              = 'C:'             
        SQLInstallSharedBaseFolder         = 'SQL Server'     
        InstallSharedDir                   = 'MSSQL'
        InstallSharedWOWDir                = 'MSSQL (x86)'
        InstanceDir                        = 'MSSQL'

        # User Data and Log + Backup file paths, eg C:\MWSCENTERSFS02\SQL1\Data1\
        # Note that the SQL instance name forms part of the path
        baseDataLogDrive                   = "C:\"                # note that instance name is appended to this variable in the configuration
        userdbFoldername                   = "SQL1\Data1\"
        userlogFoldername                  = "SQL1\Log1\"
        backupdbFoldername                 = "SQL1\Backup\"
        # Temp Data and Log file paths, eg C:\MWSCENTERSFS02\MSSQL\Data\
        # Note that the SQL instance name forms part of the path
        tempdbFoldername                   = "MSSQL\DATA"
        templogFoldername                  = "MSSQL\DATA"

        # General settings
        sqlCollation                       = 'SQL_Latin1_General_CP1_CI_AS'
        ForceReboot                        = $false

        # SQL Service Start up type
        SqlSvcStartupType                  = 'Automatic'
        AgtSvcStartupType                  = 'Automatic'
        RsSvcStartupType                   = 'Automatic'
        BrowserSvcStartupType              = 'Automatic'

        # Temp db settings
        SqlTempdbFileCount                 = 4
        SqlTempdbFileSize                  = 256
        SqlTempdbFileGrowth                = 25    # 10% of initial size
        SqlTempdbLogFileSize               = 256
        SqlTempdbLogFileGrowth             = 25    # 10% of initial size

        # SQL Static port Settings
        ProtocolName                       = 'Tcp'
        IsEnabled                          = $true
        TCPDynamicPort                     = $false
        RestartService                     = $true

        # SQL Static port Numbers
        SQLInstanceName                    = "MWSWALDO20"

        # SQL Static port Numbers
        Portnum                            = 49020

        # Waldo Database
        DatabaseName                       = "Waldo_FrW"

        SchedTaskUser                      = 'z-da-sco-schedtsk'
        LocalAdminGroup                    = 'Perm-D-DIL-LocalAdmin-SCO'

        #region SQL installation

        # SQL Native Client 
        SQLNativeClientMsi                 = 'C:\SQL2016\sqlncli.msi'       # this must be the full path to the MSI
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