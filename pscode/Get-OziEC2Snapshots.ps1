function Get-OziEC2Snapshots
{
    param
    (
        $Region,
        $OwnerId,
        $AWSCredentialsProfile        
    ) 
    $AllSnapshotObjects = @()
    $SnapshotObject = @()    
    $Snapshots = (Get-EC2Snapshot -Region $Region -OwnerId $OwnerId -ProfileName $AWSCredentialsProfile)
    if($Snapshots.Count -ge 1)
    {
        foreach($s in $Snapshots)
        {  
            $SnapshotObject = New-Object System.Object
            $SnapshotObject | Add-Member -type NoteProperty -name Region -value $Region                  
            $SnapshotObject | Add-Member -type NoteProperty -name SnapshotId -value $s.SnapshotId
            $SnapshotObject | Add-Member -type NoteProperty -name StartTime -value $s.StartTime
            $SnapshotObject | Add-Member -type NoteProperty -name State -value $s.State
            $SnapshotObject | Add-Member -type NoteProperty -name StateMessage -value $s.StateMessage
            $SnapshotObject | Add-Member -type NoteProperty -name Tags -value $s.Tags.Name
            $SnapshotObject | Add-Member -type NoteProperty -name VolumeId -value $s.VolumeId
            $SnapshotObject | Add-Member -type NoteProperty -name Size -value $s.VolumeSize
            $SnapshotObject | Add-Member -type NoteProperty -name VolumeType -value "standard"
            $SnapshotObject | Add-Member -type NoteProperty -name VolumeLabel -Value "ebsSnapsToS3"
            $SnapshotObject | Add-Member -type NoteProperty -name PricePerMonth -value $(& ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziEBSPrice.ps1") $SnapshotObject.Region $SnapshotObject.VolumeLabel $SnapshotObject.Size)
            $AllSnapshotObjects += $SnapshotObject            
        }
    }
    return $AllSnapshotObjects
}
Get-OziEC2Snapshots @args