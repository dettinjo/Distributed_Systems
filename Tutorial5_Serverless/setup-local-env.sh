#!/bin/bash

# Configuration
RESOURCE_GROUP="serverless-lab-rg"
# Use existing terraform outputs or find resources by suffix/tag if names change
# For this script, we'll fetch them dynamically using Azure CLI queries

echo "🔍 Detecting Azure Resources in $RESOURCE_GROUP..."

# 1. Find the Storage Account (assumes only one or picks the first one in the RG)
STORAGE_ACCOUNT=$(az storage account list -g $RESOURCE_GROUP --query "[0].name" -o tsv)
if [ -z "$STORAGE_ACCOUNT" ]; then
    echo "❌ Error: No Storage Account found in $RESOURCE_GROUP"
    exit 1
fi
echo "   ✅ Found Storage Account: $STORAGE_ACCOUNT"

# 2. Find the Cognitive Services Account (Computer Vision)
VISION_ACCOUNT=$(az cognitiveservices account list -g $RESOURCE_GROUP --query "[0].name" -o tsv)
if [ -z "$VISION_ACCOUNT" ]; then
    echo "❌ Error: No Cognitive Services Account found in $RESOURCE_GROUP"
    exit 1
fi
echo "   ✅ Found Vision Account: $VISION_ACCOUNT"

echo "🔑 Fetching Secrets..."

# 3. Get Connection String
STORAGE_CONN_STRING=$(az storage account show-connection-string --name $STORAGE_ACCOUNT -g $RESOURCE_GROUP --query connectionString -o tsv)

# 4. Get Vision Credentials
VISION_ENDPOINT=$(az cognitiveservices account show --name $VISION_ACCOUNT -g $RESOURCE_GROUP --query properties.endpoint -o tsv)
VISION_KEY=$(az cognitiveservices account keys list --name $VISION_ACCOUNT -g $RESOURCE_GROUP --query key1 -o tsv)

echo "📝 Generating src/local.settings.json..."

# 5. Write to file
cat > src/local.settings.json <<EOF
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "$STORAGE_CONN_STRING",
    "FUNCTIONS_WORKER_RUNTIME": "node",
    "STORAGE_CONN_STRING": "$STORAGE_CONN_STRING",
    "VISION_ENDPOINT": "$VISION_ENDPOINT",
    "VISION_KEY": "$VISION_KEY",
    "QUEUE_NAME": "analysis-queue",
    "IMAGES_CONTAINER": "images",
    "RESULTS_CONTAINER": "analysis-results"
  }
}
EOF

echo "🎉 Done! You can now run 'func start' in the src directory."