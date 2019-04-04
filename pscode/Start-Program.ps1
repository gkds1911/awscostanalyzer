############################
#### MAIN CONFIGURATION ####
############################

# CREDENTIALS
$AWSCredentialsProfile = 'laptop15-019'
$AWSRegions = 'eu-west-3'

# $AWSCredentialsProfile = 'default'
# $AWSRegions = 'eu-central-1'
$CSVExport = 0

# REGIONS
#$AWSRegions = (Get-AWSRegion).Region
#$AWSRegions = 'eu-central-1','us-east-1','ap-northeast-1','eu-west-1'

# OUTPUT
$HTMLOutputFile = "..\index.html"

##############
# MAIN PROGRAM
##############
# READ http://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/monitoring-costs.html
function Start-Program
{
    param(
        $AWSCredentialsProfile,
        $AWSRegions,
        $CSVExport
    )
    $CurrentTime = $(Get-Date -Format yyyyMMdd-hhmmss)   
    New-Item -Type Directory -Name $CurrentTime -ErrorAction SilentlyContinue | Out-Null
    Start-Transcript -Path $CurrentTime/Transcript.txt

    Write-Output "$(Get-Date) - Script lance a $CurrentTime"
    $OwnerId = (Get-STSCallerIdentity -ProfileName "$AWSCredentialsProfile").Account
    #$OwnerId = & ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziOwnerId.ps1") $AWSRegions $AWSCredentialsProfile
    Write-Output "$(Get-Date) - Compte: $AWSCredentialsProfile" 
    Write-Output "$(Get-Date) - Region: $AWSRegions" 
    Write-Output "$(Get-Date) - OwnerId: $OwnerId`n"
    
    $AllVolumeObjects = @()
    $AllInstanceObjects = @()
    $AllReservedInstanceObjects = @()
    $AllSnapshotObjects = @()    
    $AllEC2AddressObjects = @()
    $AllRDSDBInstanceObjects = @()
    $AllRDSDBReservedInstanceObjects = @()
    $AllVPNConnectionsObjects = @()
    $AllS3BucketObjects = @()
    
    foreach($Region in $AWSRegions) {
        Write-Output "$(Get-Date) - Rapatriement des infos de la region: $Region"
        Write-Output "$(Get-Date) - Recuperation des instances"
        $AllInstanceObjects += & ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziEC2Instances.ps1") $Region $AWSCredentialsProfile 
        Write-Output "$(Get-Date) - Recuperation des volumes"
        $AllVolumeObjects += & ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziEC2Volumes.ps1") $Region $AWSCredentialsProfile        
        Write-Output "$(Get-Date) - Recuperation des reserved instances"
        $AllReservedInstanceObjects += & ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziEC2ReservedInstances.ps1") $Region $AWSCredentialsProfile 
        Write-Output "$(Get-Date) - Recuperation des snapshots"
        $AllSnapshotObjects += & ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziEC2Snapshots.ps1") $Region $OwnerId $AWSCredentialsProfile 
        Write-Output "$(Get-Date) - Recuperation des adresses ec2"
        $AllEC2AddressObjects += & ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziEC2Addresses.ps1") $Region $AWSCredentialsProfile 
        Write-Output "$(Get-Date) - Recuperation des instances rds"
        $AllRDSDBInstanceObjects += & ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziRDSDBInstances.ps1") $Region $AWSCredentialsProfile
        Write-Output "$(Get-Date) - Recuperation des reserved instances rds"
        $AllRDSDBReservedInstanceObjects += & ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziRDSDBReservedInstances.ps1") $Region $AWSCredentialsProfile
        Write-Output "$(Get-Date) - Recuperation des connexions vpn"
        $AllVPNConnectionsObjects += & ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziVPCVpnConnections.ps1") $Region $AWSCredentialsProfile
        Write-Output "$(Get-Date) - Recuperation des buckets s3"
        $AllS3BucketObjects += & ((Split-Path $MyInvocation.InvocationName) + ".\Get-OziS3Buckets.ps1") $Region $AWSCredentialsProfile
    }
    Write-Output "$(Get-Date) - Generation du fichier de sortie HTML"
    & ((Split-Path $MyInvocation.InvocationName) + ".\Show-OziHTMLOutput.ps1") $AWSCredentialsProfile $HTMLOutputFile $AllInstanceObjects $AllSnapshotObjects $AllVolumeObjects $AllReservedInstanceObjects $AllEC2AddressObjects $AllRDSDBInstanceObjects $AllRDSDBReservedInstanceObjects $AllVPNConnections $AllS3BucketObjects

    if($CSVExport -eq 1)
    {
        $AllInstanceObjects | % { $_ | Export-CSV -Path $CurrentTime/InstanceObjects.csv -Append -NoTypeInformation -Delimiter ";" } 
        $AllReservedInstanceObjects | % { $_ | Export-CSV -Path $CurrentTime/ReservedInstanceObjects.csv -Append -NoTypeInformation -Delimiter ";" }
        $AllSnapshotObjects | % { $_ | Export-CSV -Path $CurrentTime/SnapshotObjects.csv -Append -NoTypeInformation -Delimiter ";" }
        $AllVolumeObjects | % { $_ | Export-CSV -Path $CurrentTime/VolumeObjects.csv -Append -NoTypeInformation -Delimiter ";" }
        $AllEC2AddressObjects | % { $_ | Export-CSV -Path $CurrentTime/EC2AddressObjects.csv -Append -NoTypeInformation -Delimiter ";" }
        $AllRDSDBInstanceObjects | % { $_ | Export-CSV -Path $CurrentTime/RDSDBInstanceObjects.csv -Append -NoTypeInformation -Delimiter ";" }
        $AllRDSDBReservedInstanceObjects | % { $_ | Export-CSV -Path $CurrentTime/RDSDBReservedInstanceObjects.csv -Append -NoTypeInformation -Delimiter ";" }
        $AllVPNConnectionsObjects | % { $_ | Export-CSV -Path $CurrentTime/VPNConnectionsObjects.csv -Append -NoTypeInformation -Delimiter ";" }
        $AllS3BucketObjects | % { $_ | Export-CSV -Path $CurrentTime/S3BucketObjects.csv -Append -NoTypeInformation -Delimiter ";" }
    }
    Stop-Transcript
   
}

Start-Program $AWSCredentialsProfile $AWSRegions $CSVExport
