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
