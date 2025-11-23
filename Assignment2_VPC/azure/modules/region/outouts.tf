output "public_vm_ip" {
  value = azurerm_public_ip.public.ip_address
}

output "public_vm_private_ip" {
  value = azurerm_network_interface.public.private_ip_address
}

output "private_vm_private_ip" {
  value = azurerm_network_interface.private.private_ip_address
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "public_subnet_id" {
  value = azurerm_subnet.public.id
}

output "private_subnet_id" {
  value = azurerm_subnet.private.id
}

# Commented out by default. Enable for transformation:

/* output "private_vm_public_ip" {
  value = azurerm_public_ip.private.ip_address
} */
