# WEB01 Join Domain Script
# Joins the lab.local domain and reboots

$ErrorActionPreference = "Stop"

# Variables
$DomainName = "lab.local"
$DomainAdmin = "dom_admin"
$DomainAdminPassword = "D0m@inAdmin!"
$DCIp = "10.0.2.10"

# Disable Windows Firewall for lab simplicity
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Set DNS server to DC
Write-Host "Setting DNS server to $DCIp..."
Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | ForEach-Object {
    Set-DnsClientServerAddress -InterfaceIndex $_.ifIndex -ServerAddresses $DCIp
}

# Join domain
Write-Host "Joining domain $DomainName..."
$SecurePassword = ConvertTo-SecureString $DomainAdminPassword -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential("$DomainName\$DomainAdmin", $SecurePassword)
Add-Computer -DomainName $DomainName -Credential $Credential -Restart:$false -Force

Write-Host "Domain join completed. Rebooting..."
