output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "blue_vm_public_ip" {
  value = azurerm_public_ip.blue_vm.ip_address
}

output "blue_vm_ssh_command" {
  value = "ssh ${var.admin_username}@${azurerm_public_ip.blue_vm.ip_address}"
}

output "blue_environment_url" {
  value = "http://${azurerm_public_ip.blue_vm.ip_address}"
}

output "green_vm_public_ip" {
  value = azurerm_public_ip.green_vm.ip_address
}

output "green_vm_ssh_command" {
  value = "ssh ${var.admin_username}@${azurerm_public_ip.green_vm.ip_address}"
}

output "green_environment_url" {
  value = "http://${azurerm_public_ip.green_vm.ip_address}"
}

output "application_gateway_ip" {
  value = azurerm_public_ip.app_gateway.ip_address
  description = "Public IP of the Application Gateway"
}

output "load_balancer_url" {
  value = "http://${azurerm_public_ip.app_gateway.ip_address}"
  description = "URL for the load-balanced application"
}

output "architecture_summary" {
  value = {
    blue_environment  = "http://${azurerm_public_ip.blue_vm.ip_address}"
    green_environment = "http://${azurerm_public_ip.green_vm.ip_address}"
    load_balancer     = "http://${azurerm_public_ip.app_gateway.ip_address}"
  }
  description = "Summary of all environment URLs"
}
