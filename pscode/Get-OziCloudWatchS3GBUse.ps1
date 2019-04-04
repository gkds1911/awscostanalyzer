function Get-OziCloudWatchS3GBUse
{
    param(
        $DimensionName,
        $DimensionValue,
        $DimensionName2,
        $DimensionValue2,        
        $Namespace,
        $Region,
        $StartTime,
        $EndTime,
        $AWSCredentialsProfile
    )

    Clear-Variable -Name Average -ErrorAction SilentlyContinue
    Clear-Variable -Name Usage -ErrorAction SilentlyContinue
    Clear-Variable -Name Datapoint -ErrorAction SilentlyContinue
    Clear-Variable -Name GrandTotal -ErrorAction SilentlyContinue
    Clear-Variable -Name Dimension -ErrorAction SilentlyContinue 
    Clear-Variable -Name Dimension2 -ErrorAction SilentlyContinue

    $Dimension = New-Object Amazon.CloudWatch.Model.Dimension
    $Dimension.set_Name($DimensionName)
    $Dimension.set_Value($DimensionValue)   

    $Dimension2 = New-Object Amazon.CloudWatch.Model.Dimension
    $Dimension2.set_Name($DimensionName2)
    $Dimension2.set_Value($DimensionValue2)   

    [decimal]$Usage = ((Get-CWMetricStatistic -ProfileName $AWSCredentialsProfile -MetricName "BucketSizeBytes" -StartTime $StartTime -EndTime $EndTime -Period 3600 -Namespace $Namespace -Statistics "Average" -Dimension $Dimension,$Dimension2 -Region $Region).Datapoints.Average/1024/1024/1024)

    $Usage = [math]::Round($Usage,2)

    return $Usage
}
Get-OziCloudWatchS3GBUse @args