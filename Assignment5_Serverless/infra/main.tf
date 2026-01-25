resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name  # Changed from hardcoded string
  location = var.location             # Changed from "West Europe"
}

resource "random_id" "suffix" {
  byte_length = 4
}

module "storage" {
  source               = "./modules/storage"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  storage_account_name = "labstore${random_id.suffix.hex}"
}

module "ai" {
  source              = "./modules/ai"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vision_name         = "labvision${random_id.suffix.hex}"
}

module "compute" {
  source                    = "./modules/compute"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  app_name                  = "lab-func-${random_id.suffix.hex}"
  storage_account_name      = module.storage.account_name
  storage_account_key       = module.storage.primary_access_key
  storage_connection_string = module.storage.primary_connection_string
  vision_endpoint           = module.ai.endpoint
  vision_key                = module.ai.key
}