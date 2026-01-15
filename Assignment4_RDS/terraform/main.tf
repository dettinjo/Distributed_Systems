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

# 1. Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# 2. Database Module
module "database" {
  source              = "./modules/database"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  db_account_name     = "weather-cosmos-${random_id.suffix.hex}"
}

# Helper to ensure unique Cosmos DB name
resource "random_id" "suffix" {
  byte_length = 4
}

# 3. Compute Module
module "compute" {
  source              = "./modules/compute"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vm_name             = "weather-runner"
  ssh_key_path        = var.ssh_key_path
  
  # Inject App Code
  app_code_content    = file("${path.root}/src/app.py")
  
  # Inject Database Connection Details (Outputs from DB module)
  cosmos_endpoint     = module.database.endpoint
  cosmos_key          = module.database.primary_key
}