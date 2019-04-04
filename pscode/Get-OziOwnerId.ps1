function Get-OziOwnerId
{
    param(
        $AWSRegions,
        $AWSCredentialsProfile
    )
    foreach($Region in $AWSRegions)
    {
        $OwnerIdExists = ((Get-EC2Instance -Region $Region -ProfileName $AWSCredentialsProfile) | Select-Object -ExpandProperty OwnerId -Unique)
        if($OwnerIdExists)
        {
            $OwnerId = $OwnerIdExists
        }        
    }
    return $OwnerId
}
Get-OziOwnerId @args