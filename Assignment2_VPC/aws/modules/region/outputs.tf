output "public_vm_public_ip" {
  value = aws_instance.public.public_ip
}
output "public_vm_private_ip" {
  value = aws_instance.public.private_ip
}
output "private_vm_private_ip" {
  value = aws_instance.private.private_ip
}
# transformation output block, only to be enabled if aws_eip.private is enabled
# output "private_vm_public_ip" {
#   value = aws_eip.private.public_ip
# }
output "vpc_id" {
  value = aws_vpc.this.id
}
