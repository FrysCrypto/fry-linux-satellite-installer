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
        sudo apt install -y "$1"
        echo "$1 installed."
    else
        echo "$1 is already installed."
    fi
}

install_if_not_present node
install_if_not_present npm
install_if_not_present p7zip-full 7z
install_if_not_present wget
install_if_not_present nano
install_if_not_present git

echo "Cloning repository..."
git clone https://github.com/FrysCrypto/FRY-Satellite-Linux.git
echo "Repository cloned."

cd FRY-Satellite-Linux || { echo "Failed to navigate to FRY-Satellite-Linux directory. Exiting..."; exit 1; }

# Assuming the .7z file and directory structure is similar to the previous repo.
# Adjust the file name and directory paths as necessary based on the actual content of the new repo.

if [ -f "FRY Satellite Javascript.7z" ]; then
    echo "Extracting .7z file..."
    7z x "FRY Satellite Javascript.7z"
    echo "Done!"
else
    echo "The .7z file does not exist. Exiting..."
    exit 1
fi

cd "FRY Satellite Javascript" || { echo "Failed to navigate to FRY Satellite Javascript directory. Exiting..."; exit 1; }
cd "Connectivity Validation" || { echo "Failed to navigate to Connectivity Validation directory. Exiting..."; exit 1; }

echo "Installing dependencies..."
npm install algosdk
echo "Done!"

ABSOLUTE_PATH=$(pwd)

echo "Creating run.sh script..."
echo "#!/bin/bash" > "$SCRIPT_PATH/run.sh"
echo "node \"$ABSOLUTE_PATH/main.js\"" >> "$SCRIPT_PATH/run.sh"
chmod +x "$SCRIPT_PATH/run.sh"

read -rp "Do you want to add the script as a cron task to run every hour? (yes/no): " cron_response

if [[ $cron_response == "yes" || $cron_response == "y" ]]; then
    (crontab -l 2>/dev/null; echo "0 * * * * $SCRIPT_PATH/run.sh >> $ABSOLUTE_PATH/logs.log 2>&1") | crontab -
    echo "Cron task added. The script will run every hour and logs will be saved in logs.log."
else
    echo "Not adding to cron."
fi

echo "Installation complete!"
echo "To run the script, run ./run.sh"
