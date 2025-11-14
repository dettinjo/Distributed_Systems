variable "region" { default = "eu-west-1" }
variable "access_key" {}
variable "secret_key" {}
variable "session_token" {}
variable "ami_id"    { default = "<your-ami-id>" }
variable "instance_type" { default = "t2.micro" }
variable "ssh_ip"    { default = "<YOUR_PUBLIC_IP>/32" }
