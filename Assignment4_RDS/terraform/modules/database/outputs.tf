output "endpoint" {
  value = azurerm_cosmosdb_account.acc.endpoint
}
output "primary_key" {
  value     = azurerm_cosmosdb_account.acc.primary_key
  sensitive = true
}