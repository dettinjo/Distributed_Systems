variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "France Central"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-blue-green-deployment"
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "bgdeploy"
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  default     = ""
}
