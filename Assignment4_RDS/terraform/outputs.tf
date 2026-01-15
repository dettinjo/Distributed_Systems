output "cosmos_db_endpoint" {
  value = module.database.endpoint
}

output "vm_public_ip" {
  value = module.compute.public_ip
}

output "connect_command" {
  value = "ssh -i ~/.ssh/id_rsa azureuser@${module.compute.public_ip}"
}