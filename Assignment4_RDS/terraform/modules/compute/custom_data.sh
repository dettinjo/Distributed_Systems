#!/bin/bash
# Send logs to /var/log/custom-data.log
exec > >(tee /var/log/custom-data.log|logger -t custom-data -s 2>/dev/console) 2>&1

echo "--- Starting Azure Setup ---"

# 1. Install Python & Pip
apt-get update
apt-get install -y python3-pip python3-venv

# 2. Setup Directory
mkdir -p /home/azureuser/weather-app
cd /home/azureuser/weather-app

# 3. Create Virtual Env
python3 -m venv venv
source venv/bin/activate

# 4. Install Azure SDK
pip install azure-cosmos

# 5. Inject Application Code
cat <<EOF > app.py
${app_code}
EOF

# 6. Set Environment Variables for DB Connection
export COSMOS_ENDPOINT="${endpoint_url}"
export COSMOS_KEY="${primary_key}"

# 7. Run Simulation
echo "--- Running Simulation ---"
python app.py

# 8. Fix Permissions so you can read it later via SSH
chown -R azureuser:azureuser /home/azureuser/weather-app

echo "--- Setup Complete ---"