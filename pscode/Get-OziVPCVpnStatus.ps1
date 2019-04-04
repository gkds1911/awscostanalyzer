function Get-OziVPCVpnStatus
{
    param
    (
        $Status0,
        $Status1
    )
    if(($Status0 -eq "DOWN") -and ($Status1 -eq "DOWN"))
    {
        $Status = "DOWN"
    }
    elseif(($Status0 -eq "UP") -and ($Status1 -eq "DOWN"))
    {
        $Status = "0 IS UP"
    }
    elseif(($Status0 -eq "DOWN") -and ($Status1 -eq "UP"))
    {
        $Status = "1 IS UP"
    }
    elseif(($Status0 -eq "UP") -and ($Status1 -eq "UP"))
    {
        $Status = "UP"
    }
    return $Status
}
Get-OziVPCVpnStatus @args