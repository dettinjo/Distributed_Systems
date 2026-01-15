variable "location" {
  description = "Azure region (e.g., westeurope)"
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "WeatherSim-RG"
}

variable "ssh_key_path" {
  description = "Path to your local public SSH key"
  type        = string
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}