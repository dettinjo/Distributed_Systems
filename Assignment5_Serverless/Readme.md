# Serverless AI Image Analyzer (Azure)

## 📌 Project Overview
This project is a **Serverless Image Analysis Pipeline** built on **Microsoft Azure**. It is a migration of the "AI as a Service" Lab (originally AWS) to the Azure ecosystem.

The system accepts an image URL, downloads it, and uses **Azure AI Vision (OCR)** to detect text and calculate confidence scores.

### 🏗 Architecture
The system follows an event-driven serverless architecture:

1.  **Crawler (Azure Function - HTTP Trigger):**
    * Receives a JSON payload with an image URL via HTTP POST.
    * Downloads the image.
    * Saves the image to **Blob Storage** (`images` container).
    * Puts a message (filename) onto a **Storage Queue** (`analysis-queue`).

2.  **Analyzer (Azure Function - Queue Trigger):**
    * Triggered automatically when a message arrives in the queue.
    * Reads the image from Blob Storage.
    * Sends the image to **Azure AI Vision (Read API)**.
    * Extracts text and calculates average confidence scores.
    * Saves the result as a JSON file in **Blob Storage** (`analysis-results` container).

---

## 🛠 Prerequisites

Ensure you have the following tools installed:

* **Azure CLI:** `brew install azure-cli` (macOS) or [Install Guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
* **Azure Functions Core Tools v4:** `brew tap azure/functions && brew install azure-functions-core-tools@4`
* **Terraform:** `brew install terraform`
* **Node.js (v18+):** `brew install node`

---

## 🚀 Setup Guide

### 1. Infrastructure (Terraform)
We use Terraform to provision all Azure resources (Storage Accounts, Function Apps, Vision Service).

```bash
cd infra
terraform init
terraform apply -auto-approve

```

**⚠️ Important:** At the end of the apply, copy the `function_app_name` from the output (e.g., `lab-func-28c3b1b4`). You will need this later.

### 2. Local Environment Configuration

**Do not create `local.settings.json` manually.** We have an automated script to fetch secrets from Azure.

1. Make sure you are logged in: `az login`
2. Run the setup script from the project root:

```bash
chmod +x setup-local-env.sh
./setup-local-env.sh

```

This script will:

* Find your deployed Storage and Vision resources.
* Fetch the Access Keys and Connection Strings.
* Generate `src/local.settings.json` (which is git-ignored).

### 3. Install Dependencies

Navigate to the source folder and install the Node.js packages:

```bash
cd src
npm install

```

---

## 💻 Running Locally

You can run the full pipeline on your laptop before deploying.

1. **Start the Functions:**
```bash
cd src
func start

```


*You should see a green list of endpoints (Crawler and Analyzer).*
2. **Trigger the Pipeline:**
Open a new terminal and send a request to your local crawler:
```bash
curl -X POST http://localhost:7071/api/crawler \
     -H "Content-Type: application/json" \
     -d '{"url": "[https://raw.githubusercontent.com/Azure-Samples/cognitive-services-sample-data-files/master/ComputerVision/Images/printed_text.jpg](https://raw.githubusercontent.com/Azure-Samples/cognitive-services-sample-data-files/master/ComputerVision/Images/printed_text.jpg)"}'

```


3. **Check Output:**
Check the terminal running `func start`. You should see logs indicating:
* `[Crawler]` Image uploaded to blob...
* `[Analyzer]` Analysis complete...



---

## ☁️ Deployment

To push your code to the live Azure infrastructure:

```bash
# Replace <APP_NAME> with the name from Terraform output
cd src
func azure functionapp publish <APP_NAME>

```

**Note:** You do **not** need to upload settings (`--publish-local-settings`) because Terraform has already configured the Function App environment variables in the cloud.

### Verifying Deployment

1. **Trigger the Live Endpoint:**
```bash
curl -X POST "https://<APP_NAME>.azurewebsites.net/api/crawler" \
     -H "Content-Type: application/json" \
     -d '{"url": "[https://raw.githubusercontent.com/Azure-Samples/cognitive-services-sample-data-files/master/ComputerVision/Images/printed_text.jpg](https://raw.githubusercontent.com/Azure-Samples/cognitive-services-sample-data-files/master/ComputerVision/Images/printed_text.jpg)"}'

```


2. **Check Results:**
Wait ~15 seconds, then list the files in the results container:
```bash
# You may need to use --auth-mode key if you lack RBAC roles
az storage blob list --account-name <STORAGE_ACCOUNT_NAME> --container-name analysis-results --output table --auth-mode key

```



---

## 🐛 Troubleshooting & Known Issues

### 1. "Tainted" Terraform State

* **Symptom:** Terraform errors saying a resource is "tainted".
* **Cause:** A previous deployment failed halfway.
* **Fix:** Run `terraform apply -auto-approve`. Terraform will destroy and recreate the broken resource automatically.

### 2. Git Push Blocked (Secret Scanning)

* **Symptom:** GitHub rejects your push with "Secret Scanning" errors.
* **Cause:** You accidentally committed `local.settings.json`.
* **Fix:**
```bash
git reset --soft HEAD~1
git restore --staged src/local.settings.json
echo "src/local.settings.json" >> .gitignore
git commit -m "Fixed secrets"
git push

```



### 3. Curl 401 Unauthorized

* **Symptom:** `curl` returns `HTTP/1.1 401 Unauthorized`.
* **Cause:** The function expects an API key (Function Level Auth).
* **Fix:** Ensure `src/crawler/function.json` has `"authLevel": "anonymous"`, then redeploy.

### 4. Permission Errors (RBAC)

* **Symptom:** `az storage blob list` says "AuthorizationPermissionMismatch".
* **Fix:** Use `--auth-mode key` to use the storage account key instead of your user identity, OR assign yourself the "Storage Blob Data Owner" role in the portal.

---

## 📂 Project Structure

```text
.
├── infra/                  # Terraform Infrastructure code
│   ├── main.tf             # Entry point
│   └── modules/            # Reusable modules (compute, storage, ai)
├── src/                    # Application Source Code
│   ├── analyzer/           # Azure Function: Queue Trigger (Vision Analysis)
│   ├── crawler/            # Azure Function: HTTP Trigger (Downloader)
│   ├── local.settings.json # (Ignored) Local secrets
│   └── package.json        # Dependencies
└── setup-local-env.sh      # Helper script to generate local settings

```