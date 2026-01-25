variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources."
  type        = string
  default     = "serverless-lab-rg"
}

variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
  default     = "West Europe"
}

variable "environment" {
  description = "The environment name (e.g., dev, prod) to be used in tags."
  type        = string
  default     = "dev"
}