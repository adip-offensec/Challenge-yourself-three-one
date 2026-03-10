# Simple lab validation script
# Run from host (Windows) or from attacker VM

Write-Host "Testing lab connectivity..."

$WEB01 = "10.0.1.10"
$DC01 = "10.0.2.10"

# Test ping to WEB01
if (Test-Connection -ComputerName $WEB01 -Count 1 -Quiet) {
    Write-Host "[+] WEB01 reachable" -ForegroundColor Green
} else {
    Write-Host "[-] WEB01 unreachable" -ForegroundColor Red
}

# Test ping to DC01 (may be blocked by firewall)
if (Test-Connection -ComputerName $DC01 -Count 1 -Quiet) {
    Write-Host "[+] DC01 reachable" -ForegroundColor Green
} else {
    Write-Host "[-] DC01 unreachable (may be expected)" -ForegroundColor Yellow
}

# Test web app
try {
    $response = Invoke-WebRequest -Uri "http://$WEB01/" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "[+] Web app accessible" -ForegroundColor Green
    }
} catch {
    Write-Host "[-] Web app not accessible" -ForegroundColor Red
}

Write-Host "Validation complete."
