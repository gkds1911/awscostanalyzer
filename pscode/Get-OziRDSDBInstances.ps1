function Get-OziRDSDBInstances
{
    param
    (
        $Region,
        $AWSCredentialsProfile
    )

    $RDSCurrentGenerationArray = "db.t2.micro","db.t2.small","db.t2.medium","db.t2.large","db.m3.medium","db.m3.large","db.m3.xlarge","db.m3.2xlarge","db.r3.large","db.r3.xlarge","db.r3.2xlarge","db.r3.4xlarge","db.r3.8xlarge","db.m4.large","db.m4.xlarge","db.m4.2xlarge","db.m4.4xlarge","db.m4.10xlarge"
    $RDSPreviousGenerationArray = "db.m1.small","db.m1.medium","db.m1.large","db.m1.xlarge","db.m2.xlarge","db.m2.2xlarge","db.m2.4xlarge","db.t1.micro"
    $RDSInstanceTypesArray = (($RDSCurrentGenerationArray + $RDSPreviousGenerationArray))

    $AllRDSDBInstanceObjects = @()
    $RDSDBInstances = (Get-RDSDBInstance -Region $Region -ProfileName $AWSCredentialsProfile)    
    if($RDSDBInstances.Count -ge 1)
    {
        $DimensionName = "DBInstanceIdentifier"
        $Namespace = "AWS/RDS"
        foreach($rds in $RDSDBInstances)
        {    
            $DimensionValue = $rds.DBInstanceIdentifier
            $RDSDBInstanceObject = New-Object System.Object
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name Region -Value $Region
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name DBName -Value $rds.DBName
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name AllocatedStorage -Value $rds.AllocatedStorage
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name DBInstanceClass -Value $rds.DBInstanceClass
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name Generation -value $(($RDSDBInstanceObject.DBInstanceClass).Split(".",2)[0]+"."+$($RDSDBInstanceObject.DBInstanceClass).Split(".",3)[1])
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name Model -value $($RDSDBInstanceObject.DBInstanceClass).ToString().Split(".",3)[2]            
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name IsLatestGeneration -value $( if($RDSDBInstanceObject.DBInstanceClass -in $RDSCurrentGenerationArray) { $TRUE } elseif($RDSDBInstanceObject.DBInstanceClass -in $RDSPreviousGenerationArray) { $FALSE } else { "ERROR" } )                                 
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name AvailabilityZone -Value $rds.AvailabilityZone
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name DBInstanceIdentifier -Value $rds.DBInstanceIdentifier
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name DbiResourceId -Value $rds.DbiResourceId
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name DBInstanceStatus -Value $rds.DBInstanceStatus
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name Engine -Value $rds.Engine
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name EngineVersion -Value $rds.EngineVersion
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name InstanceCreateTime -Value $rds.InstanceCreateTime
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name Iops -Value $rds.Iops
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name MultiAZ -Value $rds.MultiAZ
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name StorageType -Value $rds.StorageType
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name Endpoint -Value $(($rds).Endpoint | Select-Object -ExpandProperty Address)
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name LastShutdownTime -Value $((Get-RDSEvent -Region $Region -Duration 20160 | Where-Object {($_.SourceIdentifier -eq $($rds.DBInstanceIdentifier)) -and ($_.SourceType -eq 'db-instance') -and ( $_.Message -eq 'DB instance stopped')} | Select-Object -Last 1 -ExpandProperty Date))            
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name MonitoringLastDay -Value $(& ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziCloudWatchCPUAverageUse.ps1") $DimensionName $DimensionValue $Namespace $Region (Get-Date).AddDays(-1).GetDateTimeFormats()[70] (Get-Date).GetDateTimeFormats()[70] $AWSCredentialsProfile)
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name MonitoringLastWeek -Value $(& ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziCloudWatchCPUAverageUse.ps1") $DimensionName $DimensionValue $Namespace $Region (Get-Date).AddDays(-7).GetDateTimeFormats()[70] (Get-Date).GetDateTimeFormats()[70] $AWSCredentialsProfile)
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name MonitoringLastMonth -Value $(& ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziCloudWatchCPUAverageUse.ps1") $DimensionName $DimensionValue $Namespace $Region (Get-Date).AddMonths(-1).GetDateTimeFormats()[70] (Get-Date).GetDateTimeFormats()[70] $AWSCredentialsProfile)
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name IsUnderused -value $( if(($RDSDBInstanceObject.DBInstanceStatus -eq 'available') -and ($RDSDBInstanceObject.MonitoringLastMonth -lt 5)) { $TRUE } elseif($RDSDBInstanceObject.DBInstanceStatus -eq 'stopped') { "stopped" } else { $FALSE })                                 
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name DBEngineVersionDescription -Value ($(Get-RDSDBEngineVersion -Region $Region -ProfileName $AWSCredentialsProfile | Where-Object {($_.Engine -eq $rds.Engine) -and ($_.EngineVersion -eq $rds.EngineVersion)} | Select-Object -ExpandProperty DBEngineVersionDescription).Split(" ")[0])            
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name PricePerHour -Value $(& ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziRDSDBInstancePrice.ps1") $Region $RDSDBInstanceObject.DBInstanceClass $RDSDBInstanceObject.DBEngineVersionDescription)
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name CheaperInstanceType -value $((& ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziRDSDBPreviousInstance.ps1") $Region $RDSDBInstanceObject.DBInstanceClass $($RDSInstanceTypesArray -Match $RDSDBInstanceObject.Generation)).Name )
            $RDSDBInstanceObject | Add-Member -type NoteProperty -name CheaperInstancePrice -value $((& ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziRDSDBPreviousInstance.ps1") $Region $RDSDBInstanceObject.DBInstanceClass $($RDSInstanceTypesArray -Match $RDSDBInstanceObject.Generation)).Price )            
            $AllRDSDBInstanceObjects += $RDSDBInstanceObject
        }            
    }
    return $AllRDSDBInstanceObjects    
}
Get-OziRDSDBInstances @args