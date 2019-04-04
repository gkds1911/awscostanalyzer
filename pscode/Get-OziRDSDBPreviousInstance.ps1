function Get-OziRDSPreviousInstance
{
    param(
        $Region,
        $InstanceType, # db.t2.medium $RDSDBInstanceObject.DBInstanceClass
        $InstanceTypes # array
    )    
    $PreviousGenerationObject = New-Object System.Object    

    for($i=0;$i -le $InstanceTypes.Count;$i++)
    {
        if(($i -eq 0) -and $InstanceTypes[$i] -eq $InstanceType)
        {
            $PreviousGeneration = "Cannot be downsized"
            $PreviousGenerationPrice = 0
            break;
        }
        elseif($InstanceTypes[$i] -eq $InstanceType)
        {
            $PreviousGeneration = $InstanceTypes[$i-1]
            $PreviousGenerationPrice = $(& ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziRDSDBInstancePrice.ps1") $Region $InstanceTypes[$i-1] $RDSDBInstanceObject.DBEngineVersionDescription)
            break;
        }
    }

    $PreviousGenerationObject | Add-Member -type NoteProperty -name Name -Value $PreviousGeneration
    $PreviousGenerationObject | Add-Member -type NoteProperty -name Price -Value $PreviousGenerationPrice
    
    return $PreviousGenerationObject 
}
Get-OziRDSPreviousInstance @args