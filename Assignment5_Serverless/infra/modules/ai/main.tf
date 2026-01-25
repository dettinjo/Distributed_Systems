resource "azurerm_cognitive_account" "vision" {
  name                = var.vision_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "ComputerVision"
  sku_name            = "S1" # Free tier (use S1 if F0 is exhausted)
}