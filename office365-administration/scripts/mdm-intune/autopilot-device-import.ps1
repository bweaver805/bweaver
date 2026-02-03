<#
.SYNOPSIS
    Imports Windows Autopilot devices into Intune from a CSV file.

.DESCRIPTION
    This script imports device hardware hashes into Windows Autopilot using
    Microsoft Graph. It validates the CSV, uploads each device, applies
    optional group tags, and logs results for audit purposes.

    Expected CSV headers:
        - DeviceSerialNumber
        - WindowsProductID
        - HardwareHash
        - GroupTag (optional)

.PARAMETER CsvPath
    Path to the Autopilot CSV file.

.EXAMPLE
    ./autopilot-import.ps1 -CsvPath ".\autopilot-devices.csv"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$CsvPath
)

if (-not (Test-Path $CsvPath)) {
    Write-Host "CSV file not found: $CsvPath" -ForegroundColor Red
    exit 1
}

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "DeviceManagementServiceConfig.ReadWrite.All" | Out-Null

Write-Host "Importing CSV: $CsvPath" -ForegroundColor Yellow
$devices = Import-Csv -Path $CsvPath

if ($devices.Count -eq 0) {
    Write-Host "CSV contains no device entries." -ForegroundColor Red
    exit 1
}

$timestamp = (Get-Date).ToString("yyyyMMdd-HHmmss")
$logPath = "autopilot-import-log-$timestamp.csv"
$log = @()

foreach ($d in $devices) {

    if (-not $d.HardwareHash) {
        Write-Host "Skipping entry with missing HardwareHash." -ForegroundColor DarkYellow
        continue
    }

    $body = @{
        "serialNumber"   = $d.DeviceSerialNumber
        "hardwareIdentifier" = $d.HardwareHash
        "groupTag"       = $d.GroupTag
        "productKey"     = $d.WindowsProductID
    }

    Write-Host "Importing device: $($d.DeviceSerialNumber)" -ForegroundColor Cyan

    try {
        $result = New-MgDeviceManagementWindowsAutopilotDeviceIdentity -BodyParameter $body

        $log += [PSCustomObject]@{
            SerialNumber = $d.DeviceSerialNumber
            Status       = "Success"
            AutopilotId  = $result.Id
        }

        Write-Host " → Success" -ForegroundColor Green
    }
    catch {
        $log += [PSCustomObject]@{
            SerialNumber = $d.DeviceSerialNumber
            Status       = "Failed"
            Error        = $_.Exception.Message
        }

        Write-Host " → Failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "Exporting import log to $logPath" -ForegroundColor Yellow
$log | Export-Csv -Path $logPath -NoTypeInformation -Encoding UTF8

Write-Host "Autopilot import completed." -ForegroundColor Green
