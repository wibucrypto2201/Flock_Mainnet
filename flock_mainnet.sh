#!/bin/bash

# Anaconda Auto Installation Script for Ubuntu 22.04
# Author: [Your Name]

echo "Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

# Install necessary tools
echo "Installing necessary tools..."
sudo apt install -y curl wget bzip2

# Download Anaconda installer
echo "Downloading Anaconda installer..."
ANACONDA_URL="https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh"
INSTALLER_NAME="Anaconda3-2024.10-1-Linux-x86_64.sh"

wget $ANACONDA_URL -O $INSTALLER_NAME

if [ ! -f "$INSTALLER_NAME" ]; then
    echo "Failed to download Anaconda installer. Exiting..."
    exit 1
fi

# Verify installer
echo "Verifying installer integrity..."
sha256sum $INSTALLER_NAME

echo "Please check the checksum at the official site for verification:"
echo "https://repo.anaconda.com/archive/"

read -p "Does the checksum match? (y/n): " checksum_match
if [ "$checksum_match" != "y" ]; then
    echo "Checksum mismatch. Exiting..."
    exit 1
fi

# Run the Anaconda installer
echo "Running Anaconda installer..."
bash $INSTALLER_NAME -b

# Add Anaconda to PATH
echo "Adding Anaconda to PATH..."
echo 'export PATH="$HOME/anaconda3/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Update Anaconda
echo "Updating Anaconda..."
conda update -n base -c defaults conda -y

# Cleanup
echo "Cleaning up..."
rm $INSTALLER_NAME

echo "Anaconda installation completed successfully!"
echo "Run 'conda --version' to verify installation."
