function Get-OziS3Buckets
{
    param
    (
        $Region,
        $AWSCredentialsProfile
    )
    #Initializing objects and variables
    $AllS3BucketObjects = @()

    # Fetching all buckets
    $BucketList = (Get-S3Bucket -Region $Region -ProfileName $AWSCredentialsProfile)

    if($BucketList.Count -ge 1)
    {
        $DimensionName = "BucketName"
        $DimensionName2 = "StorageType"
        $Namespace = "AWS/S3"

        foreach($b in $BucketList)
        {    
            $DimensionValue = $b.BucketName
            $DimensionValue2 = "StandardStorage"
            $Now = ([DateTime]::Now.ToString("yyyy-MM-ddTHH:mm:ss")).ToString()
            $OneDayAgo = ([DateTime]::Now.AddDays(-1).ToString("yyyy-MM-ddTHH:mm:ss")).ToString()
            $S3BucketObject = New-Object System.Object
            $S3BucketObject | Add-Member -type NoteProperty -name Region -value $Region                    
            $S3BucketObject | Add-Member -type NoteProperty -name BucketName -value $b.BucketName
            $S3BucketObject | Add-Member -type NoteProperty -name CreationDate -value $b.CreationDate
            $S3BucketObject | Add-Member -type NoteProperty -name SizeGBytes -value $(& ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziCloudWatchS3GBUse.ps1") $DimensionName $DimensionValue $DimensionName2 $DimensionValue2 $Namespace $Region (Get-Date).AddDays(-1).GetDateTimeFormats()[70] (Get-Date).GetDateTimeFormats()[70] $AWSCredentialsProfile)

            $AllS3BucketObjects += $S3BucketObject
        }
    }
    return $AllS3BucketObjects
}
Get-OziS3Buckets @args