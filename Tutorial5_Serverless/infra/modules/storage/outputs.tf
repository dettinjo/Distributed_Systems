output "account_name" {
  value = azurerm_storage_account.sa.name
}

output "primary_access_key" {
  value     = azurerm_storage_account.sa.primary_access_key
  sensitive = true
}

output "primary_connection_string" {
  value     = azurerm_storage_account.sa.primary_connection_string
  sensitive = true
}