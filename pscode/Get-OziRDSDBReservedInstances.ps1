function Get-OziRDSDBReservedInstances
{
    param
    (
        $Region,
        $AWSCredentialsProfile
    )

    #Initializing objects and variables
    $AllRDSDBReservedInstanceObjects = @()

    # Fetching all rds db instances
    $RDSDBReservedInstances = (Get-RDSReservedDBInstance -Region $Region -ProfileName $AWSCredentialsProfile)

    # If there's at least one rds db instance in the current region
    if($RDSDBReservedInstances.Count -ge 1)
    {
        foreach($rdsri in $RDSDBInstances)
        {    
            # Building the RDSDBInstanceObject with information coming from the AWS EC2 API
            # http://docs.aws.amazon.com/powershell/latest/reference/items/Get-RDSReservedDBInstance.html
            $RDSDBReservedInstanceObject = New-Object System.Object
            $RDSDBReservedInstanceObject | Add-Member -type NoteProperty -name Region -value $Region   
            $RDSDBReservedInstanceObject | Add-Member -type NoteProperty -name ReservedDBInstanceId -value $rdsri.ReservedDBInstanceId
            $RDSDBReservedInstanceObject | Add-Member -type NoteProperty -name Duration -value $rdsri.Duration
            $RDSDBReservedInstanceObject | Add-Member -type NoteProperty -name DBInstanceClass -value $rdsri.DBInstanceClass
            $RDSDBReservedInstanceObject | Add-Member -type NoteProperty -name MultiAZ -value $rdsri.MultiAZ            
            $RDSDBReservedInstanceObject | Add-Member -type NoteProperty -name State -value $rdsri.State 
            $RDSDBReservedInstanceObject | Add-Member -type NoteProperty -name StartTime -value $rdsri.StartTime
            $AllRDSDBReservedInstanceObjects += $RDSDBReservedInstanceObject
        }            
    }
    return $AllRDSDBReservedInstanceObjects
}
Get-OziRDSDBReservedInstances @args