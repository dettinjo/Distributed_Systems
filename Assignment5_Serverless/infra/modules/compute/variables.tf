variable "resource_group_name" {}
variable "location" {}
variable "app_name" {}

# Inputs from Storage Module
variable "storage_account_name" {}
variable "storage_account_key" {}
variable "storage_connection_string" {}

# Inputs from AI Module
variable "vision_endpoint" {}
variable "vision_key" {}