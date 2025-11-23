module "region1" {
  source              = "./modules/region"
  providers           = { aws = aws.region1 }
  vpc_cidr            = "10.1.0.0/16"
  public_subnet_cidr  = "10.1.1.0/24"
  private_subnet_cidr = "10.1.2.0/24"
  region_name         = var.aws_region1
  vm_name_public      = "Public VM #1"
  vm_name_private     = "Private VM #1"
  ami_id              = var.ami_id
  instance_type       = var.instance_type
  key_name            = var.key_name
}

module "region2" {
  source              = "./modules/region"
  providers           = { aws = aws.region2 }
  vpc_cidr            = "10.2.0.0/16"
  public_subnet_cidr  = "10.2.1.0/24"
  private_subnet_cidr = "10.2.2.0/24"
  region_name         = var.aws_region2
  vm_name_public      = "Public VM #2"
  vm_name_private     = "Private VM #2"
  ami_id              = var.ami_id
  instance_type       = var.instance_type
  key_name            = var.key_name
}
