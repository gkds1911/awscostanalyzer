function Get-OziVPCVpnConnections
{
    param
    (
        $Region,
        $AWSCredentialsProfile
    )
    $AllVPNConnections = @()
    $VPNConnectionObject = @()    
    $VPNConnections = (Get-EC2VpnConnection -Region $Region -ProfileName $AWSCredentialsProfile)

    if($VPNConnections.Count -gt 0)
    {
        foreach($v in $VPNConnections)
        {
            $VPNConnectionObject = New-Object System.Object
            $VPNConnectionObject | Add-Member -type NoteProperty -name Region -value $Region
            $VPNConnectionObject | Add-Member -type NoteProperty -name VpnGatewayId -value $v.VpnGatewayId
            $VPNConnectionObject | Add-Member -type NoteProperty -name VPNConnectionId -value $v.VPNConnectionId
            $VPNConnectionObject | Add-Member -type NoteProperty -name State -value $v.State
            $VPNConnectionObject | Add-Member -type NoteProperty -name CustomerGatewayId -value $v.CustomerGatewayId
            $VPNConnectionObject | Add-Member -type NoteProperty -name Type -value $v.Type 
            $VPNConnectionObject | Add-Member -type NoteProperty -name VgwTelemetryStatus0 -value  $(if(($v.VgwTelemetry.Status)) {$($v.VgwTelemetry.Status)[0]} else { "" } )
            $VPNConnectionObject | Add-Member -type NoteProperty -name VgwTelemetryMessage0 -value $(if(($v.VgwTelemetry.StatusMessage)) {$($v.VgwTelemetry.StatusMessage)[0]} else { "" } )
            $VPNConnectionObject | Add-Member -type NoteProperty -name VgwOutsideIpAddr0 -value $(if(($v.VgwTelemetry.OutsideIpAddress)) {$($v.VgwTelemetry.OutsideIpAddress)[0]} else { "" } )
            $VPNConnectionObject | Add-Member -type NoteProperty -name VgwTelemetryStatus1 -value  $(if(($v.VgwTelemetry.Status)) {$($v.VgwTelemetry.Status)[1]} else { "" } )
            $VPNConnectionObject | Add-Member -type NoteProperty -name VgwTelemetryMessage1 -value $(if(($v.VgwTelemetry.StatusMessage)) {$($v.VgwTelemetry.StatusMessage)[1]} else { "" } )
            $VPNConnectionObject | Add-Member -type NoteProperty -name VgwOutsideIpAddr1 -value $(if(($v.VgwTelemetry.OutsideIpAddress)) {$($v.VgwTelemetry.OutsideIpAddress)[1]} else { "" } )
            $VPNConnectionObject | Add-Member -type NoteProperty -name VpnLink -value $(& ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziVPCVpnStatus.ps1") $Region $VPNConnectionObject.VgwTelemetryStatus0 $VPNConnectionObject.VgwTelemetryStatus1)
            #$(Get-OziVPCVpnStatus "$($VPNConnectionObject.VgwTelemetryStatus0)" "$($VPNConnectionObject.VgwTelemetryStatus1)")
            $VPNConnectionObject | Add-Member -type NoteProperty -name PricePerHour -value 0.05 #TODO
            $AllVPNConnections += $VPNConnectionObject
        }
    }
    return $AllVPNConnections
}
Get-OziVPCVpnConnections @args