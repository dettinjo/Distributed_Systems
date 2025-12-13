output "traffic_manager_dns" {
  description = "The global DNS entry point for the Blue/Green deployment"
  value       = "http://${azurerm_traffic_manager_profile.global.fqdn}"
}

output "blue_regional_ip" {
  description = "Direct IP for Blue LB (Spain)"
  value       = module.blue_env.public_ip
}

output "green_regional_ip" {
  description = "Direct IP for Green LB (France)"
  value       = module.green_env.public_ip
}