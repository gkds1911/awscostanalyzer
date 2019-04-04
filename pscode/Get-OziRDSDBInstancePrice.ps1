function Get-OziRDSDBInstancePrice
{
    param
    (
        $Region,
        $InstanceType,
        $DBEngineVersionDescription
    )

    $RDSPricePath = ".\prices\rds"
    $RDSPricesFile = Import-CSV -Path "$RDSPricePath\$Region.csv" -Delimiter ','

    foreach($Line in $RDSPricesFile)
    {
        if($Line."API Name" -eq $InstanceType)
        {
            $Price = $Line."$DBEngineVersionDescription On Demand cost"
            if($Price -like '*hourly*')
            {
                $Price = $Price.Replace(" hourly","").Replace("$","")
            }
        }
    }
    return $Price
}
Get-OziRDSDBInstancePrice @args