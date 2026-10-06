<#
.SYNOPSIS
    Configures split tunneling for Local IP ranges and specific DNS domains.

.DESCRIPTION
    This script finds the primary network adapter (non-VPN) and routes 
    private IP ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) through it.
    It also configures Windows NRPT to route specific DNS queries (Example.com)
    to designated internal DNS servers.
#>

# Require Administrator privileges to modify routing and DNS tables
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Restarting script with Administrator privileges..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Do not show error messages for optional cleanup commands
$ErrorActionPreference = 'SilentlyContinue'

Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  LAN Traffic & DNS Router - Bypassing VPN for Local IPs" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

# Find the main default route that is NOT the VPN (NextHop is not 0.0.0.0)
$mainRoute = Get-NetRoute -DestinationPrefix '0.0.0.0/0' -AddressFamily IPv4 | 
    Where-Object { $_.NextHop -ne '0.0.0.0' } | 
    Sort-Object RouteMetric | 
    Select-Object -First 1

if ($mainRoute) {
    $gateway = $mainRoute.NextHop
    $ifIndex = $mainRoute.ifIndex
    $adapter = Get-NetAdapter -InterfaceIndex $ifIndex

    Write-Host "[+] Main Network Adapter Detected: $($adapter.Name)" -ForegroundColor Green
    Write-Host "[+] Default Gateway Detected: $gateway" -ForegroundColor Green
    Write-Host ""

    # -------------------------------------------------------------
    # 1. IP ROUTING FOR PRIVATE NETWORKS
    # -------------------------------------------------------------
    Write-Host "[*] Configuring IP Routes for private networks (10.x, 172.16.x, 192.168.x)..." -ForegroundColor Yellow
    
    # Remove existing routes to prevent conflicts
    route delete 10.0.0.0
    route delete 172.16.0.0
    route delete 192.168.0.0
    
    # Add persistent routes pointing to the physical gateway
    route add -p 10.0.0.0 mask 255.0.0.0 $gateway if $ifIndex
    route add -p 172.16.0.0 mask 255.240.0.0 $gateway if $ifIndex
    route add -p 192.168.0.0 mask 255.255.0.0 $gateway if $ifIndex
    
    Write-Host "[+] IP Routes configured successfully." -ForegroundColor Green
    Write-Host ""

    # -------------------------------------------------------------
    # 2. DNS ROUTING FOR SPECIFIC DOMAINS (NRPT)
    # -------------------------------------------------------------
    Write-Host "[*] Configuring DNS Routing for 'Example.com'..." -ForegroundColor Yellow
    
    # Remove any previously set rules for this domain
    Get-DnsClientNrptRule | Where-Object { $_.Namespace -match 'Example\.com' } | Remove-DnsClientNrptRule -Force
    
    # Add the new rule targeting internal DNS servers
    Add-DnsClientNrptRule -Namespace "Example.com" -NameServers "10.10.10.100", "10.10.10.101"
    
    if ($?) { 
        Write-Host "[+] DNS rules applied successfully." -ForegroundColor Green 
    } else { 
        Write-Host "[-] Failed to apply DNS rules." -ForegroundColor Red 
    }

} else {
    Write-Host "[-] Error: Could not detect the main default gateway." -ForegroundColor Red
}

# -------------------------------------------------------------
# 3. END OF SCRIPT
# -------------------------------------------------------------
Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "Configuration completed! Local IPs and Example.com will bypass VPN." -ForegroundColor Cyan
Write-Host "Press any key to exit..." -ForegroundColor White

$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
