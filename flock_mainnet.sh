#!/bin/bash

# Anaconda Auto Installation Script for Ubuntu 22.04
# Author: [Your Name]

ANACONDA_INSTALLER="Anaconda3-2024.10-1-Linux-x86_64.sh"
ANACONDA_URL="https://repo.anaconda.com/archive/$ANACONDA_INSTALLER"
INSTALL_DIR="$HOME/anaconda3"

# Function to check if Anaconda is installed
check_anaconda_installed() {
    if [ -d "$INSTALL_DIR" ]; then
        echo "Anaconda is already installed in $INSTALL_DIR."
        return 0
    else
        echo "Anaconda is not installed."
        return 1
    fi
}

# Function to remove existing Anaconda installation
remove_anaconda() {
    echo "Removing existing Anaconda installation..."
    rm -rf "$INSTALL_DIR"
    sed -i '/anaconda3\/bin/d' ~/.bashrc
    echo "Anaconda has been removed."
}

# Function to install Anaconda
install_anaconda() {
    echo "Downloading Anaconda installer..."
    wget $ANACONDA_URL -O $ANACONDA_INSTALLER

    if [ ! -f "$ANACONDA_INSTALLER" ]; then
        echo "Failed to download Anaconda installer. Exiting..."
        exit 1
    fi

    echo "Verifying installer integrity..."
    sha256sum $ANACONDA_INSTALLER

    echo "Please check the checksum at the official site for verification:"
    echo "https://repo.anaconda.com/archive/"
    read -p "Does the checksum match? (y/n): " checksum_match
    if [ "$checksum_match" != "y" ]; then
        echo "Checksum mismatch. Exiting..."
        exit 1
    fi

    echo "Running Anaconda installer..."
    bash $ANACONDA_INSTALLER -b -p "$INSTALL_DIR"

    echo "Adding Anaconda to PATH..."
    echo 'export PATH="$HOME/anaconda3/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc

    echo "Updating Anaconda..."
    conda update -n base -c defaults conda -y

    echo "Cleaning up..."
    rm $ANACONDA_INSTALLER

    echo "Anaconda installation completed successfully!"
    echo "Run 'conda --version' to verify installation."
}

# Main script logic
echo "Checking if Anaconda is already installed..."
if check_anaconda_installed; then
    read -p "Do you want to remove the existing installation and reinstall Anaconda? (y/n): " reinstall_choice
    if [ "$reinstall_choice" == "y" ]; then
        remove_anaconda
        install_anaconda
    else
        echo "Keeping the existing Anaconda installation. Exiting..."
        exit 0
    fi
else
    install_anaconda
fi
