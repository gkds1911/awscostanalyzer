function Get-OziEC2Instances
{
    param
    (
        $Region,
        $AWSCredentialsProfile
    )

    $EC2CurrentGenerationArray = "t2.nano","t2.micro","t2.small","t2.medium","t2.large","t2.xlarge","t2.2xlarge","m4.large","m4.xlarge","m4.2xlarge","m4.4xlarge","m4.10xlarge","m4.16xlarge","m3.medium","m3.large","m3.xlarge","m3.2xlarge","c4.large","c4.xlarge","c4.2xlarge","c4.4xlarge","c4.8xlarge","c3.large","c3.xlarge","c3.2xlarge","c3.4xlarge","c3.8xlarge","x1.32xlarge","x1.16xlarge","r4.large","r4.xlarge","r4.2xlarge","r4.4xlarge","r4.8xlarge","r4.16xlarge","r3.large","r3.xlarge","r3.2xlarge","r3.4xlarge","r3.8xlarge","p2.xlarge","p2.8xlarge","p2.16xlarge","g3.4xlarge","g3.8xlarge","g3.16xlarge","f1.2xlarge","f1.16xlarge","i3.large","i3.xlarge","i3.2xlarge","i3.4xlarge","i3.8xlarge","i3.16xlarge","d2.xlarge","d2.2xlarge","d2.4xlarge","d2.8xlarge"
    $EC2PreviousGenerationArray = "m1.small","m1.medium","m1.large","m1.xlarge","c1.medium","c1.xlarge","cc2.8xlarge","g2.2xlarge","g2.8xlarge","cg1.4xlarge","m2.xlarge","m2.2xlarge","m2.4xlarge","cr1.8xlarge","i2.xlarge","i2.2xlarge","i2.4xlarge","i2.8xlarge","hi1.4xlarge","hs1.8xlarge","t1.micro"
    $EC2InstanceTypesArray = (($EC2CurrentGenerationArray + $EC2PreviousGenerationArray))

    $AllInstanceObjects = @()
    $Instances = (Get-EC2Instance -Region $Region -ProfileName $AWSCredentialsProfile)
    if($Instances.Count -ge 1)
    {
        $DimensionName = "InstanceId"
        $Namespace = "AWS/EC2" 
        foreach($i in $Instances)
        {    
            $DimensionValue = $i.Instances.InstanceId
            $InstanceObject = New-Object System.Object
            $InstanceObject | Add-Member -type NoteProperty -name Region -value $Region                    
            $InstanceObject | Add-Member -type NoteProperty -name NameTagValue -value ($i.Instances.Tags.Value | Where-Object { $_.Instances.Tags.Key -eq "Name"})
            $InstanceObject | Add-Member -type NoteProperty -name InstanceId -value $i.Instances.InstanceId
            $InstanceObject | Add-Member -type NoteProperty -name InstanceType -value $i.Instances.InstanceType
            $InstanceObject | Add-Member -type NoteProperty -name Generation -value $($InstanceObject.InstanceType).ToString().Split(".")[0]
            $InstanceObject | Add-Member -type NoteProperty -name Model -value $($InstanceObject.InstanceType).ToString().Split(".")[1]
            $InstanceObject | Add-Member -type NoteProperty -name IsLatestGeneration -value $( if($i.Instances.InstanceType -in $EC2CurrentGenerationArray) { $TRUE } elseif($i.Instances.InstanceType -in $EC2PreviousGenerationArray) { $FALSE } else { "ERROR" } )                     
            $InstanceObject | Add-Member -type NoteProperty -name State -value $i.Instances.State.Name      
            $InstanceObject | Add-Member -type NoteProperty -name ImageId  -value $i.Instances.ImageId
            $InstanceObject | Add-Member -type NoteProperty -name StateTransitionReason -value $i.Instances.StateTransitionReason     
            $InstanceObject | Add-Member -type NoteProperty -name LaunchTime -value $i.Instances.LaunchTime
            $InstanceObject | Add-Member -type NoteProperty -name PrivateDnsName -value $i.Instances.PrivateDnsName
            $InstanceObject | Add-Member -type NoteProperty -name PrivateIpAddress -value $i.Instances.PrivateIpAddress
            $InstanceObject | Add-Member -type NoteProperty -name PublicDnsName -value $i.Instances.PublicDnsName
            $InstanceObject | Add-Member -type NoteProperty -name PublicIpAddress -value $i.Instances.PublicIpAddress
            $InstanceObject | Add-Member -type NoteProperty -name SpotInstanceRequestId -value $i.Instances.SpotInstanceRequestId
            $InstanceObject | Add-Member -type NoteProperty -name MonitoringLastDay -value $(& ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziCloudWatchCPUAverageUse.ps1") $DimensionName $DimensionValue $Namespace $Region (Get-Date).AddDays(-1).GetDateTimeFormats()[70] (Get-Date).GetDateTimeFormats()[70] $AWSCredentialsProfile)
            $InstanceObject | Add-Member -type NoteProperty -name MonitoringLastWeek -value $(& ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziCloudWatchCPUAverageUse.ps1") $DimensionName $DimensionValue $Namespace $Region (Get-Date).AddDays(-7).GetDateTimeFormats()[70] (Get-Date).GetDateTimeFormats()[70] $AWSCredentialsProfile)
            $InstanceObject | Add-Member -type NoteProperty -name MonitoringLastMonth -value $(& ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziCloudWatchCPUAverageUse.ps1") $DimensionName $DimensionValue $Namespace $Region (Get-Date).AddMonths(-1).GetDateTimeFormats()[70] (Get-Date).GetDateTimeFormats()[70] $AWSCredentialsProfile)
            $InstanceObject | Add-Member -type NoteProperty -name IsUnderused -value $( if(($InstanceObject.State -eq 'running') -and ($InstanceObject.MonitoringLastMonth -lt 5)) { $TRUE } elseif($InstanceObject.State -eq 'stopped') { "stopped" } else { $FALSE })                     
            $InstanceObject | Add-Member -type NoteProperty -name PricePerHourLinux -value $(& ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziEC2InstancePrice.ps1") $Region $i.Instances.InstanceType "Linux")
            $InstanceObject | Add-Member -type NoteProperty -name PricePerHourWindows -value $(& ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziEC2InstancePrice.ps1") $Region $i.Instances.InstanceType "Windows")
            $InstanceObject | Add-Member -type NoteProperty -name CheaperInstanceType -value $((& ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziEC2PreviousInstance.ps1") $Region $InstanceObject.InstanceType $($EC2InstanceTypesArray -Match $($InstanceObject.Generation))).Name )
            $InstanceObject | Add-Member -type NoteProperty -name CheaperInstancePrice -value $((& ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziEC2PreviousInstance.ps1") $Region $InstanceObject.InstanceType $($EC2InstanceTypesArray -Match $($InstanceObject.Generation))).Price )
            $AllInstanceObjects += $InstanceObject
            }            
    }      
    return $AllInstanceObjects
}
Get-OziEC2Instances @args