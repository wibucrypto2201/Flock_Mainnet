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

# Step 1: Download and Install Anaconda
echo "Downloading Anaconda..."
wget -O anaconda.sh https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh || error_exit "Failed to download Anaconda"
success "Anaconda downloaded successfully."

echo "Installing Anaconda..."
bash anaconda.sh -b -p $HOME/anaconda3 || error_exit "Failed to install Anaconda"
success "Anaconda installed successfully."

# Step 2: Configure PATH and initialize conda
echo "Configuring environment..."
export PATH="$HOME/anaconda3/bin:$PATH"
echo 'export PATH="$HOME/anaconda3/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc || error_exit "Failed to configure environment"

# Initialize Conda
conda init || error_exit "Failed to initialize Conda"
success "Environment configured successfully."

# Step 3: Restart shell (required for conda to be fully configured)
echo "Restarting shell..."
exec bash || error_exit "Failed to restart shell"

# Step 4: Activate conda environment
echo "Activating conda environment: llm-loss-validator..."
conda activate llm-loss-validator || error_exit "Failed to activate conda environment"
success "Conda environment activated successfully."

# Step 5: Navigate to project directory
echo "Navigating to project directory..."
cd llm-loss-validator || error_exit "Failed to navigate to project directory"
success "Navigated to project directory."

# Step 6: Install Python packages
echo "Installing required Python packages..."
pip install -r requirements.txt || error_exit "Failed to install required Python packages"
success "Python packages installed successfully."

echo -e "${GREEN}Setup complete!${RESET}"
