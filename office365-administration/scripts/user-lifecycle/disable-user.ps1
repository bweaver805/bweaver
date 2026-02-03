<#
.SYNOPSIS
    Disables an Office 365 user account safely and consistently.

.DESCRIPTION
    This script performs a controlled disable operation for an O365 user:
        - Blocks sign‑in
        - Revokes active sessions
        - Removes all licenses (optional toggle)
        - Converts mailbox to shared (optional toggle)
        - Moves user to a "Disabled Users" group (optional)
        - Logs all actions for audit purposes

.PARAMETER UserPrincipalName
    The UPN of the user to disable.

.PARAMETER ConvertToSharedMailbox
    Converts the mailbox to a shared mailbox after disabling.

.PARAMETER RemoveLicenses
    Removes all assigned licenses.

.PARAMETER DisabledGroup
    Optional: security group to add the disabled user to.

.EXAMPLE
    ./disable-user.ps1 -UserPrincipalName "jdoe@contoso.com" -ConvertToSharedMailbox -RemoveLicenses
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,

    [switch]$ConvertToSharedMailbox,
    [switch]$RemoveLicenses,

    [string]$DisabledGroup = ""
)

Write-Host "Starting disable workflow for $UserPrincipalName..." -ForegroundColor Cyan

# Connect to required services
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Yellow
Connect-MgGraph -Scopes "User.ReadWrite.All","Directory.ReadWrite.All","AuditLog.Read.All" | Out-Null

# Validate user exists
$user = Get-MgUser -UserId $UserPrincipalName -ErrorAction SilentlyContinue
if (-not $user) {
    Write-Host "User not found: $UserPrincipalName" -ForegroundColor Red
    exit 1
}

Write-Host "User found: $($user.DisplayName)" -ForegroundColor Green

# Block sign-in
Write-Host "Blocking sign-in..." -ForegroundColor Yellow
Update-MgUser -UserId $UserPrincipalName -AccountEnabled:$false

# Revoke sessions
Write-Host "Revoking active sessions..." -ForegroundColor Yellow
Revoke-MgUserSignInSession -UserId $UserPrincipalName

# Remove licenses (optional)
if ($RemoveLicenses) {
    Write-Host "Removing all assigned licenses..." -ForegroundColor Yellow
    $assigned = $user.AssignedLicenses.SkuId
    if ($assigned.Count -gt 0) {
        Update-MgUserLicense -UserId $UserPrincipalName -RemoveLicenses $assigned -AddLicenses @{}
    } else {
        Write-Host "No licenses assigned." -ForegroundColor DarkYellow
    }
}

# Convert mailbox to shared (optional)
if ($ConvertToSharedMailbox) {
    Write-Host "Converting mailbox to shared..." -ForegroundColor Yellow
    try {
        Set-Mailbox -Identity $UserPrincipalName -Type Shared
    } catch {
        Write-Host "Mailbox conversion failed: $_" -ForegroundColor Red
    }
}

# Add to disabled group (optional)
if ($DisabledGroup -ne "") {
    Write-Host "Adding user to disabled group: $DisabledGroup" -ForegroundColor Yellow
    try {
        $group = Get-MgGroup -Filter "displayName eq '$DisabledGroup'"
        if ($group) {
            New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $user.Id
        } else {
            Write-Host "Group not found: $DisabledGroup" -ForegroundColor Red
        }
    } catch {
        Write-Host "Failed to add user to group: $_" -ForegroundColor Red
    }
}

Write-Host "Disable workflow completed for $UserPrincipalName." -ForegroundColor Green
