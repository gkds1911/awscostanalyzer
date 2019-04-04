function Get-OziEC2Addresses
{
    param
    (
        $Region,
        $AWSCredentialsProfile
    )
    $AllEC2AddressObjects = @()
    $EC2Addresses = (Get-EC2Address -Region $Region -ProfileName $AWSCredentialsProfile)

    if($EC2Addresses.Count -ge 1)
    {
        foreach($a in $EC2Addresses)
        {    
            $EC2AddressObject = New-Object System.Object
            $EC2AddressObject | Add-Member -type NoteProperty -name Region -value $Region                  
            $EC2AddressObject | Add-Member -type NoteProperty -name AllocationId -value $a.AllocationId                
            $EC2AddressObject | Add-Member -type NoteProperty -name AssociationId -value $a.AssociationId
            $EC2AddressObject | Add-Member -type NoteProperty -name Domain -value $a.Domain                 
            $EC2AddressObject | Add-Member -type NoteProperty -name InstanceId -value $a.InstanceId
            $EC2AddressObject | Add-Member -type NoteProperty -name NetworkInterfaceId -value $a.NetworkInterfaceId
            $EC2AddressObject | Add-Member -type NoteProperty -name NetworkInterfaceOwnerId -value $a.NetworkInterfaceOwnerId
            $EC2AddressObject | Add-Member -type NoteProperty -name PrivateIpAddress -value $a.PrivateIpAddress
            $EC2AddressObject | Add-Member -type NoteProperty -name PublicIp -value $a.PublicIp            
            $AllEC2AddressObjects += $EC2AddressObject
        }            
    }      
    return $AllEC2AddressObjects
}
Get-OziEC2Addresses @args