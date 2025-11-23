output "region1_public_vm_public_ip" {
  value = module.region1.public_vm_public_ip
}

output "region2_public_vm_public_ip" {
  value = module.region2.public_vm_public_ip
}

output "region1_private_vm_private_ip" {
  value = module.region1.private_vm_private_ip
}

output "region2_private_vm_private_ip" {
  value = module.region2.private_vm_private_ip
}

output "region1_vpc_id" {
  value = module.region1.vpc_id
}

output "region2_vpc_id" {
  value = module.region2.vpc_id
}
