#!/bin/bash
# Active Directory Attack Lab - Setup Script
# This script checks prerequisites and deploys the lab using Vagrant

set -e

echo "========================================="
echo "  Active Directory Attack Lab Setup"
echo "========================================="

# Check if running as root (should not)
if [ "$EUID" -eq 0 ]; then
    echo "ERROR: Do not run as root. Run as normal user."
    exit 1
fi

# Check Vagrant
if ! command -v vagrant &> /dev/null; then
    echo "ERROR: Vagrant is not installed."
    echo "Please install Vagrant from https://www.vagrantup.com/downloads"
    exit 1
fi

# Check VirtualBox
if ! command -v VBoxManage &> /dev/null; then
    echo "ERROR: VirtualBox is not installed."
    echo "Please install VirtualBox from https://www.virtualbox.org/wiki/Downloads"
    exit 1
fi

# Check Vagrant version
VAGRANT_VERSION=$(vagrant --version | awk '{print $2}')
echo "Vagrant version: $VAGRANT_VERSION"

# Check VirtualBox version
VB_VERSION=$(VBoxManage --version | awk -F'_' '{print $1}')
echo "VirtualBox version: $VB_VERSION"

# Check available memory (optional)
MEM_AVAILABLE=$(free -g | awk '/^Mem:/ {print $2}')
if [ "$MEM_AVAILABLE" -lt 8 ]; then
    echo "WARNING: Only $MEM_AVAILABLE GB RAM available. 8 GB recommended."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check disk space (need at least 30 GB free in current directory)
DISK_SPACE=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$DISK_SPACE" -lt 30 ]; then
    echo "WARNING: Only $DISK_SPACE GB free disk space. 30 GB recommended."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check for VirtualBox Extension Pack (optional but recommended)
if ! VBoxManage list extpacks | grep -q "Extension Pack"; then
    echo "WARNING: VirtualBox Extension Pack not installed."
    echo "Recommended for better VM performance and USB support."
    echo "Download from: https://www.virtualbox.org/wiki/Downloads"
    read -p "Continue without Extension Pack? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Warn about large download
echo ""
echo "NOTICE: This lab uses Windows Server 2022 evaluation VMs."
echo "The initial download is approximately 10 GB and may take a while."
echo "Ensure you have a stable internet connection."
echo ""
read -p "Proceed with lab deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

# Start Vagrant deployment
echo "Starting Vagrant deployment..."
echo "This will take 30-60 minutes depending on your system and network."
echo "You can monitor progress in the terminal."
echo ""
vagrant up

echo ""
echo "========================================="
echo "  Deployment Complete!"
echo "========================================="
echo "Lab VMs are now running."
echo ""
echo "Access the vulnerable web app at: http://10.0.1.10/"
echo "Domain Controller: 10.0.2.10 (not directly accessible)"
echo ""
echo "Refer to README.md for lab objectives and attack path."
echo ""