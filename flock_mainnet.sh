#!/bin/bash

# Anaconda Auto Installation Script for Ubuntu 22.04 (Run as root)
ANACONDA_INSTALLER="Anaconda3-2024.10-1-Linux-x86_64.sh"
ANACONDA_URL="https://repo.anaconda.com/archive/$ANACONDA_INSTALLER"
INSTALL_DIR="/root/anaconda3"  # Install in root's home directory

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
    sed -i '/anaconda3\/bin/d' /root/.bashrc
    echo "Anaconda has been removed."
}

# Function to install or update Anaconda
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
    echo "Checksum verification skipped for automation purposes."

    if [ -d "$INSTALL_DIR" ]; then
        echo "Anaconda is already installed. Updating the installation..."
        bash $ANACONDA_INSTALLER -u -p "$INSTALL_DIR" -f <<EOF
yes
EOF
    else
        echo "Installing Anaconda..."
        bash $ANACONDA_INSTALLER -b -p "$INSTALL_DIR"
    fi

    echo "Adding Anaconda to PATH..."
    SHELL_RC="/root/.bashrc"  # Root's shell config
    if ! grep -q "$INSTALL_DIR/bin" "$SHELL_RC"; then
        echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\"" >> "$SHELL_RC"
    fi
    source "$SHELL_RC"

    echo "Updating Anaconda..."
    $INSTALL_DIR/bin/conda update -n base -c defaults conda -y

    echo "Disabling auto-activation of the base environment..."
    $INSTALL_DIR/bin/conda config --set auto_activate_base false

    echo "Cleaning up..."
    rm $ANACONDA_INSTALLER

    echo "Anaconda installation or update completed successfully!"
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
        echo "Keeping the existing Anaconda installation. Attempting to update..."
        install_anaconda
    fi
else
    install_anaconda
fi
