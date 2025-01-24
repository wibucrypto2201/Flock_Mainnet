#!/bin/bash

# Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Download Anaconda installer
echo "Downloading Anaconda installer..."
ANACONDA_URL="https://repo.anaconda.com/archive/Anaconda3-2023.07-1-Linux-x86_64.sh"
curl -O $ANACONDA_URL

# Verify checksum
echo "Verifying installer checksum..."
EXPECTED_SUM="aad10edc9dc8c59e0d5a1a28b06e9f24"
DOWNLOADED_SUM=$(sha256sum Anaconda3-2023.07-1-Linux-x86_64.sh | awk '{print $1}')
if [ "$EXPECTED_SUM" != "$DOWNLOADED_SUM" ]; then
    echo "Checksum verification failed. Exiting."
    exit 1
fi

# Run the installer
echo "Running the Anaconda installer..."
bash Anaconda3-2023.07-1-Linux-x86_64.sh -b

# Add Anaconda to PATH
echo "Adding Anaconda to PATH..."
echo 'export PATH="$HOME/anaconda3/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Clean up installer
echo "Cleaning up..."
rm Anaconda3-2023.07-1-Linux-x86_64.sh

# Test installation
echo "Testing Anaconda installation..."
conda --version

echo "Anaconda installation complete!"
