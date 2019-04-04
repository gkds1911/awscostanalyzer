function Get-OziCloudWatchCPUAverageUse {
    param($DimensionName,
          $DimensionValue,
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

    $Dimension = New-Object Amazon.CloudWatch.Model.Dimension
    $Dimension.set_Name($DimensionName)
    $Dimension.set_Value($DimensionValue)    


    $Usage = (Get-CWMetricStatistic -ProfileName $AWSCredentialsProfile -MetricName CPUUtilization -StartTime $StartTime -EndTime $EndTime -Period 3600 -Namespace $Namespace -Statistics "Average" -Dimension $Dimension -Region $Region)
    if($Usage -ne $NULL)
    {
        foreach($Datapoint in $Usage.Datapoints)
        {
	        $GrandTotal += $Datapoint.Average
        }
        if($Usage.Datapoints.Count -eq 0)
        {
            $Average = "No available datapoints"            
        }
        elseif($Usage.Datapoints.Count -gt 0)
        {
            $Average = $([math]::Round($($GrandTotal/$($Usage.Datapoints.Count)),2))   
        }
    }
    else
    {
        $Average = "Could not fetch information"
    }
    return $Average
}
Get-OziCloudWatchCPUAverageUse @args