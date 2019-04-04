function Get-OziEBSPrice
{
    param
    (
        $Region,
        $VolumeLabel,
        $Size,
        $Iops
    )
    
    $EBSPricePath = ".\prices\ebs\pricing-ebs.json"
    $EBSPricesObject = ConvertFrom-Json -InputObject $(Get-Content $EBSPricePath)

    if($VolumeLabel -eq "ebsSnapsToS3")
    {
        $Price = (((($EBSPricesObject.config.regions | Where-Object -Property region -eq $Region).types | Where-Object -Property name -eq $VolumeLabel).values | Where-Object rate -eq "perGBmoDataStored").prices | Select-Object -ExpandProperty USD)    
        $VolumePrice = $($Price/1*$Size/1)
    }
    else
    {
        $Price = (((($EBSPricesObject.config.regions | Where-Object -Property region -eq $Region).types | Where-Object -Property name -eq $VolumeLabel).values | Where-Object rate -eq "perGBmoProvStorage").prices | Select-Object -ExpandProperty USD)    
        $VolumePrice = $($Price/1*$Size/1)
        if($Iops)
        {
            $IOPrice = (((($EBSPricesObject.config.regions | Where-Object -Property region -eq $Region).types | Where-Object -Property name -eq $VolumeLabel).values | Where-Object rate -eq "perPIOPSreq").prices | Select-Object -ExpandProperty USD)
            $VolumePrice += ($Iops/1)*($IOPrice/1)
        }        
    }
    return $VolumePrice
}
Get-OziEBSPrice @args