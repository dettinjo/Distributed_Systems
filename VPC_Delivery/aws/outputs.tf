output "public_instance1_ip" {
  value = aws_instance.public1.public_ip
}
output "public_instance2_ip" {
  value = aws_instance.public2.public_ip
}
output "private_instance1_id" {
  value = aws_instance.private1.id
}
output "private_instance2_id" {
  value = aws_instance.private2.id
}
output "vpc_id" {
  value = aws_vpc.main.id
}
