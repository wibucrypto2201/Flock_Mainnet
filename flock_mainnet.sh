#!/bin/bash

# 1. Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# 2. Install dependencies for NVIDIA Driver
echo "Installing dependencies for NVIDIA Driver..."
sudo apt install -y build-essential dkms

# 3. Download NVIDIA Driver installer
NVIDIA_DRIVER_URL="https://us.download.nvidia.com/tesla/520.61.05/NVIDIA-Linux-x86_64-520.61.05.run"
echo "Downloading NVIDIA Driver from $NVIDIA_DRIVER_URL..."
curl -O $NVIDIA_DRIVER_URL

# 4. Make the NVIDIA installer executable
echo "Making NVIDIA Driver installer executable..."
chmod +x NVIDIA-Linux-x86_64-520.61.05.run

# 5. Stop GUI (if running)
echo "Stopping graphical interface (if running)..."
sudo systemctl set-default multi-user.target
sudo systemctl stop gdm

# 6. Run the NVIDIA installer
echo "Running the NVIDIA Driver installer..."
sudo ./NVIDIA-Linux-x86_64-520.61.05.run --silent --no-cc-version-check

# 7. Verify NVIDIA installation
echo "Verifying NVIDIA Driver installation..."
nvidia-smi
if [ $? -ne 0 ]; then
    echo "NVIDIA Driver installation failed. Exiting."
    exit 1
fi
echo "NVIDIA Driver installed successfully!"

# 8. Set GUI back to default (if needed)
echo "Setting graphical interface back to default..."
sudo systemctl set-default graphical.target
sudo systemctl start gdm

# 9. Download Anaconda installer
echo "Downloading Anaconda installer..."
ANACONDA_URL="https://repo.anaconda.com/archive/Anaconda3-2023.07-1-Linux-x86_64.sh"
curl -O $ANACONDA_URL

# 10. Verify Anaconda checksum
echo "Verifying Anaconda installer checksum..."
EXPECTED_SUM="aad10edc9dc8c59e0d5a1a28b06e9f24"
DOWNLOADED_SUM=$(sha256sum Anaconda3-2023.07-1-Linux-x86_64.sh | awk '{print $1}')
if [ "$EXPECTED_SUM" != "$DOWNLOADED_SUM" ]; then
    echo "Checksum verification failed for Anaconda installer. Exiting."
    exit 1
fi

# 11. Run the Anaconda installer
echo "Running the Anaconda installer..."
bash Anaconda3-2023.07-1-Linux-x86_64.sh -b

# 12. Add Anaconda to PATH
echo "Adding Anaconda to PATH..."
echo 'export PATH="$HOME/anaconda3/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 13. Clean up installer files
echo "Cleaning up installer files..."
rm NVIDIA-Linux-x86_64-520.61.05.run
rm Anaconda3-2023.07-1-Linux-x86_64.sh

# 14. Verify Anaconda installation
echo "Verifying Anaconda installation..."
if conda --version; then
    echo "Anaconda installation complete!"
else
    echo "Anaconda installation failed. Please check for errors."
    exit 1
fi

echo "All installations (NVIDIA Driver and Anaconda) completed successfully!"
