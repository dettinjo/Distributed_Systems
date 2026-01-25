output "endpoint" {
  value = azurerm_cognitive_account.vision.endpoint
}

output "key" {
  value     = azurerm_cognitive_account.vision.primary_access_key
  sensitive = true
}