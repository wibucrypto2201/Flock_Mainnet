#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define color codes
GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"

# Function to handle errors
error_exit() {
    echo -e "${RED}Error: $1${RESET}"
    exit 1
}

# Function to print success messages
success() {
    echo -e "${GREEN}$1${RESET}"
}

echo "Starting the setup process..."

# Step 1: Download Anaconda
if [ ! -f "anaconda.sh" ]; then
    echo "Downloading Anaconda..."
    wget -O anaconda.sh https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh || error_exit "Failed to download Anaconda"
    success "Anaconda downloaded successfully."
else
    success "Anaconda installer already exists."
fi

# Step 2: Install Anaconda
if [ -d "$HOME/anaconda3" ]; then
    echo "Anaconda installation detected at $HOME/anaconda3."
    read -p "Would you like to update (u) or remove and reinstall (r)? [u/r]: " choice
    case $choice in
        u|U)
            echo "Updating existing Anaconda installation..."
            bash anaconda.sh -b -u -p $HOME/anaconda3 || error_exit "Failed to update Anaconda"
            success "Anaconda updated successfully."
            ;;
        r|R)
            echo "Removing existing Anaconda installation..."
            rm -rf $HOME/anaconda3 || error_exit "Failed to remove existing Anaconda installation"
            echo "Reinstalling Anaconda..."
            bash anaconda.sh -b -p $HOME/anaconda3 || error_exit "Failed to install Anaconda"
            success "Anaconda reinstalled successfully."
            ;;
        *)
            error_exit "Invalid choice. Please rerun the script and choose either 'u' or 'r'."
            ;;
    esac
else
    echo "Installing Anaconda..."
    bash anaconda.sh -b -p $HOME/anaconda3 || error_exit "Failed to install Anaconda"
    success "Anaconda installed successfully."
fi

# Step 3: Configure PATH and initialize conda
echo "Configuring environment..."
export PATH="$HOME/anaconda3/bin:$PATH"
echo 'export PATH="$HOME/anaconda3/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc || error_exit "Failed to configure environment"

# Initialize Conda
conda init || error_exit "Failed to initialize Conda"
success "Environment configured successfully."

# Step 4: Clone repository
echo "Cloning the repository..."
git clone https://github.com/FLock-io/llm-loss-validator.git || error_exit "Failed to clone repository"
success "Repository cloned successfully."

# Step 5: Navigate to project directory
echo "Navigating to project directory..."
cd llm-loss-validator || error_exit "Failed to navigate to project directory"
success "Navigated to project directory."

# Step 6: Create a clean Conda environment
echo "Creating a clean Conda environment..."
conda create -n llm-env python=3.10 -y || error_exit "Failed to create Conda environment"
source activate llm-env || error_exit "Failed to activate Conda environment"
success "Conda environment created and activated successfully."

# Step 7: Install packages from requirements.txt
echo "Installing required Python packages..."
pip install -r requirements.txt || error_exit "Failed to install required Python packages"
success "Python packages installed successfully."

# Step 8: Handle dependency conflicts manually
echo "Resolving dependency conflicts..."
pip uninstall -y s3fs fsspec datasets || error_exit "Failed to uninstall conflicting packages"

# Install compatible versions
pip install fsspec==2023.6.0 s3fs==2023.6.0 datasets==2.19.2 || error_exit "Failed to install compatible versions of fsspec, s3fs, and datasets"

# Step 9: Final environment check
echo "Checking for any remaining conflicts..."
pip check || error_exit "Package conflict still exists"

success "All dependencies installed and conflicts resolved successfully."

echo -e "${GREEN}Setup complete!${RESET}"
