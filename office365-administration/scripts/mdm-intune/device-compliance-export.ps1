<#
.SYNOPSIS
    Exports Microsoft Intune device compliance data.

.DESCRIPTION
    This script connects to Microsoft Graph and retrieves all device compliance
    information from Intune, including:
        - Device name
        - Compliance state
        - Operating system
        - OS version
        - Device ownership
        - Last check-in time
        - User principal name
        - Device ID and Azure AD ID

    The script exports the results to a timestamped CSV file for audit,
    reporting, or compliance review.

.EXAMPLE
    ./device-compliance-export.ps1

#>

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "DeviceManagementConfiguration.Read.All","Device.Read.All","Directory.Read.All" | Out-Null

Write-Host "Retrieving Intune managed devices..." -ForegroundColor Yellow
$devices = Get-MgDeviceManagementManagedDevice -All

if (-not $devices) {
    Write-Host "No device data returned. Check permissions or tenant configuration." -ForegroundColor Red
    exit 1
}

Write-Host "Processing device compliance data..." -ForegroundColor Cyan

$report = foreach ($d in $devices) {
    [PSCustomObject]@{
        DeviceName        = $d.DeviceName
        UserPrincipalName = $d.UserPrincipalName
        ComplianceState   = $d.ComplianceState
        OperatingSystem   = $d.OperatingSystem
        OsVersion         = $d.OsVersion
        DeviceType        = $d.DeviceType
        DeviceOwnership   = $d.DeviceOwnership
        LastCheckIn       = $d.LastSyncDateTime
        AzureAdDeviceId   = $d.AzureAdDeviceId
        ManagedDeviceId   = $d.Id
    }
}

$timestamp = (Get-Date).ToString("yyyyMMdd-HHmmss")
$reportPath = "intune-device-compliance-$timestamp.csv"

Write-Host "Exporting device compliance report to $reportPath" -ForegroundColor Green
$report | Export-Csv -Path $reportPath -NoTypeInformation -Encoding UTF8

Write-Host "Device compliance export completed successfully." -ForegroundColor Cyan
