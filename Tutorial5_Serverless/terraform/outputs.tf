output "function_app_name" {
  value = azurerm_linux_function_app.fn.name
}
output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}