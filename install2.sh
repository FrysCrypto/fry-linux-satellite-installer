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

# SCRIPT_PATH="/home/debian/scripts/FRY-Satellite-Linux/FRY Satellite/Connectivity Validation"
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
            # Ensure curl is installed for adding NodeSource repository
            if ! command -v curl &> /dev/null; then
                sudo apt install -y curl
            fi
            # Node.js installation with NodeSource
            curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
        fi
        sudo apt install -y "$1"
        echo "$1 installed."
    else
        echo "$1 is already installed."
    fi
}


install_if_not_present nodejs
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

# ... (any other steps needed for setup) ...

# Create run.sh script if it doesn't exist
if [ ! -f "$SCRIPT_PATH/run.sh" ]; then
    echo "run.sh script does not exist. Creating it now..."
    echo "#!/bin/bash" > "$SCRIPT_PATH/run.sh"
    echo "#!/bin/bash" > "$SCRIPT_PATH/run.sh"
    # Add the commands you need to run your application here
    echo "cd \"$SCRIPT_PATH/FRY-Satellite-Linux/FRY Satellite/Connectivity Validation\"" >> "$SCRIPT_PATH/run.sh"
    echo "node main.js" >> "$SCRIPT_PATH/run.sh" # Replace "node main.js" with the actual command to start your app
    chmod +x "$SCRIPT_PATH/run.sh"
    echo "run.sh script created."
else
    echo "run.sh script already exists."
fi

# Add cron job to run the script every hour if it doesn't already exist
cron_job="0 * * * * $SCRIPT_PATH/run.sh"
(crontab -l 2>/dev/null; echo "$cron_job") | crontab -
echo "Cron job added to run the script every hour."
echo "Installation complete!"
echo "To run the script, run ./run.sh"



# Generate or overwrite the run.sh file with cron job setup
cat > run.sh << 'EOF'
#!/bin/bash

# Check and install jq if not installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Installing jq..."
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get update && sudo apt-get install -y jq
    elif [ -x "$(command -v yum)" ]; then
        sudo yum install -y jq
    else
        echo "Error: Package manager not supported. Please install jq manually."
        exit 1
    fi
fi

# Prompt the user for the mnemonic phrase
echo "Please enter the main account mnemonic phrase:"
read mnemonic_phrase

# Update the config.json file with the entered mnemonic phrase
jq --arg mn "$mnemonic_phrase" '.main_account_mnemonic = $mn' config.json > temp.json && mv temp.json config.json

echo "The mnemonic phrase has been updated in config.json."

# Add the cron job to run this script every hour
(crontab -l 2>/dev/null; echo "0 * * * * $(pwd)/run.sh") | crontab -

EOF

# Make run.sh executable
chmod +x run.sh

echo "Setup complete. run.sh has been created and made executable. It will prompt for the mnemonic phrase, update config.json, and set up a cron job."
