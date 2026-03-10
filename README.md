# Active Directory Attack Lab

This lab simulates a realistic Windows Active Directory environment with intentional vulnerabilities to practice offensive security techniques.

## Lab Architecture

- **Domain**: `lab.local`
- **Network Segments**:
  - **DMZ** (10.0.1.0/24): WEB01 (10.0.1.10) - IIS web server hosting vulnerable Attendance & Payroll System.
  - **Internal** (10.0.2.0/24): DC01 (10.0.2.10) - Domain Controller.
- **Firewall Rules**: Outbound HTTP/HTTPS and DNS allowed from DMZ to Internal; direct RDP/SMB blocked.

## Credentials

| Account | Password | Purpose |
|---------|----------|---------|
| john.doe | Password123! | Regular user |
| jane.smith | Summer2024! | Regular user |
| svc_payroll | P@yrollSvc! | Service account (SPN: http/web01.lab.local) |
| svc_backup | B@ckup123! | Service account with Backup Operators rights |
| dom_admin | D0m@inAdmin! | Domain Admin |
| web_admin | W3b@dmin! | Local admin on WEB01 |

## Setup Instructions

### Prerequisites
- **Vagrant** (2.2.6 or later) - [Download](https://www.vagrantup.com/downloads)
- **VirtualBox** (6.1 or later) - [Download](https://www.virtualbox.org/wiki/Downloads)
- **VirtualBox Extension Pack** (recommended for better performance)
- At least **8 GB RAM** (16 GB recommended)
- At least **50 GB free disk space**
- **Windows Server 2022 Evaluation** box (~10 GB download)
- Stable internet connection for initial download

### Automated Setup (Recommended)
1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/Challenge-yourself-three-one.git
   cd Challenge-yourself-three-one
   ```
2. Run the setup script:
   ```bash
   ./setup.sh
   ```
   The script will check prerequisites and start the deployment.

### Manual Deployment
1. Clone this repository (or extract the lab package).
2. Open a terminal in the lab root directory.
3. Run `vagrant up` to provision both VMs (DC01 and WEB01).
4. Wait for provisioning to complete (may take 30-60 minutes).
5. Verify connectivity:
   - DC01: `ping 10.0.2.10`
   - WEB01: `ping 10.0.1.10`

### Access
- **WEB01**: http://10.0.1.10/ (vulnerable Attendance & Payroll System)
- **DC01**: 10.0.2.10 (Domain Controller, not directly accessible from host)
- Use **WinRM** or **RDP** via pivot through WEB01 for internal access.

### Important Notes
- The first `vagrant up` will download the Windows Server 2022 box (~10 GB). Ensure you have sufficient bandwidth and disk space.
- If provisioning fails, run `vagrant destroy -f && vagrant up` to start fresh.
- Firewall is disabled on both VMs for lab simplicity.

### Testing the Deployment
After deployment, you can verify the lab is working:

1. **Web Application**: Open http://10.0.1.10/ in your browser. You should see the "Attendance & Payroll System" page with a file upload form.
2. **Pre‑uploaded Web Shell**: Access http://10.0.1.10/uploads/cmd.aspx to test command execution (e.g., `whoami`).
3. **Connectivity**: From your host, ping both VMs to ensure they are reachable:
   ```bash
   ping -c 2 10.0.1.10
   ping -c 2 10.0.2.10
   ```

## Lab Objectives

Your goal is to compromise the entire domain and retrieve the proof files from both WEB01 and DC01.

### Suggested Attack Path
1. **Initial Access**: Exploit the file upload vulnerability in the Attendance & Payroll System to gain remote code execution.
2. **Privilege Escalation**: Escalate privileges on WEB01 using JuicyPotato/PrintSpoofer (service account has SeImpersonatePrivilege).
3. **Credential Dumping**: Dump hashes/plaintext passwords from memory to obtain credentials for `web_admin` and `svc_payroll`.
4. **Lateral Movement**: Use obtained credentials to enumerate Active Directory (PowerView, BloodHound).
5. **Kerberos Attacks**: Perform Kerberoasting against `svc_payroll` SPN and crack the hash.
6. **Domain Compromise**: Use `svc_backup` (Backup Operators) to perform DCSync and retrieve Domain Admin hash.
7. **Proof Collection**: Retrieve `proof.txt` from both WEB01 and DC01 desktops.

## Hints

- The web app allows unrestricted file upload; try uploading a web shell.
- Check the `uploads` directory for pre‑placed web shell (`cmd.aspx`).
- Service accounts often have `SeImpersonatePrivilege` enabled.
- Use tools like Mimikatz, Rubeus, Impacket, and BloodHound.
- Firewall blocks direct SMB/RDP from DMZ to Internal; tunnel through WEB01.

## Proof Flags

- WEB01: `FLAG: WEB01_COMPROMISED_{Upl04d_1s_Fun}`
- DC01: `FLAG: DC01_COMPROMISED_{R3pl1c4t10n_1s_Fun}`

## Troubleshooting

- If Vagrant fails to download the Windows box, ensure you have a stable internet connection.
- If VMs fail to start due to insufficient memory, adjust memory settings in `Vagrantfile`.
- To re‑provision, run `vagrant destroy -f && vagrant up`.

## License

This lab is for educational purposes only. Use only in isolated environments.

