function Get-OziEC2ReservedInstances
{
    param
    (
        $Region,
        $AWSCredentialsProfile
    )

    #Initializing objects and variables
    $AllReservedInstanceObjects = @()
    $ReservedInstances = @()   

    # Fetching all reserved instances
    $ReservedInstances = (Get-EC2ReservedInstance -Region $Region -ProfileName $AWSCredentialsProfile)      

    if($ReservedInstances.Count -ge 1)
    {
        foreach($ri in $ReservedInstances)
        {    
            # Building the InstanceObject with information coming from the AWS EC2 API
            # http://docs.aws.amazon.com/powershell/latest/reference/items/Get-EC2Instance.html 
            $ReservedInstanceObject = New-Object System.Object
            $ReservedInstanceObject | Add-Member -type NoteProperty -name Region -value $Region                    
            $ReservedInstanceObject | Add-Member -type NoteProperty -name AvailabilityZone -value $ri.AvailabilityZone
            $ReservedInstanceObject | Add-Member -type NoteProperty -name Duration -value $ri.Duration
            $ReservedInstanceObject | Add-Member -type NoteProperty -name InstanceType -value $ri.InstanceType
            $ReservedInstanceObject | Add-Member -type NoteProperty -name State -value $ri.State 
            $ReservedInstanceObject | Add-Member -type NoteProperty -name Start -value $ri.Start
            $AllReservedInstanceObjects += $ReservedInstanceObject
        }
    }
    return $AllReservedInstanceObjects
}
Get-OziEC2ReservedInstances @args