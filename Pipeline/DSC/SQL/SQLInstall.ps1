
Configuration SQLInstallConfig
{

     param (
            [Parameter(Mandatory = $true)]
            [String] $sqlInstanceName,

            [Parameter(Mandatory = $true)]
            [Uint16] $portNumber,

            [Parameter(Mandatory = $true)]
            [String] $sqlFeatures
     )


    Import-DscResource -ModuleName SqlServerDsc -ModuleVersion 13.1.0.0

    # PS Credential Objects for SQL related services. Stored in Azure Credential
    #$sqlServiceAccountCredential    = Get-AutomationPSCredential -Name 'SQLServiceAccountCreds'
    #$sqlAgentAccountCredential      = Get-AutomationPSCredential -Name 'SQLAgentAccountCreds'
    #$sqlRsAccountCredential         = Get-AutomationPSCredential -Name 'SQLRSAccountCreds'
    $sqlServiceAccountCredential    = Get-AutomationPSCredential -Name 'DomainJoinCreds'
    $sqlAgentAccountCredential      = Get-AutomationPSCredential -Name 'DomainJoinCreds'

    #Write-Verbose "sqlServiceAccountCredential: $sqlServiceAccountCredential"
    #Write-Verbose "sqlAgentAccountCredential: $sqlAgentAccountCredential"
    #Write-Verbose "sqlRsAccountCredential: $sqlRsAccountCredential"
    
    $baseDataLogPath         = "$($Node.baseDataLogDrive)$($sqlInstanceName)"
    $baseInstallPath         = "$($Node.SQLInstallSharedDrive)\$($Node.SQLInstallSharedBaseFolder)\$($sqlInstanceName)"

    Write-Verbose "baseDataLogPath: $baseDataLogPath"
    Write-Verbose "baseInstallPath: $baseInstallPath"

    # need to prefix domain otherwise sql creates login with local account server\login
    $sqlSysAdmins = @("$($Node.DomainToJoin)\$($Node.InstallerAccount)")
    #$sqlSysAdmins           = @($SFSinstallerAccount, 
                                # $PRIserver, 
                                # $CMsvcReportAccount, 
                                # $SCCMEnterpAdminAccount, 
                                # $WebstoreAdmAccount)

    # Write-Verbose "SFSinstallerAccount: $SFSinstallerAccount"
    # Write-Verbose "PRIserver: $PRIserver"
    # Write-Verbose "PRIserver: $PRIserver"
    # Write-Verbose "CMsvcReportAccount: $CMsvcReportAccount"
    # Write-Verbose "WebstoreAdmAccount: $WebstoreAdmAccount"

    # Install SQL Server

    SqlSetup 'SQL-Instance'
    {
   
        InstanceName                = $sqlInstanceName
        Features                    = $sqlFeatures

        Action                      = $Node.Action
        # Product key for licensed installations.
        # Tested with blank to support cases where key is pre-pidded
        # ProductKey                  = 'B9GQY-GBG4J-282NY-QRG4X-KQBCR'

        InstallSharedDir            = "$($baseInstallPath)\$($Node.userdbFoldername)"
        InstallSharedWOWDir         = "$($baseInstallPath)\$($Node.InstallSharedWOWDir)"
        InstanceDir                 = "$($baseInstallPath)\$($Node.InstanceDir)"

        InstallSQLDataDir           = $baseDataLogPath
        SQLUserDBDir                = "$($baseDataLogPath)\$($Node.userdbFoldername)"
        SQLUserDBLogDir             = "$($baseDataLogPath)\$($Node.userlogFoldername)"
        SQLTempDBDir                = "$($baseDataLogPath)\$($Node.tempdbFoldername)"
        SQLTempDBLogDir             = "$($baseDataLogPath)\$($Node.templogFoldername)"
        SQLBackupDir                = "$($baseDataLogPath)\$($Node.backupdbFoldername)"

        SQLCollation                = $Node.sqlCollation

        SourcePath                  = $Node.ArtifactoryDownloadPath
        SQLSysAdminAccounts         = $sqlSysAdmins

        UpdateEnabled               = $Node.UpdateEnabled
        UpdateSource                = $Node.UpdateSource
        ForceReboot                 = $Node.ForceReboot

        SQLSvcAccount               = $sqlServiceAccountCredential
        AgtSvcAccount               = $sqlAgentAccountCredential
        #RSSvcAccount                = $sqlRsAccountCredential
        
        SqlSvcStartupType           = $Node.SqlSvcStartupType
        AgtSvcStartupType           = $Node.AgtSvcStartupType
        #RsSvcStartupType            = $Node.RsSvcStartupType
        BrowserSvcStartupType       = $Node.BrowserSvcStartupType

        SqlTempdbFileCount          = $Node.SqlTempdbFileCount
        SqlTempdbFileSize           = $Node.SqlTempdbFileSize
        SqlTempdbFileGrowth         = $Node.SqlTempdbFileGrowth     
        SqlTempdbLogFileSize        = $Node.SqlTempdbLogFileSize
        SqlTempdbLogFileGrowth      = $Node.SqlTempdbLogFileGrowth     

        PsDscRunAsCredential        = $DomainJoinCredential
    }

    # Configure SQL Server Static Port
    SqlServerNetwork 'SQL-StaticPort'
    {
        InstanceName                = $sqlInstanceName
        ProtocolName                = $Node.ProtocolName
        IsEnabled                   = $Node.IsEnabled
        TCPDynamicPort              = $Node.TCPDynamicPort
        TCPPort                     = $portNumber
        RestartService              = $Node.RestartService

        DependsOn                   = '[SqlSetup]SQL-Instance'

    }

    # Enable SQL Named Pipes
    # Script EnableNamedPipes
    # {
    #     GetScript = {
    #         Import-Module "sqlps"

    #         $smo = 'Microsoft.SqlServer.Management.Smo.'  
    #         $wmi = new-object ($smo + 'Wmi.ManagedComputer').  

    #         # Enable the named pipes protocol for the default instance.  
    #         $uri = "ManagedComputer[@Name='$($using:Node.NodeName)']/ ServerInstance[@Name='$using:sqlInstanceName']/ServerProtocol[@Name='Np']"  
    #         $Np = $wmi.GetSmoObject($uri)  
    #         $isNamedPipesEnabled = $Np.IsEnabled
    #         Write-Verbose "Get: Is Named Pipes Enabled: $isNamedPipesEnabled"

    #         return @{ Result = [string]$isNamedPipesEnabled }
    #     }
    #     TestScript = {
    #         Import-Module "sqlps"

    #         $smo = 'Microsoft.SqlServer.Management.Smo.'  
    #         $wmi = new-object ($smo + 'Wmi.ManagedComputer').  

    #         # Enable the named pipes protocol for the default instance.  
    #         $uri = "ManagedComputer[@Name='$($using:Node.NodeName)']/ ServerInstance[@Name='$using:sqlInstanceName']/ServerProtocol[@Name='Np']"  
    #         $Np = $wmi.GetSmoObject($uri)  
    #         $isNamedPipesEnabled = $Np.IsEnabled

    #         Write-Verbose "Test: For $($using:sqlInstanceName) Is Named Pipes Enabled: $isNamedPipesEnabled"

    #         if( $isNamedPipesEnabled -eq $true )
    #         {
    #             Write-Verbose "Named pipes is already enabled for Node: $($using:Node.NodeName) , SQL Instance: $using:sqlInstanceName "
    #             return $true
    #         }
    #         else
    #         {
    #             Write-Verbose "Named pipes is NOT enabled for Node: $($using:Node.NodeName) , SQL Instance: $using:sqlInstanceName "
    #             return $false
    #         }
    #     }
    #     SetScript = {
    #         Write-Verbose "Enabling Named pipes for Node: $($using:Node.NodeName) , SQL Instance: $using:sqlInstanceName "

    #         Import-Module "sqlps"

    #         $smo = 'Microsoft.SqlServer.Management.Smo.'  
    #         $wmi = new-object ($smo + 'Wmi.ManagedComputer').  

    #         # Enable the named pipes protocol for the default instance.  
    #         $uri = "ManagedComputer[@Name='$($using:Node.NodeName)']/ ServerInstance[@Name='$using:sqlInstanceName']/ServerProtocol[@Name='Np']"  
    #         $Np = $wmi.GetSmoObject($uri)  
    #         $Np.IsEnabled = $true  
    #         $Np.Alter()      
               
    #         Write-Verbose "Named pipes have been enabled for Node: $($using:Node.NodeName) , SQL Instance: $using:sqlInstanceName "
    #     }

    #     DependsOn = '[SqlSetup]SQL-Instance'
    # }
}

