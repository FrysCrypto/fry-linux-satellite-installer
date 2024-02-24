#!/bin/bash
echo '                             '
echo '                             '
echo '$$$$$$$$  \$$$$$$$ \$$\     $$\ '
echo '$$  _____ $$  __$$  \$$\   $$  |'
echo '$$ |      $$ |  $$   \$$\ $$  / '
echo '$$$$$$\   $$$$$$$  |  \$$$$  /  '
echo '$$  __|   $$  __$$<    \$$  /   '
echo '$$ |      $$ |  $$ |    $$ |    '
echo '$$ |      $$ |  $$ |    $$ |    '
echo '\__|      \__|  \__|    \__|    '
echo '                             '
echo '                             '
echo 'Made by Simon :)'
echo '                             '
echo '                             '

set -e

SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"
echo "$SCRIPT_PATH"

read -rp "Welcome! Do you want to run the installer? (yes/no): " start_response
if [[ $start_response != "yes" && $start_response != "y" ]]; then
    echo "Exiting the installer."
    exit 0
fi

read -rp "Do you want to update the package lists? (yes/no): " update_response
if [[ $update_response == "yes" || $update_response == "y" ]]; then
    echo "Updating package lists..."
    sudo apt update
else
    echo "Skipping package list update."
fi

install_if_not_present() {
    local cmd_name=${2:-$1}
    if ! command -v "$cmd_name" &> /dev/null; then
        echo "$1 is not installed. Installing..."
        if [ "$1" = "nodejs" ]; then
            curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
        fi
        if [ "$1" = "curl" ]; then
            sudo apt install -y curl
        fi
        sudo apt install -y "$1"
        echo "$1 installed."
    else
        echo "$1 is already installed."
    fi
}

# Ensure curl is installed for adding NodeSource repository
install_if_not_present curl

# Node.js installation with NodeSource
install_if_not_present nodejs nodejs # NodeSource setup will be called within the function if nodejs is missing

install_if_not_present npm
install_if_not_present p7zip-full 7z
install_if_not_present wget
install_if_not_present nano
install_if_not_present git

echo "Cloning repository..."
git clone https://github.com/FrysCrypto/FRY-Satellite-Linux.git
echo "Repository cloned."

cd FRY-Satellite-Linux || { echo "Failed to navigate to FRY-Satellite-Linux directory. Exiting..."; exit 1; }

if [ -f "FRY Satellite.7z" ]; then
    echo "Extracting .7z file..."
    7z x "FRY Satellite.7z"
    echo "Done!"
else
    echo "The .7z file does not exist. Exiting..."
    exit 1
fi

# The subsequent commands should be adjusted according to the contents of the .7z file once extracted

echo "Installation complete!"
echo "To run the script, run ./run.sh"
