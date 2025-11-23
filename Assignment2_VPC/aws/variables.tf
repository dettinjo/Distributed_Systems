variable "aws_region1" { default = "eu-west-1" }
variable "aws_region2" { default = "eu-north-1" } # pick supported regions
variable "ami_id" { default = "ami-..." } # Use Ubuntu or Amazon Linux AMI ID for your region
variable "instance_type" { default = "t2.micro" }
variable "key_name" {}