Configuration SQLInstall
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    # AD related resources
    Import-DscResource -ModuleName xActiveDirectory -ModuleVersion 3.0.0.0
    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 6.4.0.0
    Import-DscResource -ModuleName SecurityPolicyDsc -ModuleVersion 2.9.0.0
    Import-DscResource -ModuleName xReleaseManagement -ModuleVersion 1.0.0.0
    Import-DscResource -ModuleName NetworkingDsc -ModuleVersion 7.3.0.0
    Import-DscResource -ModuleName SqlServerDsc -ModuleVersion 13.1.0.0
    # Custom resources
    Import-DscResource -ModuleName DXC_BuildAutomationCommonDsc
    Import-DscResource -ModuleName DXC_SecuritySWInstallDsc

    Node ($AllNodes.Where{$_.Role -eq 'SQL'}).NodeName
    {

        # AD related variables
        $DomainJoinCredential   = Get-AutomationPSCredential -Name 'DomainJoinCreds'
        $InstallerCredential   = Get-AutomationPSCredential -Name 'InstallerCreds'

        $SplitDomain            = $Node.DomainToJoin.split('.')[0]

        # Accounts
        # $CASserver              = "$SplitDomain\$($Node.SFSinstallerAccount)"
        # $PRIserver              = "$SplitDomain\$($Node.PRIserver)"
        # $SFSinstallerAccount    = "$SplitDomain\$($Node.SFSinstallerAccount)"
        # $CMsvcReportAccount     = "$SplitDomain\$($Node.CMsvcReportAccount)"
        # $WebstoreAdmAccount     = "$SplitDomain\$($Node.WebstoreAdmAccount)"
        # $SCCMEnterpAdminAccount = "$SplitDomain\$($Node.PermDName1)-$($Node.CustCode)-$($Node.PermDName2)"

        <# 
        This var is used to create the local folder to host the SQL SP + CU
        It must be the same as the folder name used when installing the SQL instance excluding
        the '.\' which is used during SQL install to define the path is relative.
        #>
        $SqlUpdatesFolder       = $($Node.UpdateSource) -replace ".\\", ""

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
 
        if ($Node.executeSecuritySWinstallConfig)
        {   
            File SourcesFolder
            {
                DestinationPath = $Node.SourcesFolderPath
                Ensure = $Node.SourcesFolderEnsureString
                Type = $Node.SourcesFolderType
            }

            # Download Security related software
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
        }

        if($Node.executeADConfig)
        {
            # AD Configuration
            DnsServerAddress SetDNSServerAddress
            {
                AddressFamily = $Node.DNSServerAddressFamily
                InterfaceAlias = $Node.DNSServerAddressInterfaceAlias
                Address = $Node.DNSServerAddress
                Validate = $Node.DNSServerAddressValidate
            }

            xWaitForADDomain WaitForADDomainOnSQL
            {
                DomainName = $Node.DomainToJoin
                DomainUserCredential = $DomainJoinCredential
                RebootRetryCount = $Node.RebootRetryCountSQL
                RetryCount = $Node.RetryCountSQL
                RetryIntervalSec = $Node.RetryIntervalSecSQL
                DependsOn = '[DnsServerAddress]SetDNSServerAddress'
            }
            
            Computer SQLServerDomainJoin
            {
                Name = $Node.NodeName
                Credential = $DomainJoinCredential
                DomainName = $Node.DomainToJoin
                #JoinOU = ($Node.OUPath + "," + 'DC={0},DC={1}' -f ($Node.DomainToJoin.split('.')[0]), ($Node.DomainToJoin.split('.')[1]))
                Server = ($Node.ADDomainController + '.' + $Node.DomainToJoin)
                PsDscRunAsCredential = $DomainJoinCredential
                DependsOn = '[xWaitForADDomain]WaitForADDomainOnSQL'
            }
            
            # Archive IEMFileZipExtract
            # {
            #     Destination = ($Node.SourcesFolderPath + '\')
            #     Path = ($Node.DownloadPath + '\' + $Node.IEMResourceClientZip)
            #     Ensure = $Node.ExtractEnsureString
            #     Force = $Node.ExtractForce
            #     DependsOn = '[ArtifactoryDownload]SecuritySoftwareDownload', '[Computer]SQLServerDomainJoin'
            # }
        
            # xTokenize IEMCFGTokenize
            # {
            #     path = $Node.IEMCFGSourcePath
            #     tokens = @{Relay_Control_RootServer="$($Node.IEMRelayControlRootServer)";Relay_Control_Server1="$($Node.IEMRelayControlServer1)";Relay_Control_Server2="$($Node.IEMRelayControlServer2)";RelayServer1="$($Node.IEMRelayServer1)";RelayServer2="$($Node.IEMRelayServer2)";RelaySelect_Automatic="$($Node.IEMRelaySelectAutomatic)";BESClient_ActionManager_SkipVoluntaryOnForceShutdown="$($Node.BESCliActMgrSkipVolOnForShut)";CSC_CUSTOMER_ID="$($Node.IEMCSCCustomerID)";CSC_ENVIRONMENT="$($Node.IEMCSCEnvironment)";CSC_FLEXERA_MGSFT_DOMAIN_NAME="$($Node.IEMCSCFlexeraMGSFTDomainName)";CSC_FLEXERA_MGSFT_BOOTSTRAP_DOWNLOAD="$($Node.IEMFlexeraMGSFTBootstrapDownload)"}
            #     useTokenFiles = $Node.IEMUseTokenFiles
            #     DependsOn = '[Archive]IEMFileZipExtract'
            # }

            # File IEMCFGFileCopy
            # {
            #     DestinationPath = $Node.IEMCFGDestinationPath
            #     SourcePath = $Node.IEMCFGSourcePath
            #     Checksum = $Node.IEMCFGChecksum
            #     Ensure = $Node.IEMCFGDestinationEnsureString
            #     Force = $Node.IEMCFGDestinationForce
            #     Type = $Node.IEMCFGType
            #     MatchSource = $Node.IEMCFGMatchSource
            #     DependsOn = '[xTokenize]IEMCFGTokenize'
            # }

            # xTokenize IEMAFXMTokenize
            # {
            #     path = $Node.IEMAFXMPath
            #     tokens = @{Fixlet_Site_Gather_URL="$($Node.IEMFixletSiteGatherURL)";Fixlet_Site_Report_URL="$($Node.IEMFixletSiteReportURL)";Fixlet_Site_Registration_URL="$($Node.IEMFixletSiteRegistrationURL)";BES_Mirror_Gather_URL="$($Node.IEMBESMirrorGatherURL)";BES_Mirror_Download_URL="$($Node.IEMBESMirrorDownloadURL)"}
            #     useTokenFiles = $Node.IEMUseTokenFiles
            #     DependsOn = '[Archive]IEMFileZipExtract'
            # }
            
            # Package InstallIEM
            # {
            #     Name = $Node.IEMResourceClientFile
            #     Path = ($Node.SourcesFolderPath + '\' + 'IEMResource_Client' + '\' + $Node.IEMResourceClientFile)
            #     ProductId = $Node.IEMProductID
            #     Arguments = $Node.IEMArguments
            #     Ensure = $Node.IEMInstallEnsureString
            #     DependsOn = '[Archive]IEMFileZipExtract','[xTokenize]IEMCFGTokenize','[File]IEMCFGFileCopy','[xTokenize]IEMAFXMTokenize'
            # }
            
            Group LocalAdministratorGroupPermissions
            {
                GroupName = $Node.LAGroupName
                Credential = $DomainJoinCredential
                Ensure = $Node.LAGroupEnsureString
                MembersToInclude = @("$SplitDomain\$($Node.InstallerAccount)") # @($SCCMEnterpAdminAccount, $CASserver, $PRIserver)
                DependsOn = '[Computer]SQLServerDomainJoin'
                PsDscRunAsCredential = $DomainJoinCredential
            }
    
            UserRightsAssignment LogOnAsAService
            {
                Identity = "$SplitDomain\$($Node.InstallerAccount)"
                Policy = $Node.LogOnAsAService
                Ensure = $Node.UserRightsEnsureString
                Force = $Node.UserRightsEnforcement
                DependsOn = '[Computer]SQLServerDomainJoin'
            }
    
            UserRightsAssignment LogOnAsABatchJob
            {
                Identity = "$SplitDomain\$($Node.InstallerAccount)"
                Policy = $Node.LogOnAsABatchJob
                Ensure = $Node.UserRightsEnsureString
                Force = $Node.UserRightsEnforcement
                DependsOn = '[Computer]SQLServerDomainJoin'
            }
            
            # UserRightsAssignment DenyLogOnLocally
            # {
            #     Identity = "$SplitDomain\$($Node.ServiceAccounts[0])","$SplitDomain\$($Node.ServiceAccounts[1])","$SplitDomain\$($Node.ServiceAccounts[2])","$SplitDomain\$($Node.ServiceAccounts[3])"
            #     Policy = $Node.DenyLogOnLocally
            #     Ensure = $Node.UserRightsEnsureString
            #     Force = $Node.UserRightsEnforcement
            #     DependsOn = '[Computer]SQLServerDomainJoin'
            # }
        }

        if ($Node.executeSQLConfig)
        { 

            # Setup directories
            File SetupDir {
                # This directory exists but is not visible in File Explorer
                Type            = 'Directory'
                DestinationPath = $Node.ArtifactoryDownloadPath
                Ensure          = $Node.EnsureString
    
                DependsOn = '[Computer]SQLServerDomainJoin' # '[UserRightsAssignment]DenyLogOnLocally'                  
            }

            File SetupDirUpdates {
                # This directory exists but is not visible in File Explorer
                Type            = 'Directory'
                DestinationPath = $Node.ArtifactoryDownloadPath + "\" + $SqlUpdatesFolder
                Ensure          = $Node.EnsureString 

                DependsOn       = '[File]SetupDir'
            }

            # Download Artifactory Files
            ArtifactoryDownload SQLinstallationfiles
            {
                UniqueName              = 'SQLinstallationfiles'
                DownloadZipPath         = $Node.ArtifactoryDownloadPath
                ArtifactoryFiles        = $Node.ArtifactorySqlSWArray
                ArtifactoryAccessKey    = $Node.ArtifactoryKey
                ArtifactoryRepoURL      = $Node.ArtifactoryURLSql
            
                DependsOn       = '[File]SetupDir'
            }

            ArtifactoryDownload SQLServicePack
            {
                UniqueName              = 'SQLServicePack'
                DownloadZipPath         = $Node.ArtifactoryDownloadPath + "\" + $SqlUpdatesFolder
                ArtifactoryFiles        =  $Node.ArtifactorySqlSPArray
                ArtifactoryAccessKey    = $Node.ArtifactoryKey
                ArtifactoryRepoURL      = $Node.ArtifactoryURLSql
            
                DependsOn       = '[File]SetupDir'
            }

            # Download 7zip
            ArtifactoryDownload Tools
            {
                UniqueName = 'Tools' 
                DownloadZipPath         = $Node.ArtifactoryDownloadPath
                ArtifactoryFiles        = @($Node.Artifact7ZipExe, $Node.Artifact7ZipDll)
                ArtifactoryAccessKey    = $Node.ArtifactoryKey
                ArtifactoryRepoURL      = $Node.ArtifactoryURLTools
            
                DependsOn = "[ArtifactoryDownload]SQLinstallationfiles" 
            }

            # Unzip Sql ISO
            Script "unZipSqlIso"
            {
                GetScript = 
                {
                    Write-Verbose -Message "unZipSqlIso GetScript nothing to do."         
                    @{ Result = "" }         
                }
                TestScript = 
                {
                    # To validate if the file has been unzipped we test if the file named setup.exe exists
                    $FileExists = Test-Path -Path ($($Using:Node.ArtifactoryDownloadPath) + '\' + 'setup.exe') -PathType Leaf
                    Write-Verbose "FileExists from test : $FileExists and Path is: $($Using:Node.ArtifactoryDownloadPath)"

                    return $FileExists
                }
                SetScript = 
                {
                    $7zipExe    = $($Using:Node.ArtifactoryDownloadPath) + '\7z.exe'
                    $targetFile = $($Using:Node.ArtifactoryDownloadPath) + '\' + $($Using:Node.ArtifactSQLiso)
                        
                    Write-verbose "7zipExe: $7zipExe"
                    Write-verbose "targetFile: $targetFile"

                    $Process = Start-Process -FilePath $7zipExe -WorkingDirectory "$($Using:Node.ArtifactoryDownloadPath)" -Wait -PassThru -WindowStyle Hidden -ArgumentList "x $targetFile -aos -r -y -o$($Using:Node.ArtifactoryDownloadPath) " 
                    # An error in Start-Process may still result in DSC reporting compliance hence the exitcode test
                    if ($Process.ExitCode -ne 0)
                    {
                        throw "$7zipExe exited with exit code $($Process.ExitCode) when extracting the SQL ISO. Working Directory: $($Using:Node.ArtifactoryDownloadPath) Argument: x $targetFile -aos -r -y -o$($Using:Node.ArtifactoryDownloadPath)"
                    }     
                    else
                    {
                        Write-Verbose "SQL iso was successfully unzipped. Working Directory: $($Using:Node.ArtifactoryDownloadPath) Argument: x $targetFile aos -r -y -o$($Using:Node.ArtifactoryDownloadPath)" 
                    }       
                }
                DependsOn = "[ArtifactoryDownload]SQLinstallationfiles" 
            } 

            # Install SQL Native Client - latest version is required by ConfigMgr.
            Package InstallSQLNativeClient
            {
                Ensure      = $Node.EnsureString 
                Name        = $Node.SQLNativeClientName 
                Path        = $Node.SQLNativeClientMsi 
                Arguments   = $Node.SQLNativeClientArguments
                ProductId   = $Node.SQLNativeClientProductID
        
                DependsOn   = '[Script]unZipSqlIso'
            }
            
            # Install prerequisites for SQL Server
            WindowsFeatureSet WindowsFeatures
            {
                Name                = $Node.SQLDependentFeatures 
                Ensure              = $Node.EnsureString 
                #Source              = $Node.FeatureSourcePath # Assumes built-in Everyone has read permission to the share and path.
                DependsOn           = "[Package]InstallSQLNativeClient" 
            }

            <#
                On the remote SQL Server an empty file with the name NO_SMS_ON_DRIVE.SMS will need to be placed at the root 
                of all drives that should not have any Configuration Manager components installed.  
                Typically, the file should be added to all drives but the drive where application binaries are 
                stored.
            #>
            # $($Node.validNoSMSDrives).ForEach(
            #     {
            #         File "NO_SMS_$($_)"
            #         {
            #             Ensure          = $Node.EnsureString 
            #             DestinationPath = "$($_)\$($Node.NO_SMS_ON_DRIVE_Filename)" 
            #             Contents        = ''
    
            #             DependsOn       = '[WindowsFeatureSet]WindowsFeatures'
            #         }
            #     }
            # )
        
            # Install SSMS
            Package InstallSSMS
            {
                Ensure      = $Node.EnsureString 
                Name        = $Node.SQLSetUpExe 
                Path        = $Node.SSMSiso 
                Arguments   = "/install /passive /norestart" # place in PSD1
                ProductId   = $Node.SSMSproductID
                DependsOn       = '[WindowsFeatureSet]WindowsFeatures'
            }
        
            SQLInstallConfig MWSWALDO20
            {
                sqlInstanceName = $Node.SQLInstanceName # "MWSCENTER$($Node.CustCode)02"
                portNumber      = $Node.portnum
                sqlFeatures     = $Node.sqlFeaturesStd
                DependsOn       = '[Package]InstallSSMS'
            }

            # SqlServerLogin Add_WindowsUser
            # {
            #     Ensure               = 'Present'
            #     Name                 = $Node.DomainToJoin + '\' + 'LabAdmin'
            #     LoginType            = 'WindowsUser'
            #     ServerName           = $Node.NodeName
            #     InstanceName         = $Node.SQLInstanceName
            #     PsDscRunAsCredential = $DomainJoinCredential
            # }

            SqlDatabase CreateWaldoDatabase
            {
                Ensure       = 'Present'
                ServerName   = $Node.NodeName
                InstanceName = $Node.SQLInstanceName
                Name         = $Node.DatabaseName
                PsDscRunAsCredential = $DomainJoinCredential
                DependsOn       = '[SQLInstallConfig]MWSWALDO20'
            }

            SqlDatabaseUser AddUserSchedTask
            {
                ServerName           = $Node.NodeName
                InstanceName         = $Node.SQLInstanceName
                DatabaseName         = $Node.DatabaseName
                Name                 = "$SplitDomain\$($Node.SchedTaskUser)"
                UserType             = 'NoLogin'
                PsDscRunAsCredential = $DomainJoinCredential
                DependsOn            = '[SqlDatabase]CreateWaldoDatabase'
            }

            SqlDatabaseUser AddUserLocalAdminGroup
            {
                ServerName           = $Node.NodeName
                InstanceName         = $Node.SQLInstanceName
                DatabaseName         = $Node.DatabaseName
                Name                 = "$SplitDomain\$($Node.LocalAdminGroup)"
                UserType             = 'NoLogin'
                PsDscRunAsCredential = $DomainJoinCredential
                DependsOn            = '[SqlDatabaseUser]AddUserSchedTask'
            }

            SqlDatabaseRole IncludeRoleMembers
            {
                ServerName           = $Node.NodeName
                InstanceName         = $Node.SQLInstanceName
                Database             = $Node.DatabaseName
                Name                 = 'db_owner'
                MembersToInclude     = @("$SplitDomain\$($Node.SchedTaskUser)", "$SplitDomain\$($Node.LocalAdminGroup)")
                Ensure               = 'Present'
                PsDscRunAsCredential = $DomainJoinCredential
                DependsOn            = '[SqlDatabaseUser]AddUserLocalAdminGroup'
            }
        }
    }
}
