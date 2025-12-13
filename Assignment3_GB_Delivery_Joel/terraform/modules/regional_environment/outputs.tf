output "public_ip_id" {
  value = azurerm_public_ip.lb.id
}

output "public_ip" {
  value = azurerm_public_ip.lb.ip_address
}