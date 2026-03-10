# Domain Controller Provisioning Script
# This script installs AD DS and configures the lab.local domain

# Enable error handling
$ErrorActionPreference = "Stop"

# Variables
$DomainName = "lab.local"
$NetBIOSName = "LAB"
$DomainMode = "Win2016"
$ForestMode = "Win2016"
$SafeModePassword = ConvertTo-SecureString "D0m@inAdmin!" -AsPlainText -Force

# Install AD DS and DNS features
Write-Host "Installing AD DS and DNS features..."
Install-WindowsFeature -Name AD-Domain-Services, DNS -IncludeManagementTools

# Promote to Domain Controller
Write-Host "Promoting to Domain Controller..."
Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetBIOSName $NetBIOSName `
    -DomainMode $DomainMode `
    -ForestMode $ForestMode `
    -SafeModeAdministratorPassword $SafeModePassword `
    -InstallDns:$true `
    -NoRebootOnCompletion:$true `
    -Force:$true

# Wait for AD services to stabilize
Start-Sleep -Seconds 30

# Import AD module
Import-Module ActiveDirectory

# Create Organizational Units
Write-Host "Creating Organizational Units..."
New-ADOrganizationalUnit -Name "Users" -Path "DC=lab,DC=local" -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name "Service Accounts" -Path "DC=lab,DC=local" -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name "Admins" -Path "DC=lab,DC=local" -ProtectedFromAccidentalDeletion $false

# Create regular users
Write-Host "Creating regular users..."
$UserPass = ConvertTo-SecureString "Password123!" -AsPlainText -Force
New-ADUser -Name "john.doe" -GivenName "John" -Surname "Doe" -SamAccountName "john.doe" -UserPrincipalName "john.doe@lab.local" -AccountPassword $UserPass -Enabled $true -Path "OU=Users,DC=lab,DC=local"
$UserPass2 = ConvertTo-SecureString "Summer2024!" -AsPlainText -Force
New-ADUser -Name "jane.smith" -GivenName "Jane" -Surname "Smith" -SamAccountName "jane.smith" -UserPrincipalName "jane.smith@lab.local" -AccountPassword $UserPass2 -Enabled $true -Path "OU=Users,DC=lab,DC=local"

# Create service accounts
Write-Host "Creating service accounts..."
$SvcPayrollPass = ConvertTo-SecureString "P@yrollSvc!" -AsPlainText -Force
New-ADUser -Name "svc_payroll" -SamAccountName "svc_payroll" -UserPrincipalName "svc_payroll@lab.local" -AccountPassword $SvcPayrollPass -Enabled $true -Path "OU=Service Accounts,DC=lab,DC=local"
Set-ADUser -Identity svc_payroll -ServicePrincipalNames @{Add="http/web01.lab.local"}

$SvcBackupPass = ConvertTo-SecureString "B@ckup123!" -AsPlainText -Force
New-ADUser -Name "svc_backup" -SamAccountName "svc_backup" -UserPrincipalName "svc_backup@lab.local" -AccountPassword $SvcBackupPass -Enabled $true -Path "OU=Service Accounts,DC=lab,DC=local"

# Create admin accounts
Write-Host "Creating admin accounts..."
$DomAdminPass = ConvertTo-SecureString "D0m@inAdmin!" -AsPlainText -Force
New-ADUser -Name "dom_admin" -SamAccountName "dom_admin" -UserPrincipalName "dom_admin@lab.local" -AccountPassword $DomAdminPass -Enabled $true -Path "OU=Admins,DC=lab,DC=local"
Add-ADGroupMember -Identity "Domain Admins" -Members "dom_admin"

$WebAdminPass = ConvertTo-SecureString "W3b@dmin!" -AsPlainText -Force
New-ADUser -Name "web_admin" -SamAccountName "web_admin" -UserPrincipalName "web_admin@lab.local" -AccountPassword $WebAdminPass -Enabled $true -Path "OU=Admins,DC=lab,DC=local"
Add-ADGroupMember -Identity "Administrators" -Members "web_admin"

# Add svc_backup to Backup Operators group (for DCSync simulation)
Write-Host "Adding svc_backup to Backup Operators..."
Add-ADGroupMember -Identity "Backup Operators" -Members "svc_backup"

# Configure Delegation for DCSync (optional, already via Backup Operators)
# Set-ADObject -Identity "CN=svc_backup,OU=Service Accounts,DC=lab,DC=local" -Replace @{msDS-ReplicationGetChangesAll = $true}

# Enable SeImpersonatePrivilege for svc_payroll (default for service accounts)
# Already present by default for service accounts

# Configure DNS forwarder (optional)
# Set-DnsServerForwarder -IPAddress 8.8.8.8

# Disable Windows Firewall for lab simplicity (or configure specific rules)
Write-Host "Disabling Windows Firewall..."
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Create proof file on desktop
Write-Host "Creating proof file..."
$ProofContent = "FLAG: DC01_COMPROMISED_{R3pl1c4t10n_1s_Fun}"
$ProofPath = "C:\Users\Administrator\Desktop\proof.txt"
$ProofContent | Out-File -FilePath $ProofPath -Encoding ascii

Write-Host "Domain controller provisioning completed successfully."
