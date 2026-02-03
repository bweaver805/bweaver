<#
.SYNOPSIS
    Generates an Office 365 license usage report.

.DESCRIPTION
    This script connects to Microsoft Graph and produces a detailed report of:
        - All available SKUs
        - Total licenses purchased
        - Licenses consumed
        - Licenses remaining
        - Percentage utilization
        - Users assigned to each SKU (optional export)

.PARAMETER ExportUserAssignments
    If specified, exports a secondary CSV listing each user and their assigned licenses.

.EXAMPLE
    ./license-usage-report.ps1

.EXAMPLE
    ./license-usage-report.ps1 -ExportUserAssignments
#>

param(
    [switch]$ExportUserAssignments
)

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "Directory.Read.All","User.Read.All" | Out-Null

Write-Host "Retrieving license (SKU) information..." -ForegroundColor Yellow
$skus = Get-MgSubscribedSku

if (-not $skus) {
    Write-Host "No SKU data returned. Check permissions or tenant configuration." -ForegroundColor Red
    exit 1
}

$report = foreach ($sku in $skus) {
    $skuId = $sku.SkuId
    $skuPart = $sku.SkuPartNumber
    $total = $sku.PrepaidUnits.Enabled
    $consumed = $sku.ConsumedUnits
    $remaining = $total - $consumed
    $percent = if ($total -ne 0) { [math]::Round(($consumed / $total) * 100, 2) } else { 0 }

    [PSCustomObject]@{
        SkuPartNumber      = $skuPart
        SkuId              = $skuId
        TotalLicenses      = $total
        ConsumedLicenses   = $consumed
        RemainingLicenses  = $remaining
        UtilizationPercent = "$percent%"
    }
}

$timestamp = (Get-Date).ToString("yyyyMMdd-HHmmss")
$reportPath = "license-usage-report-$timestamp.csv"

Write-Host "Exporting license usage report to $reportPath" -ForegroundColor Green
$report | Export-Csv -Path $reportPath -NoTypeInformation -Encoding UTF8

# Optional: export user-to-license mapping
if ($ExportUserAssignments) {
    Write-Host "Retrieving user license assignments..." -ForegroundColor Yellow
    $users = Get-MgUser -All -Property "Id,DisplayName,UserPrincipalName,AssignedLicenses"

    $userReport = foreach ($u in $users) {
        foreach ($lic in $u.AssignedLicenses) {
            [PSCustomObject]@{
                DisplayName       = $u.DisplayName
                UserPrincipalName = $u.UserPrincipalName
                SkuId             = $lic.SkuId
            }
        }
    }

    $userReportPath = "license-user-assignments-$timestamp.csv"
    Write-Host "Exporting user assignment report to $userReportPath" -ForegroundColor Green
    $userReport | Export-Csv -Path $userReportPath -NoTypeInformation -Encoding UTF8
}

Write-Host "License usage reporting completed successfully." -ForegroundColor Cyan
