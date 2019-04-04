function Get-OziEC2Volumes
{
    param
    (
        $Region,
        $AWSCredentialsProfile
    )    
    $AllVolumeObjects = @()
    $VolumeObject = @() 

    $Volumes = (Get-EC2Volume -Region $Region -ProfileName $AWSCredentialsProfile)

    if($Volumes.Count -ge 1)
    {
        foreach($v in $Volumes)
        {
            $VolumeObject = New-Object System.Object
            $VolumeObject | Add-Member -type NoteProperty -name Region -value $Region
            $VolumeObject | Add-Member -type NoteProperty -name AttachmentState -value $( if($v.Attachments.State) { $v.Attachments.State } else { $NULL } )
            $VolumeObject | Add-Member -type NoteProperty -name AttachmentInstance -value $( if($VolumeObject.AttachmentState) { $v.Attachments.InstanceId } else { $NULL } )
            $VolumeObject | Add-Member -type NoteProperty -name AttachmentInstanceState -value $( if($VolumeObject.AttachmentState) { (Get-EC2Instance -Region $Region -ProfileName $AWSCredentialsProfile -InstanceId $VolumeObject.AttachmentInstance).Instances.State.Name } else { $NULL })
            # TODO : Gérer le delete on termination 
            $VolumeObject | Add-Member -type NoteProperty -name AvailabilityZone -value $v.AvailabilityZone
            $VolumeObject | Add-Member -type NoteProperty -name CreateTime -value $v.CreateTime
            $VolumeObject | Add-Member -type NoteProperty -name Iops -value $v.Iops
            $VolumeObject | Add-Member -type NoteProperty -name Size -value $v.Size
            $VolumeObject | Add-Member -type NoteProperty -name State -value $v.State
            $VolumeObject | Add-Member -type NoteProperty -name NameTagValue -value ($v.Tags.Value | Where-Object { $_.Tags.Key -eq "Name"})
            $VolumeObject | Add-Member -type NoteProperty -name VolumeId -value $v.VolumeId 
            $VolumeObject | Add-Member -type NoteProperty -name VolumeType -value $v.VolumeType
            $VolumeObject | Add-Member -type NoteProperty -name VolumeLabel -value $(
                switch($VolumeObject.VolumeType)
                {
                    "gp2" { "Amazon EBS General Purpose SSD (gp2) volumes" }
                    "io1" { "Amazon EBS Provisioned IOPS SSD (io1) volumes" }
                    "st1" { "Amazon EBS Throughput Optimized HDD (st1) volumes" }
                    "sc1" { "Amazon EBS Cold HDD (sc1) volumes" } 
                    "standard" { "ebsSnapsToS3" }
                })
            $VolumeObject | Add-Member -type NoteProperty -name PricePerMonth -value $(& ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziEBSPrice.ps1") $VolumeObject.Region $VolumeObject.VolumeLabel $VolumeObject.Size $VolumeObject.Iops)
            $AllVolumeObjects += $VolumeObject                
        }
    }
    return $AllVolumeObjects
}
Get-OziEC2Volumes @args