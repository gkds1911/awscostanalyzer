function Get-OziEC2InstancePrice
{
    param
    (
        $Region,
        $InstanceType,
        $OS
    )

    $EC2PricePath = ".\prices\ec2"
    $EC2PricesFile = Import-CSV -Path "$EC2PricePath\$Region.csv" -Delimiter ','

    foreach($Line in $EC2PricesFile)
    {
        if($Line."API Name" -eq $InstanceType)
        {
            $Price = $Line."$OS On Demand cost"
            if($Price -like '*hourly*')
            {
                $Price = $Price.Replace(" hourly","").Replace("$","")
            }
        }
    }
    return $Price
}
Get-OziEC2InstancePrice @args