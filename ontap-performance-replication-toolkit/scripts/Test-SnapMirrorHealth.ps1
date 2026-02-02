<#
.SYNOPSIS
    Validates SnapMirror replication health.

.DESCRIPTION
    Queries ONTAP SnapMirror relationships and returns lag, status,
    last transfer time, and any warnings.

.PARAMETER Cluster
    The ONTAP cluster management LIF.

.PARAMETER Credential
    PSCredential object for ONTAP authentication.

.EXAMPLE
    .\Test-SnapMirrorHealth.ps1 -Cluster "ontap-prod" -Credential (Get-Credential)
#>

param(
    [Parameter(Mandatory)]
    [string]$Cluster,

    [Parameter(Mandatory)]
    [pscredential]$Credential
)

$Uri = "https://$Cluster/api/snapmirror/relationships"

try {
    $response = Invoke-RestMethod -Uri $Uri `
        -Credential $Credential `
        -Method GET `
        -SkipCertificateCheck `
        -ErrorAction Stop

    $results = foreach ($item in $response.records) {
        [PSCustomObject]@{
            SourcePath     = $item.source.path
            Destination    = $item.destination.path
            Status         = $item.status
            LagTime        = $item.lag_time
            LastTransfer   = $item.last_transfer_end_timestamp
        }
    }

    $results | Format-Table -AutoSize
    return $results
}
catch {
    Write-Error "Failed to retrieve SnapMirror health: $_"
}
