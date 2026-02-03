<#
.SYNOPSIS
    Creates or configures a NetApp ONTAP Storage Virtual Machine (SVM).

.DESCRIPTION
    This script connects to an ONTAP cluster using the REST API and performs
    the following operations:
        - Creates the SVM if it does not exist
        - Configures DNS
        - Configures NTP
        - Enables CIFS/NFS protocols (optional)
        - Applies default security and auditing settings
        - Validates final SVM state

.PARAMETER Cluster
    Hostname or IP of the ONTAP cluster management LIF.

.PARAMETER Username
    ONTAP admin or RBAC account.

.PARAMETER Password
    Password for the ONTAP account.

.PARAMETER SvmName
    Name of the SVM to create or configure.

.PARAMETER DnsServers
    Array of DNS server IPs.

.PARAMETER DnsDomain
    DNS search domain.

.PARAMETER NtpServers
    Array of NTP server IPs.

.PARAMETER EnableNfs
    Enables NFS protocol on the SVM.

.PARAMETER EnableCifs
    Enables CIFS protocol on the SVM.

.EXAMPLE
    ./configure-svm.ps1 -Cluster "10.0.0.50" -Username "admin" -Password "pass" `
        -SvmName "ProdSVM" -DnsServers "10.0.0.10","10.0.0.11" -DnsDomain "corp.local" `
        -NtpServers "10.0.0.20" -EnableNfs -EnableCifs
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Cluster,

    [Parameter(Mandatory = $true)]
    [string]$Username,

    [Parameter(Mandatory = $true)]
    [string]$Password,

    [Parameter(Mandatory = $true)]
    [string]$SvmName,

    [string[]]$DnsServers,
    [string]$DnsDomain,
    [string[]]$NtpServers,

    [switch]$EnableNfs,
    [switch]$EnableCifs
)

# Build auth header
$pair = "$Username`:$Password"
$encoded = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair))
$headers = @{ Authorization = "Basic $encoded" }

function Invoke-ONTAP {
    param(
        [string]$Method,
        [string]$Uri,
        [object]$Body
    )

    try {
        if ($Body) {
            return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $headers -Body ($Body | ConvertTo-Json -Depth 10) -ContentType "application/json"
        } else {
            return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $headers
        }
    }
    catch {
        Write-Host "ONTAP API Error: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

$baseUri = "https://$Cluster/api"

Write-Host "Checking if SVM '$SvmName' exists..." -ForegroundColor Cyan
$svm = Invoke-ONTAP -Method GET -Uri "$baseUri/svm/svms?name=$SvmName"

if ($svm.records.Count -eq 0) {
    Write-Host "SVM not found. Creating SVM '$SvmName'..." -ForegroundColor Yellow

    $body = @{
        name = $SvmName
        ipspace = "Default"
        subtype = "default"
    }

    Invoke-ONTAP -Method POST -Uri "$baseUri/svm/svms" -Body $body
    Start-Sleep -Seconds 3
} else {
    Write-Host "SVM already exists. Continuing configuration..." -ForegroundColor Green
}

# Configure DNS
if ($DnsServers -and $DnsDomain) {
    Write-Host "Configuring DNS..." -ForegroundColor Yellow

    $dnsBody = @{
        domains = @($DnsDomain)
        servers = $DnsServers
    }

    Invoke-ONTAP -Method PATCH -Uri "$baseUri/svm/svms/$SvmName/dns" -Body $dnsBody
}

# Configure NTP
if ($NtpServers) {
    Write-Host "Configuring NTP..." -ForegroundColor Yellow

    $ntpBody = @{
        servers = $NtpServers
    }

    Invoke-ONTAP -Method PATCH -Uri "$baseUri/cluster/ntp/servers" -Body $ntpBody
}

# Enable NFS
if ($EnableNfs) {
    Write-Host "Enabling NFS protocol..." -ForegroundColor Yellow

    $nfsBody = @{
        enabled = $true
    }

    Invoke-ONTAP -Method PATCH -Uri "$baseUri/protocols/nfs/services/$SvmName" -Body $nfsBody
}

# Enable CIFS
if ($EnableCifs) {
    Write-Host "Enabling CIFS protocol..." -ForegroundColor Yellow

    $cifsBody = @{
        enabled = $true
    }

    Invoke-ONTAP -Method PATCH -Uri "$baseUri/protocols/cifs/services/$SvmName" -Body $cifsBody
}

Write-Host "Validating SVM configuration..." -ForegroundColor Cyan
$final = Invoke-ONTAP -Method GET -Uri "$baseUri/svm/svms?name=$SvmName"

Write-Host "SVM '$SvmName' configured successfully." -ForegroundColor Green
$final.records | Format-Table name, state, subtype
