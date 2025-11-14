module "region1" {
  source = "./modules/region"
  region               = var.region1
  rg_name              = "rg-demo-region1"
  vnet_name            = "vnet-region1"
  public_subnet_name   = "public-subnet1"
  public_subnet_prefix = "10.1.1.0/24"
  private_subnet_name  = "private-subnet1"
  private_subnet_prefix = "10.1.2.0/24"
  address_space        = "10.1.0.0/16"
  admin_username       = var.admin_username
  admin_ssh_key        = var.admin_ssh_key
  ssh_ip               = var.ssh_ip
  vm_name_public       = "Public VM #1"
  vm_name_private      = "Private VM #1"
}

module "region2" {
  source = "./modules/region"
  region               = var.region2
  rg_name              = "rg-demo-region2"
  vnet_name            = "vnet-region2"
  public_subnet_name   = "public-subnet2"
  public_subnet_prefix = "10.2.1.0/24"
  private_subnet_name  = "private-subnet2"
  private_subnet_prefix = "10.2.2.0/24"
  address_space        = "10.2.0.0/16"
  admin_username       = var.admin_username
  admin_ssh_key        = var.admin_ssh_key
  ssh_ip               = var.ssh_ip
  vm_name_public       = "Public VM #2"
  vm_name_private      = "Private VM #2"
}
