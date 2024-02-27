
#!/bin/bash

# Install necessary packages
apt-get update
apt-get install -y curl jq moreutils

# Download and install the Algorand node
curl -O https://raw.githubusercontent.com/algorand/go-algorand-doc/master/downloads/installers/update.sh
chmod 544 update.sh
./update.sh -i -c stable -p ~/node -d ~/node/data -n

# Wait for the node to sync
echo "Waiting for the node to sync. This can take a while..."
until [ "$(goal node status | grep 'Sync Time' | awk '{ print $NF }')" == "0s" ]; do
    sleep 60
done

# Prompt for mnemonic phrase and update config.json accordingly
echo "Please enter your mnemonic phrase: "
read mnemonic_phrase
CONFIG_JSON_PATH="~/node/data/config.json"
jq --arg mp "$mnemonic_phrase" '.main_account_mnemonic = $mp' $CONFIG_JSON_PATH | sponge $CONFIG_JSON_PATH

# Create or modify run.sh with the cron job setup
echo "#!/bin/bash" > ~/run.sh
echo "# Add your node commands here" >> ~/run.sh
echo "# Example: goal node status" >> ~/run.sh
(crontab -l 2>/dev/null; echo "0 * * * * /home/\$USER/run.sh") | crontab -

# Make the script executable
chmod +x ~/run.sh

echo "Installation and initial setup complete. run.sh has been created and scheduled."
