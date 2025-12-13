variable "resource_group_name" {
  description = "Name of the main resource group"
  default     = "rg-blue-green-lab"
}

variable "location_main" {
  description = "Primary location for the Resource Group"
  default     = "spaincentral"
}

variable "blue_region" {
  description = "Region for Blue Environment"
  default     = "spaincentral"
}

variable "green_region" {
  description = "Region for Green Environment"
  default     = "francecentral"
}

variable "admin_username" {
  default = "azureuser"
}

variable "ssh_key_path" {
  description = "Path to your public SSH key (e.g., ~/.ssh/id_rsa.pub)"
  default     = "~/.ssh/id_rsa.pub"
}

# --- Traffic Weights ---
variable "blue_weight" {
  description = "Traffic weight for Blue"
  default     = 80
}

variable "green_weight" {
  description = "Traffic weight for Green"
  default     = 20
}