terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "AI-Service-Lab-RG"
  location = "West Europe" # Change to your preferred region
}

# 1. Storage Account (Used for Images & Function App internal logs)
resource "azurerm_storage_account" "sa" {
  name                     = "aiservicestor${random_id.suffix.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# The container where you upload images
resource "azurerm_storage_container" "images" {
  name                  = "uploaded-images"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

# 2. Azure AI Vision (The "Rekognition" equivalent)
resource "azurerm_cognitive_account" "vision" {
  name                = "ai-vision-${random_id.suffix.hex}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "ComputerVision"
  sku_name            = "F0" # Free Tier (Change to S1 if Free is used up)
}

# 3. Cosmos DB (The "DynamoDB" equivalent)
resource "azurerm_cosmosdb_account" "acc" {
  name                = "ai-cosmos-${random_id.suffix.hex}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy { consistency_level = "Session" }
  geo_location {
    location = azurerm_resource_group.rg.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "db" {
  name                = "AnalysisDB"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.acc.name
}

resource "azurerm_cosmosdb_sql_container" "container" {
  name                = "ImageLabels"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.acc.name
  database_name       = azurerm_cosmosdb_sql_database.db.name
  partition_key_path  = "/file_name"
  throughput          = 400
}

# 4. Azure Function App (The "Lambda" equivalent)
resource "azurerm_service_plan" "plan" {
  name                = "serverless-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1" # Consumption (Serverless)
}

resource "azurerm_linux_function_app" "fn" {
  name                = "ai-function-${random_id.suffix.hex}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  service_plan_id            = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      python_version = "3.9" # Ensure this matches your local python version
    }
  }

  # Environment Variables passed to the code
  app_settings = {
    "VISION_ENDPOINT" = azurerm_cognitive_account.vision.endpoint
    "VISION_KEY"      = azurerm_cognitive_account.vision.primary_access_key
    "COSMOS_ENDPOINT" = azurerm_cosmosdb_account.acc.endpoint
    "COSMOS_KEY"      = azurerm_cosmosdb_account.acc.primary_key
    "AzureWebJobsStorage" = azurerm_storage_account.sa.primary_connection_string
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}