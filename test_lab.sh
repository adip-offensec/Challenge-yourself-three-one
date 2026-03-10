#!/bin/bash
# Test script for AD Attack Lab
# Run after deployment to verify basic functionality

set -e

echo "========================================="
echo "  AD Attack Lab - Basic Connectivity Test"
echo "========================================="

# Test WEB01 web app
echo ""
echo "1. Testing WEB01 web application (http://10.0.1.10/)..."
if curl -s -f --connect-timeout 10 http://10.0.1.10/ > /dev/null; then
    echo "   ✓ WEB01 web app is accessible"
else
    echo "   ✗ WEB01 web app is NOT accessible"
    echo "   Check if VM is running: vagrant status web01"
fi

# Test pre-uploaded web shell
echo ""
echo "2. Testing pre-uploaded web shell (http://10.0.1.10/uploads/cmd.aspx)..."
if curl -s -f --connect-timeout 10 http://10.0.1.10/uploads/cmd.aspx > /dev/null; then
    echo "   ✓ Web shell is accessible"
else
    echo "   ✗ Web shell is NOT accessible"
    echo "   The uploads directory may not have proper permissions."
fi

# Test ping to WEB01
echo ""
echo "3. Testing connectivity to WEB01 (10.0.1.10)..."
if ping -c 2 -W 2 10.0.1.10 > /dev/null 2>&1; then
    echo "   ✓ WEB01 is reachable via ping"
else
    echo "   ✗ WEB01 is NOT reachable via ping"
    echo "   Check VirtualBox network configuration."
fi

# Test ping to DC01 (may be blocked by firewall, but we disabled it)
echo ""
echo "4. Testing connectivity to DC01 (10.0.2.10)..."
if ping -c 2 -W 2 10.0.2.10 > /dev/null 2>&1; then
    echo "   ✓ DC01 is reachable via ping"
else
    echo "   ✗ DC01 is NOT reachable via ping"
    echo "   This may be expected if firewall rules are enabled."
fi

# Check Vagrant status
echo ""
echo "5. Checking Vagrant VM status..."
vagrant status --machine-readable | grep ',state,' | while IFS=',' read -r _ _ _ vm state; do
    echo "   $vm: $state"
done

echo ""
echo "========================================="
echo "  Test completed."
echo "  Refer to README.md for next steps."
echo "========================================="