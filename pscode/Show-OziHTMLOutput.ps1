function Show-OziHTMLOutput
{
    param
    (
        $AWSCredentialsProfile,
        $HTMLOutputFile,
        $AllInstanceObjects,
        $AllSnapshotObjects,
        $AllVolumeObjects,
        $AllReservedInstanceObjects,
        $AllEC2AddressObjects,
        $AllRDSDBInstanceObjects,
        $AllRDSDBReservedInstanceObjects,
        $AllVPNConnections,
        $AllS3BucketObjects
    )

    $Header = Get-Content -Path .\tpl\header.html
    $Footer = Get-Content -Path .\tpl\footer.html

    $Slides =  "            <section>
                <aside class='notes'>
                    Commentaires sur les instances EC2 : Nombre total (compte), puis stopped (compte), underused (compte) et out of date (compte) (generation precedente).
                </aside>
                <div class='ozi_slidetitle'><h2>Services surveill&eacute;s</h2></div>
                <div class='ozi_slidecontent'>
                    <ul>
                        <li class='contenttitle'>EC2</li>
                        <ul>
                            $(
                                ## Instances 
                                Write-Host "`n$(get-date) - INSTANCES"
                                ## READ: https://blog.cloudability.com/getting-scientific-about-over-provisioned-aws-instances/
                                $EC2Instances                           = $AllInstanceObjects
                                $EC2InstancesPricing                    = 0 
                                $EC2InstancesStopped                    = $($EC2Instances | Where-Object { $_.State -eq 'stopped' } )
                                $EC2InstancesStoppedPricing             = 0                            
                                $EC2InstancesUnderused                  = $($EC2Instances | Where-Object { $_.IsUnderused -eq $TRUE } )
                                $EC2InstancesUnderusedPricing           = 0
                                $EC2InstancesOutOfDate                  = $($EC2Instances | Where-Object { $_.IsLatestGeneration -eq $FALSE })
                                $EC2InstancesOutOfDatePricing           = 0
                                $EC2ReservedInstances                   = $($AllReservedInstanceObjects)
                                $EC2ReservedInstancesActive             = $(($EC2ReservedInstances) | Where-Object -Property State -eq 'active')
                                $EC2InstancesUnderusedDowngrade         = 0
                                $EC2InstancesUnderusedDowngradePricing  = 0

                                foreach($i in $EC2Instances)
                                {
                                    if($i -in $EC2InstancesStopped)
                                    {
                                        $EC2InstancesStoppedPricing += $((([float]$i.PricePerHourWindows)*24)*30) 
                                        Write-Host "$(get-date) - $($i.Region) -- Supprimez l'instance arretee $($i.InstanceId) pour economiser $([Math]::Round(((([float]$i.PricePerHourWindows)*24)*30),2))$ par mois."
                                    }
                                    if($i -in $EC2InstancesUnderused)
                                    {
                                        if($i.CheaperInstancePrice -ne 0)
                                        {
                                            $EC2InstancesUnderusedPricing += $((([float]$i.PricePerHourWindows)*24)*30) 
                                            $EC2InstancesUnderusedDowngrade = $((([float]$i.CheaperInstancePrice)*24)*30) 
                                            $EC2InstancesUnderusedDowngradePricing += $EC2InstancesUnderusedDowngrade          
                                            
                                            Write-Host "$(get-date) - $($i.Region) -- Redimensionnez l'instance $($i.InstanceId) vers $($i.CheaperInstanceType) pour economiser $(([Math]::Round(((([float]$i.PricePerHourWindows)*24)*30),2))-$([Math]::Round($EC2InstancesUnderusedDowngrade,2)))$ par mois. ($([Math]::Round($EC2InstancesUnderusedDowngrade,2))$ au lieu de $([Math]::Round(((([float]$i.PricePerHourWindows)*24)*30),2))$)"
                                        }
                                    }
                                    if($i -in $EC2InstancesOutOfDate)
                                    {
                                        #$([Math]::Round(((([float]$i.PricePerHourWindows)*24)*30),2))
                                        #$([Math]::Round([Math]::Round([float]($i.PricePerHourWindows)*24,2)*30,2))
                                        $EC2InstancesOutOfDatePricing += $((([float]$i.PricePerHourWindows)*24)*30)
                                        Write-Host "$(get-date) - $($i.Region) -- Mettez a jour l'instance $($i.InstanceId) vers la derniere generation." 
                                    }
                                    $EC2InstancesPricing += $((([float]$i.PricePerHourWindows)*24)*30)
                                }

                                if($EC2InstancesStoppedPricing -gt 0)
                                {
                                    Write-Host "$(get-date) --- Economisez $([Math]::Round($EC2InstancesStoppedPricing,2))$ en supprimant $($EC2InstancesStopped.Count) instances arretees."  
                                }

                                if($EC2InstancesUnderusedDowngradePricing -gt 0)
                                {
                                    Write-Host "$(get-date) --- Economisez $([Math]::Round($EC2InstancesUnderusedPricing-$EC2InstancesUnderusedDowngradePricing,2))$ en redimensionnant $($EC2InstancesUnderused.Count) instances sous-utilisees." 
                                }
                            )
                            <li class='fragment'>Instances au total: <span class='fragment'>$(($EC2Instances).Count)</li></span>                        
                            <li class='fragment'>Instances arr&ecirc;t&eacute;es: <span class='fragment'>$($($EC2InstancesStopped).Count)</li></span>
                            <li class='fragment'>Instances sous-utilis&eacute;es: <span class='fragment'>$($($EC2InstancesUnderused).Count)</li></span>
                            <li class='fragment'>Instances d&eacute;pass&eacute;es: <span class='fragment'>$($($EC2InstancesOutOfDate).Count)</li></span>
                            <li class='fragment'>Instances r&eacute;serv&eacute;es: <span class='fragment'>$($($EC2ReservedInstancesActive).Count)</li></span>
                        </ul>
                    </ul>
                </div>
                <div class='ozi_slidebottom'>
            </section>
            <section>
                <aside class='notes'>
                    Compteurs sur les snapshots (compte, taille), volumes non attaches (compte, taille), attaches 'off' (compte, taille), et EIP non assignees (compte).
                </aside>  
                <div class='ozi_slidetitle'><h2>Services surveill&eacute;s</h2></div>         
                <div class='ozi_slidecontent'>
                    <ul>
                        <li class='contenttitle'>EC2</li>   
                        <ul>
                            $(
                                ## Snapshots
                                Write-Host "`n$(get-date) - SNAPSHOTS"
                                ## Read https://forums.aws.amazon.com/thread.jspa?messageID=693781
                                $EC2Snapshots                           = $AllSnapshotObjects
                                $EC2SnapshotsGroups                     = $EC2Snapshots | Group-Object -Property VolumeId
                                $EC2SnapshotsGroupsOldestSnapshotsOnly  = @()

                                foreach($sng in $EC2SnapshotsGroups)
                                {
                                    if(($sng | Where-Object { $_.Count -gt 1}).Group)
                                    {
                                        $EC2SnapshotsGroupsOldestSnapshotsOnly += $(($sng | Where-Object { $_.Count -gt 1}).Group | Sort-Object -Property StartTime | Select-Object -First 1)
                                    }
                                    else
                                    {
                                        $EC2SnapshotsGroupsOldestSnapshotsOnly += ($sng.Group)
                                    }
                                }
                                $EC2SnapshotsGroupsOldestSnapshotsOnly  | % { $EC2SnapshotsGroupsSize       += $_.Size}
                                $EC2SnapshotsGroupsOldestSnapshotsOnly  | % { $EC2SnapshotsGroupsPricing    += $_.PricePerMonth}
                                
                                ## Usable vars : EC2SnapshotsGroupsOldestSnapshotsOnly, EC2SnapshotsGroupsSize, EC2SnapshotsGroupsPricing
                                
                                ## Snapshots out of date
                                $EC2SnapshotsOutOfDate                          = $($EC2Snapshots | Where-Object { ($_.StartTime) -lt ($([datetime]::Now).AddDays(-7)) }) 
                                $EC2SnapshotsOutOfDateGroups                    = $EC2SnapshotsOutOfDate | Group-Object -Property VolumeId
                                $EC2SnapshotsOutOfDateGroupsOldestSnapshotsOnly  = @()
                                #$sng = ""

                                foreach($sng in $EC2SnapshotsOutOfDateGroups)
                                {
                                    if(($sng | Where-Object { $_.Count -gt 1}).Group)
                                    {
                                        $EC2SnapshotsOutOfDateGroupsOldestSnapshotsOnly += $(($sng | Where-Object { $_.Count -gt 1}).Group | Sort-Object -Property StartTime | Select-Object -First 1)
                                    }
                                    else
                                    {
                                        $EC2SnapshotsOutOfDateGroupsOldestSnapshotsOnly += ($sng.Group)
                                    }  
                                }

                                $EC2SnapshotsOutOfDateGroupsOldestSnapshotsOnly  | % { 
                                    Write-Host "$(Get-Date) - $($_.Region) -- Supprimez le snapshot $($_.SnapshotId) pour economiser $([Math]::Round(($_.PricePerMonth),2))$ par mois."
                                    $EC2SnapshotsOutOfDateGroupsSize     += $_.Size
                                    $EC2SnapshotsOutOfDateGroupsPricing  += $_.PricePerMonth }

                                if($EC2SnapshotsOutOfDateGroupsPricing -gt 0)
                                {
                                    Write-Host "$(get-date) --- Economisez $([Math]::Round($EC2SnapshotsOutOfDateGroupsPricing,2))$ en supprimant $($EC2SnapshotsOutOfDateGroupsOldestSnapshotsOnly.Count) snapshots vieux de plus d'une semaine."
                                }

                                ## Usable vars : EC2SnapshotsOutOfDateGroupsOldestSnapshotsOnly, EC2SnapshotsOutOfDateGroupsSize, EC2SnapshotsOutOfDateGroupsPricing

                                ## Volumes
                                Write-Host "`n$(get-date) > VOLUMES"

                                $EC2Volumes                                     = $($AllVolumeObjects)
                                $EC2VolumesSize                                 = 0
                                $EC2VolumesPricing                              = 0
                                $EC2VolumesUnattached                           = $($EC2Volumes | Where-Object { ($_.AttachmentState -eq $NULL) } )
                                $EC2VolumesUnattachedPricing                    = 0
                                $EC2VolumesUnattachedSize                       = 0
                                $EC2VolumesAttachedToStoppedInstances           = @($EC2Volumes | Where-Object { ($_.AttachmentInstanceState -eq 'stopped') })
                                $EC2VolumesAttachedToStoppedInstancesSize       = 0                                

                                foreach($i in $EC2Volumes)
                                {
                                    if($i -in $EC2VolumesUnattached)
                                    {
                                        $EC2VolumesUnattachedPricing += $i.PricePerMonth
                                        $EC2VolumesUnattachedSize += $i.Size
                                        Write-Host "$(get-date) - $($i.Region) -- Supprimez le volume non-attache $($i.VolumeId) ($($i.Size)GB) ($($i.VolumeType)) pour economiser $([Math]::Round(($i.PricePerMonth),2))$ par mois."
                                    }
                                    else
                                    {
                                        if($i -in $EC2VolumesAttachedToStoppedInstances)
                                        {
                                            Write-Host "$(get-date) - $($i.Region) -- Supprimez le volume attache a une instance arretee $($i.VolumeId) ($($i.Size)GB) ($($i.VolumeType)) pour economiser $([Math]::Round(($i.PricePerMonth),2))$ par mois."
                                            #$EC2VolumesAttachedToStoppedInstances           += $i
                                            $EC2VolumesAttachedToStoppedInstancesPricing    += $i.PricePerMonth
                                            $EC2VolumesAttachedToStoppedInstancesSize       += $i.Size   
                                        }         
                                    }
                                    $EC2VolumesPricing += $i.PricePerMonth
                                    $EC2VolumesSize += $i.Size    
                                }

                                if($EC2VolumesUnattachedPricing -gt 0)
                                {
                                    Write-Host "$(get-date) --- Economisez $([Math]::Round($EC2VolumesUnattachedPricing,2))$ en supprimant $($EC2VolumesUnattached.Count) volumes non-attaches."            
                                }
                                if($EC2VolumesAttachedToStoppedInstancesPricing -gt 0)
                                {
                                    Write-Host "$(get-date) --- Economisez $([Math]::Round($EC2VolumesAttachedToStoppedInstancesPricing,2))$ en supprimant $($EC2VolumesAttachedToStoppedInstances.Count) volumes attaches a des instances arretees."
                                }

                                ## EIP Addresses
                                Write-Host "`n$(get-date) - EC2ADDRESSES"
                                $EC2Addresses                           = $($AllEC2AddressObjects)
                                $EC2AddressUnassociated                 = ($EC2Addresses | Where-Object { ($_.AssociationId -eq $NULL) } )
                                $EC2AddressUnassociatedPricing          = 0
                                $EC2AddressUnassociatedPricingPerRegion = 0
                                # TODO
                                $EC2AddressUnassociatedFirstOnePricing  = 7.32
                                $EC2AddressUnassociatedOtherOnesPricing = 3.66

                                foreach($Region in $AWSRegions)
                                { 
                                    $EC2AddressUnassociatedPerRegion = ($EC2Addresses | Where-Object { ($_.Region -eq $Region) -and ($_.AssociationId -eq $NULL) } )
                                    $EC2AddressUnassociatedAdditionalAddresses = ($EC2AddressUnassociatedPerRegion.Count)-1
                                    
                                    if($EC2AddressUnassociatedPerRegion.Count -eq 1)
                                    {
                                        $EC2AddressUnassociatedPricing += $EC2AddressUnassociatedFirstOnePricing
                                        Write-Host "$(get-date) - $($Region) -- Supprimez l'EIP non attachee $($EC2AddressUnassociatedPerRegion.AllocationId)"
                                    }
                                    if($EC2AddressUnassociatedPerRegion.Count -gt 1)
                                    {
                                        $EC2AddressUnassociatedPricing += $($EC2AddressUnassociatedFirstOnePricing+($EC2AddressUnassociatedOtherOnesPricing*$EC2AddressUnassociatedAdditionalAddresses))
                                        foreach($eip in $EC2AddressUnassociatedPerRegion)
                                        {
                                            Write-Host "$(get-date) - $($Region) -- Supprimez l'EIP non attachee $($eip.AllocationId)"
                                        }
                                    }
                                }

                                if($EC2AddressUnassociatedPricing -gt 0)
                                {
                                    Write-Host "$(get-date) --- Economisez $([Math]::Round($EC2AddressUnassociatedPricing,2))$ en supprimant $(($EC2AddressUnassociated).Count) EIPs non attachees."
                                }
                                
                            )
                            <li class='fragment'>Anciens snapshots: <span class='fragment'>$($($EC2SnapshotsOutOfDateGroupsOldestSnapshotsOnly).Count) ($($EC2SnapshotsOutOfDateGroupsSize)GB)</li></span>
                            <li class='fragment'>Volumes non-attach&eacute;s: <span class='fragment'>$($($EC2VolumesUnattached).Count) ($($EC2VolumesUnattachedSize)GB)</li></span>
                            <li class='fragment'>Volumes 'offline': <span class='fragment'>$($($EC2VolumesAttachedToStoppedInstances).Count) ($($EC2VolumesAttachedToStoppedInstancesSize)GB)</li></span>
                            <li class='fragment'>Elastic IPs non attribu&eacute;es: <span class='fragment'>$($($EC2AddressUnassociated).Count)</li></span>
                        </ul>
                    </ul>
                </div>
                <div class='ozi_slidebottom'>
            </section>
            <section>
                <div class='ozi_slidetitle'><h2>Services surveill&eacute;s</h2></div>
                <div class='ozi_slidecontent'>
                    <ul>
                        <li class='contenttitle'>RDS</li>
                        <ul>
                            $(
                                Write-Host "`n$(get-date) - RDS Instances"
                                ## $RDSInstancesCount = $($AllRDSDBInstanceObjects).Count
                                $RDSInstances                   = $AllRDSDBInstanceObjects
                                $RDSInstancesPricing            = 0
                                $RDSInstancesStopped            = $($RDSInstances | Where-Object { ($_.DBInstanceStatus -eq 'stopped') } )
                                $RDSInstancesStoppedPricing     = 0
                                $RDSInstancesUnderused          = $($RDSInstances | Where-Object { ($_.IsUnderused -eq $TRUE) } )                         
                                $RDSInstancesUnderusedPricing   = 0                        
                                $RDSInstancesOutOfDate          = $($RDSInstances | Where-Object { ($_.IsLatestGeneration -eq $FALSE) } )
                                $RDSInstancesOutOfDatePricing   = 0
                                $RDSInstancesUnderusedDowngrade  = 0
                                $RDSInstancesUnderusedDowngrade  = 0
                                $RDSInstancesUnderusedUpgradable = 0
                                #TODO
                                $RDSReservedInstances = $AllRDSDBReservedInstanceObjects
                                # $RDSReservedInstancesCount = $(($AllRDSDBReservedInstanceObjects).Count)
                                foreach($i in $RDSInstances)
                                {
                                    
                                    # Write-Host "$(get-date) - $($i.Region) -- Downgrade instance $($i.InstanceId) to $($i.CheaperInstanceType) to save $($([Math]::Round([Math]::Round([float]($i.PricePerHourWindows)*24,2)*30,2))-$EC2InstancesUnderusedDowngrade)$ per month. ($($EC2InstancesUnderusedDowngrade)$ instead of $($([Math]::Round([Math]::Round([float]($i.PricePerHourWindows)*24,2)*30,2)))$)"
                                    # Write-Host "$(get-date) - $($i.Region) -- Update instance $($i.InstanceId) to the latest generation."                        
                                    if($i -in $RDSInstancesStopped)
                                    {
                                        $RDSInstancesStoppedPricing += $([Math]::Round([Math]::Round([float]($i.PricePerHour)*24,2)*30,2))
                                        Write-Host "$(get-date) - $($i.Region) -- Supprimez l'instance RDS arretee $($i.DbiResourceId) pour economiser $([Math]::Round(((([float]$i.PricePerHour)*24)*30),2))$ par mois."
                                    }
                                    if($i -in $RDSInstancesUnderused)
                                    {
                                        if($i.CheaperInstancePrice -ne 0)
                                        {
                                            $RDSInstancesUnderusedPricing += $([Math]::Round([Math]::Round([float]($i.PricePerHour)*24,2)*30,2))
                                            $RDSInstancesUnderusedDowngrade = $([Math]::Round([Math]::Round([float]($i.CheaperInstancePrice)*24,2)*30,2))
                                            $RDSInstancesUnderusedDowngradePricing += $RDSInstancesUnderusedDowngrade
                                            $RDSInstancesUnderusedUpgradable += 1
                                            Write-Host "$(get-date) - $($i.Region) -- Redimensionnez l'instance $($i.DbiResourceId) vers $($i.CheaperInstanceType) pour economiser $($([Math]::Round([Math]::Round([float]($i.PricePerHour)*24,2)*30,2))-$RDSInstancesUnderusedDowngrade)$ par mois. ($($RDSInstancesUnderusedDowngrade)$ au lieu de $($([Math]::Round([Math]::Round([float]($i.PricePerHour)*24,2)*30,2)))$)"
                                        }
                                    }
                                    if($i -in $RDSInstancesOutOfDate)
                                    {
                                        $RDSInstancesOutOfDatePricing += $([Math]::Round([Math]::Round([float]($i.PricePerHour)*24,2)*30,2))
                                        Write-Host "$(get-date) - $($i.Region) -- Mettez a jour l'instance $($i.DbiResourceId) vers la derniere generation."
                                    }
                                    
                                    #$RDSInstancesPricing += ([Math]::Round(([float]($i.PricePerHour)*24,2)*30),2)
                                    $RDSInstancesPricing += $([Math]::Round([Math]::Round([float]($i.PricePerHour)*24,2)*30,2))
                                }
                                
                                ## Pas d'estimation du coût des snapshots
                                ## READ: https://stackoverflow.com/questions/34578126/how-to-know-the-db-backup-storage-size-for-amazon-rds-instance
                                if($RDSInstancesStoppedPricing -gt 0)
                                {
                                    Write-Host "$(get-date) --- Economisez $([Math]::Round($RDSInstancesStoppedPricing,2))$ en supprimant $($RDSInstancesStopped.Count) instances arretees."
                                }
                                if($RDSInstancesUnderusedDowngradePricing -gt 0)
                                {
                                    Write-Host "$(get-date) --- Economisez $([Math]::Round($RDSInstancesUnderusedPricing-$RDSInstancesUnderusedDowngradePricing,2))$ en redimensionnant $($RDSInstancesUnderusedUpgradable) instances sous-utilisees."
                                }
                            )

                            <li class='fragment'>Instances RDS DB arr&ecirc;t&eacute;es: <span class='fragment'>$($($RDSInstancesStopped).Count)</li></span>
                            <li class='fragment'>Instances RDS DB sous-utilis&eacute;es: <span class='fragment'>$($($RDSInstancesUnderused).Count)</li></span>
                            <li class='fragment'>Instances RDS DB d&eacute;pass&eacute;es: <span class='fragment'>$($($RDSInstancesOutOfDate).Count)</li></span>
                            <li class='fragment'>Instances RDS DB r&eacute;serv&eacute;es: <span class='fragment'>$($($RDSReservedInstances).Count)</li></span>
                        </ul>
                    </ul>
                </div>
                <div class='ozi_slidebottom'>
            </section>
            <section>
                <div class='ozi_slidetitle'><h2>Services surveill&eacute;s</h2></div>
                <div class='ozi_slidecontent'>
                    <ul>
                        <li class='fragment contenttitle'>VPC</li>
                        <ul>
                            $(
                                ## VPN CONNECTIONS
                                Write-Host "`n$(get-date) - VPN Connections"
                                $VPCVpnConnections = $($AllVPNConnections)
                                $VPCVpnConnectionsPricing = 0.00
                                $VPCVpnConnectionsDown = $($AllVPNConnections | Where-Object { $_.VpnLink -eq "DOWN" })
                                $VPCVpnConnectionsDownPricing = 0.00

                                if($($($VPCVpnConnectionsDown).Count) -eq 0)
                                {
                                    if($($($VPCVpnConnections).Count) -eq 0)
                                    {
                                        Write-Output "<li class='fragment'>Pas de connexions VPN configur&eacute;es</li>"    
                                    }
                                    else
                                    {
                                        Write-Output "<li class='fragment'>Toutes les connexions VPN sont utilis&eacute;es</li>"
                                    }
                                }
                                elseif($($($VPCVpnConnectionsDown).Count) -eq 1)
                                {
                                    Write-Output "<li class='fragment'>Connexions VPN inutilis&eacute;e: <span class='fragment'>$($($VPCVpnConnectionsDown).Count)</li></span>"
                                }
                                elseif($($($VPCVpnConnectionsDown).Count) -ge 2)    
                                {
                                    Write-Output "<li class='fragment'>Connexions VPN inutilis&eacute;es: <span class='fragment'>$($($VPCVpnConnectionsDown).Count)</li></span>"
                                }

                                foreach($i in $VPCVpnConnections)
                                {
                                    if($i -in $VPCVpnConnectionsDown)
                                    {
                                        ## REUSE: Prix d'une connection VPN non utilis&eacute;e par mois
                                        $VPCVpnConnectionsDownPricing += $([Math]::Round([Math]::Round([float]($i.PricePerHour)*24,2)*30,2))
                                    }
                                    $VPCVpnConnectionsPricing += $([Math]::Round([Math]::Round([float]($i.PricePerHour)*24,2)*30,2))
                                }

                                if($VPCVpnConnectionsPricing -gt 0)
                                {
                                    Write-Host "$(get-date) --- Economisez $($VPCVpnConnectionsPricing)$ en supprimant $($VPCVpnConnectionsDown.Count) connexions VPN down."   
                                }
                                ## S3 Buckets
                                $S3Buckets = $($AllS3BucketObjects)
                                $S3BucketsSize = 0
                                $S3Buckets | %{ $S3BucketsSize += $_.SizeGBytes }
                                $S3BucketsPricing = $S3BucketsSize*0.0245
                                # TODO : Faire un parser en python pour récuperer les infos   https://aws.amazon.com/s3/pricing/      
                            )
                        </ul>
                        <li class='fragment contenttitle'>S3</li>
                        <ul>
                            <li class='fragment'>Buckets S3: <span class='fragment'>$($($S3Buckets).Count) buckets <span class='fragment'>et $($S3BucketsSize)GB occup&eacute;s</li></span></span>
                        </ul>
                    </ul>
                </div>
                <div class='ozi_slidebottom'>
            </section>
            <section>
                <div class='ozi_slidetitle'><h2>Co&ucirc;ts actuels</h2></div>
                <div class='ozi_tableplacement'>
                $(
                    $TotalCost = $EC2InstancesPricing+$EC2SnapshotsGroupsPricing+$EC2VolumesPricing+$RDSInstancesPricing+$EC2AddressUnassociatedPricing+$VPCVpnConnectionsPricing+$S3BucketsPricing
                )
                <table>
                <tbody>
                <tr>
                    <th>Ressource</th>
                    <th>Compte</th>
                    <th align='right'>Co&ucirc;t</th>
                </tr>
                <tr>
                    <td style='padding-top: 15px;'>Instances EC2</td>
                    <td>$($($EC2Instances).Count)</td>
                    <td align='right'>$([math]::Round(($EC2InstancesPricing),2))</td>
                </tr>
                <tr>
                    <td>Snapshots EC2</td>
                    <td>$($($EC2SnapshotsGroupsOldestSnapshotsOnly).Count)</td>
                    <td align='right'>$([math]::Round(($EC2SnapshotsGroupsPricing),2))</td>
                </tr>
                <tr>
                    <td>Volumes EBS</td>
                    <td>$($($EC2Volumes).Count)</td>
                    <td align='right'>$([math]::Round(($EC2VolumesPricing),2))</td>
                </tr>
                <tr>
                    <td>EIP non associ&eacute;es</td>
                    <td>$($($EC2AddressUnassociated).Count)</td>
                    <td align='right'>$([math]::Round(($EC2AddressUnassociatedPricing),2))</td>
                </tr>
                <tr>
                    <td>VPN</td>
                    <td>$($($VPCVpnConnections).Count)</td>
                    <td align='right'>$([math]::Round(($VPCVpnConnectionsPricing),2))</td>
                </tr>
                <tr>
                    <td>Buckets S3</td>
                    <td>$($($S3Buckets).Count)</td>
                    <td align='right'>$([math]::Round(($S3BucketsPricing),2))</td>
                </tr>
                </tr>
                <tr>
                    <td style='padding-bottom: 15px;'>Instances RDS</td>
                    <td>$($($RDSInstances).Count)</td>
                    <td align='right'>$([math]::Round(($RDSInstancesPricing),2))</td>
                </tr>
                </tr>
                <tr class='ozi_lasttablerow'>
                    <td>Total </td>
                    <td>&nbsp;</td>
                    <td align='right'>$([math]::Round(($TotalCost),2))$</td>
                </tr>
                </tbody>
                </table>
                </div>
                <div class='ozi_slidebottom'>
            </section>
            <section>
                <div class='ozi_slidetitle'><h2>Economies possibles</h2></div>
                <div class='ozi_tableplacement'>
                $(
                    $GlobalSavings = $EC2InstancesStoppedPricing+(($EC2InstancesUnderusedPricing-$EC2InstancesUnderusedDowngradePricing))+$EC2InstancesOutOfDatePricing+$EC2SnapshotsOutOfDateGroupsPricing
                    $GlobalSavings += $EC2VolumesUnattachedPricing+$EC2VolumesAttachedToStoppedInstancesPricing+$EC2AddressUnassociatedPricing+$VPCVpnConnectionsDownPricing
                    $GlobalSavings += $RDSInstancesStoppedPricing+$RDSInstancesUnderusedPricing+$RDSInstancesOutOfDatePricing
                )
                <table style='font-size: large;'>
                <tbody>
                <tr>
                    <th>Ressource</th>
                    <th>Compte</th>
                    <th align='right'>Economie</th>
                </tr>
                <tr>
                    <td style='padding-top: 15px;'>Instances arr&ecirc;t&eacute;es</td>
                    <td>$($($EC2InstancesStopped).Count)</td>
                    <td align='right'>$([math]::Round(($EC2InstancesStoppedPricing),2))</td>
                </tr>
                <tr>
                    <td>Redim. instances sous-utilis&eacute;es</td>
                    <td>$($($EC2InstancesUnderused).Count)</td>
                    <td align='right'>$([math]::Round(($EC2InstancesUnderusedPricing-$EC2InstancesUnderusedDowngradePricing),2))</td>
                </tr>
                <tr>
                    <td>Instances d&eacute;pass&eacute;es</td>
                    <td>$($($EC2InstancesOutOfDate).Count)</td>
                    <td align='right'>$([math]::Round(($EC2InstancesOutOfDatePricing),2))</td>
                </tr>
                <tr>
                    <td>Snapshots d&eacute;pass&eacute;s</td>
                    <td>$($($EC2SnapshotsOutOfDateGroupsOldestSnapshotsOnly).Count)</td>
                    <td align='right'>$([math]::Round(($EC2SnapshotsOutOfDateGroupsPricing),2))</td>
                </tr>
                <tr>
                    <td>Volumes non attach&eacute;s</td>
                    <td>$($($EC2VolumesUnattached).Count)</td>
                    <td align='right'>$([math]::Round(($EC2VolumesUnattachedPricing),2))</td>
                </tr>
                <tr>
                    <td>Volumes 'off'</td>
                    <td>$($($EC2VolumesAttachedToStoppedInstances).Count)</td>
                    <td align='right'>$([math]::Round(($EC2VolumesAttachedToStoppedInstancesPricing),2))</td>
                </tr>
                <tr>
                    <td>EIP non associ&eacute;es</td>
                    <td>$($($EC2AddressUnassociated).Count)</td>
                    <td align='right'>$([math]::Round(($EC2AddressUnassociatedPricing),2))</td>
                </tr>
                <tr>
                    <td>VPN arr&ecirc;t&eacute;s</td>
                    <td>$($($VPCVpnConnectionsDown).Count)</td>
                    <td align='right'>$([math]::Round(($VPCVpnConnectionsDownPricing),2))</td>
                </tr>
                <tr>
                    <td>Instances RDS arr&ecirc;t&eacute;es</td>
                    <td>$($($RDSInstancesStopped).Count)</td>
                    <td align='right'>$([math]::Round(($RDSInstancesStoppedPricing),2))</td>
                </tr>
                <tr>
                    <td>Instances RDS sous-utilis&eacute;es</td>
                    <td>$($($RDSInstancesUnderused).Count)</td>
                    <td align='right'>$([math]::Round(($RDSInstancesUnderusedPricing),2))</td>
                </tr>
                <tr>
                    <td style='padding-bottom: 15px;'>Instances RDS d&eacute;pass&eacute;es</td>
                    <td>$($($RDSInstancesOutOfDate).Count)</td>
                    <td align='right'>$([math]::Round(($RDSInstancesOutOfDatePricing),2))</td>
                </tr>
                <tr class='ozi_lasttablerow'>
                    <td>Total </td>
                    <td>&nbsp;</td>
                    <td align='right'>$([math]::Round(($GlobalSavings),2))$</td>
                </tr>
                </tbody>
                </table>
                </div>
                <div class='ozi_slidebottom'>
            </section> 
            <section>
                <div class='ozi_slidetitle'><h2>Economies possibles (%)</h2></div>
                <div class='ozi_tableplacement'>
                <table>
                <tbody>
                <tr>
                    <th>Ressource</th>
                    <th>Co&ucirc;t actuel</th>
                    <th align='right'>Economie</th>
                </tr>
                <tr>
                    <td style='padding-top: 15px;'>Instances EC2</td>
                    <td>$([math]::Round(($EC2InstancesPricing),2))</td>
                    <td align='right'>$( if($EC2InstancesPricing -ne 0) { Write-Output "$( [math]::Round(((($EC2InstancesStoppedPricing+($EC2InstancesUnderusedPricing-$EC2InstancesUnderusedDowngradePricing)+$EC2InstancesOutOfDatePricing)/$EC2InstancesPricing)*100),2) )%" } else { Write-Output "N/A" } )</td>
                </tr>
                <tr>
                    <td>Snapshots EC2</td>
                    <td>$([math]::Round(($EC2SnapshotsGroupsPricing),2))</td>
                    <td align='right'>$( if($EC2SnapshotsGroupsPricing -ne 0) { Write-Output "$( [math]::Round((($EC2SnapshotsOutOfDateGroupsPricing/$EC2SnapshotsGroupsPricing)*100),2) )%" } else { Write-Output "N/A" } )</td>
                </tr>
                <tr>
                    <td>Volumes EBS</td>
                    <td>$([math]::Round(($EC2VolumesPricing),2))</td>
                    <td align='right'>$( if($EC2VolumesPricing -ne 0) { Write-Output "$( [math]::Round(((($($EC2VolumesUnattachedPricing+$EC2VolumesAttachedToStoppedInstancesPricing))/$EC2VolumesPricing)*100),2) )%" } else { Write-Output "N/A" } )</td>
                </tr>
                <tr>
                    <td>EIP 'off'</td>
                    <td>$([math]::Round(($EC2AddressUnassociatedPricing),2))</td>
                    <td align='right'>$( if($EC2AddressUnassociatedPricing -ne 0) { Write-Output "$( [math]::Round((($EC2AddressUnassociatedPricing/$EC2AddressUnassociatedPricing)*100),2) )%" } else { Write-Output "N/A" } )</td>
                </tr>
                <tr>
                    <td>VPN</td>
                    <td>$([math]::Round(($VPCVpnConnectionsPricing),2))</td>
                    <td align='right'>$( if($VPCVpnConnectionsPricing -ne 0) { Write-Output "$([math]::Round((($VPCVpnConnectionsDownPricing/$VPCVpnConnectionsPricing)*100),2)) %" } else { Write-Output "N/A" } )</td>
                </tr>
                <tr>
                    <td>Buckets S3</td>
                    <td>$([math]::Round(($S3BucketsPricing),2))</td>
                    <td align='right'>N/A</td>
                </tr>
                <tr>
                    <td style='padding-bottom: 15px;'>Instances RDS</td>
                    <td>$([math]::Round(($RDSInstancesPricing),2))</td>
                    <td align='right'>$( if($RDSInstancesPricing -ne 0) { Write-Output "$( [math]::Round(((($RDSInstancesStoppedPricing+$RDSInstancesUnderusedPricing+$RDSInstancesOutOfDatePricing)/$RDSInstancesPricing)*100),2) ) %" } else { Write-Output "N/A" } )</td>
                </tr> 
                <tr class='ozi_lasttablerow'>
                    <td>Total </td>
                    <td>$([math]::Round(($TotalCost),2))$</td>
                    <td align='right'>$( [math]::Round((($GlobalSavings/$TotalCost)*100),2) )%</td>
                </tr> 
                </tbody>
                </table>
                </div>
                <div class='ozi_slidebottom'>
            </section> 
            <section> 
                <div class='ozi_finalslide'>
                    <div class='ozi_finalplacement'>
                        <span>
                            Nous sommes ravis de vous avoir fait &eacute;conomiser la somme de 
                        </span>
                    </div>
                    <div class='ozi_finalsavings'>$([math]::Round(($GlobalSavings),2))$</div>
                    <div class='ozi_finallogo'>
                        <img height='125' width='125' data-src='static/img/Logo-carre-Groupe-blanc.png'> 
                    </div>
                </div>
            </section>"

    Write-Host "`n$(get-date) - Utilisation actuelle"
    Write-Host "$(get-date) - Instances EC2 : $($EC2Instances.Count) : $([math]::Round(($EC2InstancesPricing),2))$"
    Write-Host "$(get-date) - Snapshots EC2 : $($EC2SnapshotsGroupsOldestSnapshotsOnly.Count) : $([math]::Round(($EC2SnapshotsGroupsPricing),2))$"
    Write-Host "$(get-date) - Volumes EBS : $($EC2Volumes.Count) : $([math]::Round(($EC2VolumesPricing),2))$"
    Write-Host "$(get-date) - EIPs : $($EC2AddressUnassociated.Count) : $([math]::Round(($EC2AddressUnassociatedPricing),2))$"
    Write-Host "$(get-date) - VPN : $($VPCVpnConnections.Count) : $([math]::Round(($VPCVpnConnectionsPricing),2))$"
    Write-Host "$(get-date) - Buckets S3 : $($S3Buckets.Count) : $([math]::Round(($S3BucketsPricing),2))$"
    Write-Host "$(get-date) - Instances RDS : $($RDSInstances.Count) : $([math]::Round(($RDSInstancesPricing),2))$"
    Write-Host "$(get-date) --- Total : $([math]::Round(($TotalCost),2))$"

    Write-Host "`n$(get-date) - Economies possibles"
    Write-Host "$(get-date) - Supprimer les $($EC2InstancesStopped.Count) instances EC2 arretees : $([math]::Round(($EC2InstancesStoppedPricing),2))$"
    Write-Host "$(get-date) - Redimensionner les $($EC2InstancesUnderused.Count) instances EC2 sous-utilisees : $([math]::Round(($EC2InstancesUnderusedPricing-$EC2InstancesUnderusedDowngradePricing),2))$"
    Write-Host "$(get-date) - Reconfigurer les $($EC2InstancesOutOfDate.Count) instances obsoletes : $([math]::Round(($EC2InstancesOutOfDatePricing),2))$"
    Write-Host "$(get-date) - Supprimer les $($EC2SnapshotsOutOfDateGroupsOldestSnapshotsOnly.Count) snapshots EC2 depasses : $([math]::Round(($EC2SnapshotsOutOfDateGroupsPricing),2))$"
    Write-Host "$(get-date) - Supprimer les $($EC2VolumesUnattached.Count) volumes non attaches : $([math]::Round(($EC2VolumesUnattachedPricing),2))$"
    Write-Host "$(get-date) - Supprimer les $($EC2VolumesAttachedToStoppedInstances.Count) volumes 'zombies' : $([math]::Round(($EC2VolumesAttachedToStoppedInstancesPricing),2))$"
    Write-Host "$(get-date) - Supprimer les $($EC2AddressUnassociated.Count) EIP non associees : $([math]::Round(($EC2AddressUnassociatedPricing),2))$"
    Write-Host "$(get-date) - Supprimer les $($VPCVpnConnectionsDown.Count) VPN down :  : $([math]::Round(($VPCVpnConnectionsDownPricing),2))$"
    Write-Host "$(get-date) - Supprimer les $($RDSInstancesStopped.Count) instances RDS arretees : $([math]::Round(($RDSInstancesStoppedPricing),2))$"
    Write-Host "$(get-date) - Redimensionner les $($RDSInstancesUnderused.Count) instances RDS sous-utilisees : $([math]::Round(($RDSInstancesUnderusedPricing),2))$"
    Write-Host "$(get-date) - Reconfigurer les $($RDSInstancesOutOfDate.Count) instances obsoletes : $([math]::Round(($RDSInstancesOutOfDatePricing),2))$"
    Write-Host "$(get-date) --- Total : $([math]::Round(($GlobalSavings),2))$" 

    Write-Host "`n$(get-date) - Economies possibles (%)"
    Write-Host "$(get-date) - Ressource`t`tCout Actuel`tEconomie (%)"
    Write-Host "$(get-date) - Instances EC2 `t$([math]::Round(($EC2InstancesPricing),2)) `t`t$( if($EC2InstancesPricing -ne 0) { "$( [math]::Round(((($EC2InstancesStoppedPricing+($EC2InstancesUnderusedPricing-$EC2InstancesUnderusedDowngradePricing)+$EC2InstancesOutOfDatePricing)/$EC2InstancesPricing)*100),2) )%" } else { "N/A" } )"
    Write-Host "$(get-date) - Snapshots EC2 `t$([math]::Round(($EC2SnapshotsGroupsPricing),2)) `t`t$( if($EC2SnapshotsGroupsPricing -ne 0) { "$( [math]::Round((($EC2SnapshotsOutOfDateGroupsPricing/$EC2SnapshotsGroupsPricing)*100),2) )%" } else { "N/A" } )"
    Write-Host "$(get-date) - Volumes EBS   `t$([math]::Round(($EC2VolumesPricing),2)) `t`t$( if($EC2VolumesPricing -ne 0) { "$( [math]::Round(((($($EC2VolumesUnattachedPricing+$EC2VolumesAttachedToStoppedInstancesPricing))/$EC2VolumesPricing)*100),2) )%" } else { "N/A" } )"
    Write-Host "$(get-date) - EIPs          `t$([math]::Round(($EC2AddressUnassociatedPricing),2)) `t`t$( if($EC2AddressUnassociatedPricing -ne 0) { "$( [math]::Round((($EC2AddressUnassociatedPricing/$EC2AddressUnassociatedPricing)*100),2) )%" } else { "N/A" } )"
    Write-Host "$(get-date) - VPN           `t$([math]::Round(($VPCVpnConnectionsPricing),2)) `t`t$( if($VPCVpnConnectionsPricing -ne 0) { "$([math]::Round((($VPCVpnConnectionsDownPricing/$VPCVpnConnectionsPricing)*100),2)) %" } else { "N/A" } )"
    Write-Host "$(get-date) - Buckets S3    `t$([math]::Round(($S3BucketsPricing),2))"
    Write-Host "$(get-date) - Instances RDS `t$([math]::Round(($RDSInstancesPricing),2)) `t`t$( if($RDSInstancesPricing -ne 0) { "$( [math]::Round(((($RDSInstancesStoppedPricing+$RDSInstancesUnderusedPricing+$RDSInstancesOutOfDatePricing)/$RDSInstancesPricing)*100),2) ) %" } else { "N/A" } )"
    Write-Host "$(get-date) --- Total       `t$([math]::Round(($TotalCost),2))$ `t$( [math]::Round((($GlobalSavings/$TotalCost)*100),2) )%"


    # $StartFile | Out-File -FilePath .\static\$CurrentTime.html -Encoding utf8
    # $slides | Out-File -FilePath .\static\$CurrentTime.html -Append utf8
    # $EndFile | Out-File -FilePath .\static\$CurrentTime.html -Append utf8
    $Header | Out-File -FilePath $HTMLOutputFile -Encoding utf8
    $Slides | Out-File -FilePath $HTMLOutputFile -Append -Encoding utf8
    $Footer | Out-File -FilePath $HTMLOutputFile -Append -Encoding utf8
}
Show-OziHTMLOutput @args