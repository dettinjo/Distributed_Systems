output "function_app_name" {
  value = azurerm_linux_function_app.app.name
}

output "function_app_default_hostname" {
  value = azurerm_linux_function_app.app.default_hostname
}