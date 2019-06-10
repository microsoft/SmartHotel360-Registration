#
# Copyright="© Microsoft Corporation. All rights reserved."
#

configuration ConfigSQLAOn
{
    param
    (
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [String]$ClusterName,

        [Parameter(Mandatory)]
        [String]$ClusterIpAddress,

        [Parameter(Mandatory)]
        [String]$ClusterOwnerNode,

        [Parameter(Mandatory)]
        [String]$witnessStorageName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$witnessStorageKey,

        [Parameter(Mandatory)]
        [String]$AGName,

        [Parameter(Mandatory)]
        [String]$AGListenerName,

        [Parameter(Mandatory)]
        [String[]]$AGListenerIpAddresses,

        [UInt32]$AGListenerPort = 1433,

        [UInt32]$DatabaseEnginePort = 1433,
        
        [UInt32]$DatabaseMirrorPort = 5022,

        [UInt32]$ProbePortNumber = 59999,

        [String]$AvailabilityMode,

        [String]$FailoverMode,

        [Parameter(Mandatory)]
        [Boolean]$IsSecondarySite = $false,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SQLServicecreds,


        [String]$DomainNetbiosName=(Get-NetBIOSName -DomainName $DomainName),

        [Int]$RetryCount=20,
        [Int]$RetryIntervalSec=30,

        [Parameter(Mandatory)]
        [String]$ScriptsLocationSAName,

        [Parameter(Mandatory)]
        [String]$ScriptsLocationSAKey,

        [Parameter(Mandatory)]
        [String]$ScriptsLocationSAContainer        
    )

#    Install-PackageProvider -Name NuGet -Force
#    Install-Module -Name SqlServer -AllowClobber -Force 
    Import-DscResource -ModuleName xDisk,xActiveDirectory,xFailoverCluster,xNetworking,SqlServerDsc,cAzureStorage
    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($Admincreds.UserName)", $Admincreds.Password)
    [System.Management.Automation.PSCredential]$DomainFQDNCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)
    [System.Management.Automation.PSCredential]$SQLCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SQLServicecreds.UserName)", $SQLServicecreds.Password)
    $SqlServiceName = $SQLServicecreds.UserName

    $RebootVirtualMachine = $false

    if ($DomainName)
    {
        $RebootVirtualMachine = $true
    }

    WaitForSqlSetup

    Node localhost
    {
        xWaitForDisk Disk
        {
            DiskNumber = 2
            RetryIntervalSec = $RetryIntervalSec
            RetryCount = $RetryCount
        }

        xDisk FVolume
        {
            DiskNumber = 2
            DriveLetter = 'F'

            DependsOn = '[xWaitForDisk]Disk'
        }

        WindowsFeature FC
        {
            Name = "Failover-Clustering"
            Ensure = "Present"
        }

        WindowsFeature FailoverClusterTools 
        { 
            Ensure = "Present" 
            Name = "RSAT-Clustering-Mgmt"
            DependsOn = "[WindowsFeature]FC"
        } 

        WindowsFeature FCPS
        {
            Name = "RSAT-Clustering-PowerShell"
            Ensure = "Present"
            DependsOn = "[WindowsFeature]FailoverClusterTools"
        }

        WindowsFeature FCPSCMD
        {
            Ensure    = 'Present'
            Name      = 'RSAT-Clustering-CmdInterface'
            DependsOn = '[WindowsFeature]FCPS'
        }        

        WindowsFeature ADPS
        {
            Name = "RSAT-AD-PowerShell"
            Ensure = "Present"
            DependsOn = '[WindowsFeature]FCPSCMD'
        }

        xFirewall DatabaseEngineFirewallRule
        {
            Direction = "Inbound"
            Name = "SQL-Server-Database-Engine-TCP-In"
            DisplayName = "SQL Server Database Engine (TCP-In)"
            Description = "Inbound rule for SQL Server to allow TCP traffic for the Database Engine."
            DisplayGroup = "SQL Server"
            State = "Enabled"
            Access = "Allow"
            Protocol = "TCP"
            LocalPort = $DatabaseEnginePort -as [String]
            Ensure = "Present"
        }

        xFirewall DatabaseMirroringFirewallRule
        {
            Direction = "Inbound"
            Name = "SQL-Server-Database-Mirroring-TCP-In"
            DisplayName = "SQL Server Database Mirroring (TCP-In)"
            Description = "Inbound rule for SQL Server to allow TCP traffic for the Database Mirroring."
            DisplayGroup = "SQL Server"
            State = "Enabled"
            Access = "Allow"
            Protocol = "TCP"
            LocalPort = $DatabaseMirrorPort -as [String]
            Ensure = "Present"
        }

        xFirewall LoadBalancerProbePortFirewallRule
        {
            Direction = "Inbound"
            Name = "SQL-Server-Probe-Port-TCP-In"
            DisplayName = "SQL Server Probe Port (TCP-In)"
            Description = "Inbound rule to allow TCP traffic for the Load Balancer Probe Port."
            DisplayGroup = "SQL Server"
            State = "Enabled"
            Access = "Allow"
            Protocol = "TCP"
            LocalPort = $ProbePortNumber -as [String]
            Ensure = "Present"
        }

        SqlServerLogin AddDomainAdminAccountAsLogin
        {
            Ensure               = "Present"
            Name                 = $DomainCreds.UserName
            LoginType            = "WindowsUser"
            ServerName           = $env:COMPUTERNAME
            InstanceName         = "MSSQLSERVER"
        }

        xADUser CreateSqlServerServiceAccount
        {
            Ensure = "Present"
            DomainName = $DomainName
            UserName = $SQLServicecreds.UserName
            Password = $SQLServicecreds
            DomainAdministratorCredential = $DomainCreds
        }

        SqlServerLogin AddSqlServerServiceAccountAsLogin
        {
            Ensure               = "Present"
            Name                 = $SQLCreds.UserName
            LoginType            = "WindowsUser"
            ServerName           = $env:COMPUTERNAME
            InstanceName         = "MSSQLSERVER"
            DependsOn = "[xADUser]CreateSqlServerServiceAccount"
        }
        
        SqlServerRole AddAccountsToSysadminServerRole
        {
            Ensure               = "Present"
            ServerRoleName       = "sysadmin"
            MembersToInclude     = $DomainCreds.UserName, $SQLCreds.UserName
            ServerName           = $env:COMPUTERNAME
            InstanceName         = "MSSQLSERVER"

            DependsOn = "[SqlServerLogin]AddDomainAdminAccountAsLogin", "[SqlServerLogin]AddSqlServerServiceAccountAsLogin"
        }

        Service MsSqlServerService
        {
            Name        = "MSSQLSERVER"
            StartupType = "Automatic"
            State       = "Running"
        }

        SqlServiceAccount SetServiceAccount
        {
            ServerName     = $env:COMPUTERNAME
            InstanceName   = 'MSSQLSERVER'
            ServiceType    = 'DatabaseEngine'
            ServiceAccount = $SQLCreds
            RestartService = $true

            PsDscRunAsCredential = $DomainCreds
            DependsOn = "[SqlServerRole]AddAccountsToSysadminServerRole", "[Service]MsSqlServerService"
        }

        Script ResetSpns
        {
            GetScript = { 
                return @{ 'Result' = $true }
            }

            SetScript = {
                $spn = "MSSQLSvc/" + ${env:COMPUTERNAME} + "." + $using:DomainName
                
                $cmd = "setspn -D $spn ${env:COMPUTERNAME}"
                Write-Verbose $cmd
                Invoke-Expression $cmd

                $cmd = "setspn -A $spn $using:SqlServiceName"
                Write-Verbose $cmd
                Invoke-Expression $cmd

                $spn = "MSSQLSvc/" + ${env:COMPUTERNAME} + "." + $using:DomainName + ":1433"
                
                $cmd = "setspn -D $spn ${env:COMPUTERNAME}"
                Write-Verbose $cmd
                Invoke-Expression $cmd

                $cmd = "setspn -A $spn $using:SqlServiceName"
                Write-Verbose $cmd
                Invoke-Expression $cmd
            }

            TestScript = {
                $false
            }

            PsDscRunAsCredential = $DomainCreds
            DependsOn = "[SqlServiceAccount]SetServiceAccount"
        }

        if ($ClusterOwnerNode -eq $env:COMPUTERNAME) {

            Script CreateFailoverCluster
            {
                SetScript = "New-Cluster -Name ${ClusterName} -StaticAddress ${ClusterIpAddress} -Node ${env:COMPUTERNAME} -NoStorage -ErrorAction Stop"
                TestScript = "(Get-Cluster -Name . -ErrorAction Ignore).Name -eq '${ClusterName}'"
                GetScript = "@{Ensure = if ((Get-Cluster -Name . -ErrorAction Ignore).Name -eq '${ClusterName}') {'Present'} else {'Absent'}}"
    
                PsDscRunAsCredential = $DomainCreds
                DependsOn = "[WindowsFeature]FCPS"
            }

            Script FailoverCluster
            {
                SetScript = "Set-ClusterQuorum -CloudWitness -AccountName ${witnessStorageName} -AccessKey $($witnessStorageKey.GetNetworkCredential().Password)"
                TestScript = "(Get-ClusterQuorum).QuorumResource.Name -eq 'Cloud Witness'"
                GetScript = "@{Ensure = if ((Get-ClusterQuorum).QuorumResource.Name -eq 'Cloud Witness') {'Present'} else {'Absent'}}"
    
                PsDscRunAsCredential = $DomainCreds
                DependsOn = "[Script]CreateFailoverCluster"
            }
    
        }
        else {

            xWaitForCluster WaitForCluster
            {
                Name             = $ClusterName
                RetryIntervalSec = 10
                RetryCount       = 60

                PsDscRunAsCredential = $DomainCreds
                DependsOn = '[WindowsFeature]ADPS'
            }

            Script FailoverCluster
            {
                GetScript = "@{Ensure = if ((Get-ClusterNode -Cluster ${ClusterOwnerNode}).Name -contains '${env:COMPUTERNAME}') {'Present'} else {'Absent'}}"
                SetScript = "Add-ClusterNode -Name ${env:COMPUTERNAME} -Cluster ${ClusterOwnerNode}"
                TestScript = "(Get-ClusterNode -Cluster ${ClusterOwnerNode}).Name -contains '${env:COMPUTERNAME}'"

                PsDscRunAsCredential = $DomainCreds
                DependsOn = "[xWaitForCluster]WaitForCluster"
            }

        }

        # Adding the required service account to allow the cluster to log into SQL
        SqlServerLogin AddNTServiceClusSvc
        {
            Ensure               = 'Present'
            Name                 = 'NT SERVICE\ClusSvc'
            LoginType            = 'WindowsUser'
            ServerName           = $env:COMPUTERNAME
            InstanceName         = 'MSSQLSERVER'

            DependsOn = "[Script]FailoverCluster"
        }

        # Add the required permissions to the cluster service login
        SqlServerPermission AddNTServiceClusSvcPermissions
        {
            Ensure               = 'Present'
            ServerName           = $env:COMPUTERNAME
            InstanceName         = 'MSSQLSERVER'
            Principal            = 'NT SERVICE\ClusSvc'
            Permission           = 'AlterAnyAvailabilityGroup', 'ViewServerState'

            DependsOn            = '[SqlServerLogin]AddNTServiceClusSvc'
        }

        SqlAlwaysOnService EnableAlwaysOn
        {
            Ensure               = 'Present'
            ServerName           = $env:COMPUTERNAME
            InstanceName         = 'MSSQLSERVER'
            RestartTimeout       = 120

            DependsOn = "[Script]FailoverCluster"
        }

        # Create a DatabaseMirroring endpoint
        SqlServerEndpoint HADREndpoint
        {
            EndPointName         = 'HADR'
            Ensure               = 'Present'
            Port                 = 5022
            ServerName           = $env:COMPUTERNAME
            InstanceName         = 'MSSQLSERVER'

            DependsOn            = "[SqlAlwaysOnService]EnableAlwaysOn"
        }

        if ($ClusterOwnerNode -eq $env:COMPUTERNAME) {

            SqlAG CreateAG
            {
                Ensure               = "Present"
                Name                 = $AGName
                ServerName           = $env:COMPUTERNAME
                InstanceName         = 'MSSQLSERVER'
                AvailabilityMode     = $AvailabilityMode
                FailoverMode         = $FailoverMode
    
                PsDscRunAsCredential = $DomainCreds
                DependsOn            = "[SqlServerEndpoint]HADREndpoint","[SqlServiceAccount]SetServiceAccount","[Script]ResetSpns"

            }

            cAzureStorage CopyScripts
            {
                Path = "D:\Temp"
                StorageAccountName = $ScriptsLocationSAName
                StorageAccountContainer = $ScriptsLocationSAContainer
                StorageAccountKey = $ScriptsLocationSAKey
                Blob = "DBScripts"
            }
    
            Script ExecuteScripts
                {
                    GetScript = { }
                    TestScript = { $false }
                    SetScript = {
                        foreach($file in Get-ChildItem "D:\Temp\DBScripts" | where Extension -EQ '.sql' | sort Name)
                        {
                            Invoke-Sqlcmd -InputFile $file.FullName -Variable jobOwnerLoginName="'$($using:DomainCreds.UserName)'" 
                        }
                    }

                    DependsOn = "[SqlAG]CreateAG", "[cAzureStorage]CopyScripts"
                }
    
            SqlScriptQuery "AddDBToAG"
            {
                ServerInstance = $env:COMPUTERNAME
                GetQuery = "SELECT 1"
                TestQuery = "SELECT Name FROM sys.databases WHERE Name = 'SmartHotel.Registration' AND replica_id IS NULL"
                SetQuery = "BACKUP DATABASE [SmartHotel.Registration] TO  DISK = N'D:\Temp\SmartHotel.Registration.bak' WITH NOFORMAT, NOINIT,  NAME = N'SmartHotel.Registration-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10;
                GO
                ALTER AVAILABILITY GROUP [$AGName] ADD DATABASE [SmartHotel.Registration];
                GO"

                PsDscRunAsCredential = $DomainCreds
                DependsOn = "[Script]ExecuteScripts"
            }
    

        }
        else {

            SqlWaitForAG WaitForAG
            {
                Name                 = $AGName
                RetryIntervalSec     = 20
                RetryCount           = 30

                PsDscRunAsCredential = $DomainCreds
                DependsOn            = "[SqlServerEndpoint]HADREndpoint","[SqlServiceAccount]SetServiceAccount","[Script]ResetSpns"
            }

<#            
            Script Sleep
            {
                SetScript = "Start-Sleep -Seconds 30"
                TestScript = { $false }
                GetScript = { }
    
                PsDscRunAsCredential = $DomainCreds
                DependsOn = "[SqlWaitForAG]WaitForAG"
            }
#>

            # Add the availability group replica to the availability group
            SqlAGReplica AddReplica
            {
                Ensure                     = 'Present'
                Name                       = $env:COMPUTERNAME
                AvailabilityGroupName      = $AGName
                ServerName                 = $env:COMPUTERNAME
                InstanceName               = 'MSSQLSERVER'
                PrimaryReplicaServerName   = $ClusterOwnerNode
                PrimaryReplicaInstanceName = 'MSSQLSERVER'
                AvailabilityMode     = $AvailabilityMode
                FailoverMode         = $FailoverMode

                PsDscRunAsCredential = $DomainCreds
#                DependsOn            = "[Script]Sleep"
                DependsOn = "[SqlWaitForAG]WaitForAG"
            }


            SqlScriptQuery EnableAutoSeeding
            {
                ServerInstance = $ClusterOwnerNode
                GetQuery = "SELECT 1"
                TestQuery = "SELECT NULL"
                SetQuery = "ALTER AVAILABILITY GROUP [$AGName]
				MODIFY REPLICA ON '$env:COMPUTERNAME' WITH (SEEDING_MODE = AUTOMATIC)
                GO"
                
                PsDscRunAsCredential = $Admincreds
				DependsOn = "[SqlAGReplica]AddReplica"
            }

            SqlScriptQuery GrantCreateAyDatabase
            {
                ServerInstance = $env:COMPUTERNAME
                GetQuery = "SELECT 1"
                TestQuery = "SELECT NULL"
                SetQuery = "ALTER AVAILABILITY GROUP [$AGName]
				GRANT CREATE ANY DATABASE
                GO"
                
                PsDscRunAsCredential = $Admincreds
				DependsOn = "[SqlAGReplica]AddReplica"
            }

            if ($IsSecondarySite) {

                SqlAGListener AvailabilityGroupListener
                {
                    Ensure               = 'Present'
                    Name                 = $AGListenerName
                    ServerName           = $ClusterOwnerNode
                    InstanceName         = 'MSSQLSERVER'
                    AvailabilityGroup    = $AGName
                    IpAddress            = $AGListenerIpAddresses
                    Port                 = $AGListenerPort
    
                    PsDscRunAsCredential = $DomainCreds
                    DependsOn = "[SqlAGReplica]AddReplica"
                }
    
                Script SetProbePort
                {
                    GetScript = { 
                        return @{ 'Result' = $true }
                    }
                    SetScript = {
    
                        foreach ($AGListenerIpAddress in $using:AGListenerIpAddresses) {
    
                            $AGListenerIpAddressSplit = $AGListenerIpAddress -split '/'
                            $ipResourceName = $using:AGName + "_" + $AGListenerIpAddressSplit[0]
                            $ipResource = Get-ClusterResource $ipResourceName
    
                            Set-ClusterParameter -InputObject $ipResource -Name ProbePort -Value $using:ProbePortNumber
    
                            if ($ipResource.State -eq 'Online') {
                                Stop-ClusterResource $ipResource
                            }
                        }

                        $agResource = Get-ClusterGroup -Name $using:AGName
                        Start-ClusterGroup $agResource

                    }
                    TestScript = {
    
                        $Result = $true
    
                        foreach ($AGListenerIpAddress in $using:AGListenerIpAddresses) {
    
                            $AGListenerIpAddressSplit = $AGListenerIpAddress -split '/'
                            $ipResourceName = $using:AGName + "_" + $AGListenerIpAddressSplit[0]
                            $resource = Get-ClusterResource $ipResourceName
                            $probePort = $(Get-ClusterParameter -InputObject $resource -Name ProbePort).Value
                            Write-Verbose "ProbePort = $probePort"
    
                            $Result = $Result -and ($probePort -eq $using:ProbePortNumber)
                        }
                        $Result
                    }
    
                    DependsOn = "[SqlAGListener]AvailabilityGroupListener"
                    PsDscRunAsCredential = $DomainCreds
                }            
            }
    

        }
        

        LocalConfigurationManager 
        {
            RebootNodeIfNeeded = $true
        }

    }
}
function Get-NetBIOSName
{ 
    [OutputType([string])]
    param(
        [string]$DomainName
    )

    if ($DomainName.Contains('.')) {
        $length=$DomainName.IndexOf('.')
        if ( $length -ge 16) {
            $length=15
        }
        return $DomainName.Substring(0,$length)
    }
    else {
        if ($DomainName.Length -gt 15) {
            return $DomainName.Substring(0,15)
        }
        else {
            return $DomainName
        }
    }
}
function WaitForSqlSetup
{
    # Wait for SQL Server Setup to finish before proceeding.
    while ($true)
    {
        try
        {
            Get-ScheduledTaskInfo "\ConfigureSqlImageTasks\RunConfigureImage" -ErrorAction Stop
            Start-Sleep -Seconds 5
        }
        catch
        {
            break
        }
    }
}
