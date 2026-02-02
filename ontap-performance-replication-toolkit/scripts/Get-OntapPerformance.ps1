<#
.SYNOPSIS
    Retrieves ONTAP performance metrics for a cluster or SVM.

.DESCRIPTION
    Uses the ONTAP REST API to pull key performance indicators such as
    latency, IOPS, and throughput. Designed to be modular and reusable
    in larger automation frameworks.

.PARAMETER Cluster
    The ONTAP cluster management LIF.

.PARAMETER Credential
    PSCredential object for ONTAP authentication.

.EXAMPLE
    .\Get-OntapPerformance.ps1 -Cluster "ontap-prod" -Credential (Get-Credential)
#>

param(
    [Parameter(Mandatory)]
    [string]$Cluster,

    [Parameter(Mandatory)]
    [pscredential]$Credential
)

$BaseUri = "https://$Cluster/api/cluster/metrics"

try {
    $response = Invoke-RestMethod -Uri $BaseUri `
        -Credential $Credential `
        -Method GET `
        -SkipCertificateCheck `
        -ErrorAction Stop

    $metrics = [PSCustomObject]@{
        Timestamp   = (Get-Date)
        IOPS        = $response.iops
        LatencyMS   = $response.latency
        Throughput  = $response.throughput
    }

    $metrics | Format-List
    return $metrics
}
catch {
    Write-Error "Failed to retrieve ONTAP performance metrics: $_"
}
