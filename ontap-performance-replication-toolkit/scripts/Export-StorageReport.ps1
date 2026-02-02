<#
.SYNOPSIS
    Generates a combined ONTAP storage report.

.DESCRIPTION
    Calls performance and SnapMirror health functions, merges the data,
    and exports to CSV or JSON for reporting or dashboards.

.PARAMETER Cluster
    ONTAP cluster management LIF.

.PARAMETER Credential
    PSCredential object for ONTAP authentication.

.PARAMETER OutputPath
    Path to save the report.

.EXAMPLE
    .\Export-StorageReport.ps1 -Cluster ontap-prod -OutputPath report.csv
#>

param(
    [Parameter(Mandatory)]
    [string]$Cluster,

    [Parameter(Mandatory)]
    [pscredential]$Credential,

    [Parameter(Mandatory)]
    [string]$OutputPath
)

Write-Host "Collecting performance metrics..."
$perf = & "$PSScriptRoot\Get-OntapPerformance.ps1" -Cluster $Cluster -Credential $Credential

Write-Host "Collecting SnapMirror health..."
$mirror = & "$PSScriptRoot\Test-SnapMirrorHealth.ps1" -Cluster $Cluster -Credential $Credential

$report = [PSCustomObject]@{
    Timestamp     = $perf.Timestamp
    IOPS          = $perf.IOPS
    LatencyMS     = $perf.LatencyMS
    Throughput    = $perf.Throughput
    SnapMirror    = $mirror
}

if ($OutputPath.EndsWith(".json")) {
    $report | ConvertTo-Json -Depth 5 | Out-File $OutputPath
}
else {
    $report | Export-Csv -Path $OutputPath -NoTypeInformation
}

Write-Host "Report saved to $OutputPath"
