resource "azurerm_service_plan" "plan" {
  name                = "${var.app_name}-plan"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1" # Consumption Plan (Serverless)
}

resource "azurerm_linux_function_app" "app" {
  name                = var.app_name
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_key
  service_plan_id            = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      node_version = "20" 
    }
  }

  app_settings = {
    "AzureWebJobsStorage"    = var.storage_connection_string
    "STORAGE_CONN_STRING"    = var.storage_connection_string
    "VISION_ENDPOINT"        = var.vision_endpoint
    "VISION_KEY"             = var.vision_key
    "QUEUE_NAME"             = "analysis-queue"
    "IMAGES_CONTAINER"       = "images"
    "RESULTS_CONTAINER"      = "analysis-results"
    "FUNCTIONS_WORKER_RUNTIME" = "node"
  }
}