function Get-OziEC2PreviousInstance
{
    param(
        $Region,
        $InstanceType,
        $InstanceTypes
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
            $PreviousGenerationPrice = $(& ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziEC2InstancePrice.ps1") $Region $InstanceTypes[$i-1] "Windows")
            break;
        }
    }

    $PreviousGenerationObject | Add-Member -type NoteProperty -name Name -Value $PreviousGeneration
    $PreviousGenerationObject | Add-Member -type NoteProperty -name Price -Value $PreviousGenerationPrice
    
    return $PreviousGenerationObject 
}
Get-OziEC2PreviousInstance @args