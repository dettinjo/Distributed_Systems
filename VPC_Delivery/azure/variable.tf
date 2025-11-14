variable "region1" { default = "spaincentral" }
variable "region2" { default = "francecentral" }

variable "admin_username" {
  description = "Admin username for VM login"
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for VM login -- use a strong password"
  sensitive   = true
}

variable "admin_ssh_key" {
  description = "SSH public key for VM admin login"
}

variable "ssh_ip" {
  description = "Your public IP for SSH access"
  default     = "<YOUR_PUBLIC_IP>/32"
}
