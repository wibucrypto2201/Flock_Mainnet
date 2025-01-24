#!/bin/bash

# 1. Cập nhật hệ thống
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# 2. Kiểm tra phiên bản kernel và cài đặt các gói cần thiết
echo "Installing kernel headers and build tools..."
sudo apt install -y linux-headers-$(uname -r) build-essential dkms curl

# 3. Tắt Secure Boot nếu cần
echo "Checking Secure Boot..."
if [ -f /sys/firmware/efi/efivars/SecureBoot-*/data ]; then
    echo "Secure Boot is enabled. You need to disable it from BIOS/UEFI to proceed with NVIDIA driver installation."
    exit 1
fi

# 4. Tải NVIDIA Driver
NVIDIA_DRIVER_URL="https://us.download.nvidia.com/tesla/520.61.05/NVIDIA-Linux-x86_64-520.61.05.run"
echo "Downloading NVIDIA Driver from $NVIDIA_DRIVER_URL..."
curl -O $NVIDIA_DRIVER_URL

# 5. Cấp quyền thực thi cho NVIDIA installer
echo "Making NVIDIA Driver installer executable..."
chmod +x NVIDIA-Linux-x86_64-520.61.05.run

# 6. Dừng GUI (nếu đang chạy)
echo "Stopping graphical interface..."
sudo systemctl set-default multi-user.target
sudo systemctl stop gdm || echo "Graphical interface not running. Proceeding..."

# 7. Cài đặt NVIDIA Driver
echo "Running NVIDIA Driver installer..."
sudo ./NVIDIA-Linux-x86_64-520.61.05.run --silent --no-cc-version-check

# 8. Kiểm tra cài đặt NVIDIA
echo "Verifying NVIDIA Driver installation..."
if ! command -v nvidia-smi &> /dev/null; then
    echo "NVIDIA Driver installation failed. Please check /var/log/nvidia-installer.log for details."
    exit 1
fi
echo "NVIDIA Driver installed successfully!"

# 9. Thiết lập lại GUI (nếu cần)
echo "Re-enabling graphical interface..."
sudo systemctl set-default graphical.target
sudo systemctl start gdm || echo "GUI not required on this system."

# 10. Tải Anaconda
ANACONDA_URL="https://repo.anaconda.com/archive/Anaconda3-2023.07-1-Linux-x86_64.sh"
echo "Downloading Anaconda installer..."
curl -O $ANACONDA_URL

# 11. Kiểm tra checksum của Anaconda
echo "Verifying Anaconda installer checksum..."
EXPECTED_SUM="aad10edc9dc8c59e0d5a1a28b06e9f24"
DOWNLOADED_SUM=$(sha256sum Anaconda3-2023.07-1-Linux-x86_64.sh | awk '{print $1}')
if [ "$EXPECTED_SUM" != "$DOWNLOADED_SUM" ]; then
    echo "Checksum verification failed for Anaconda installer. Exiting."
    exit 1
fi

# 12. Cài đặt Anaconda
echo "Running Anaconda installer..."
bash Anaconda3-2023.07-1-Linux-x86_64.sh -b

# 13. Thêm Anaconda vào PATH
echo "Adding Anaconda to PATH..."
echo 'export PATH="$HOME/anaconda3/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 14. Làm sạch file cài đặt
echo "Cleaning up installation files..."
rm -f NVIDIA-Linux-x86_64-520.61.05.run
rm -f Anaconda3-2023.07-1-Linux-x86_64.sh

# 15. Kiểm tra Anaconda
echo "Verifying Anaconda installation..."
if ! command -v conda &> /dev/null; then
    echo "Anaconda installation failed."
    exit 1
fi
echo "Anaconda installed successfully!"

# 16. Hoàn thành
echo "All installations (NVIDIA Driver and Anaconda) completed successfully!"
