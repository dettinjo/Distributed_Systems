output "function_app_name" {
  description = "The name of the created Function App."
  value       = module.compute.function_app_name
}

output "function_app_default_hostname" {
  description = "The default URL of the Function App."
  value       = module.compute.function_app_default_hostname
}

output "crawler_endpoint" {
  description = "The specific endpoint to trigger the crawler."
  value       = "https://${module.compute.function_app_default_hostname}/api/crawler"
}

output "storage_account_name" {
  description = "The name of the storage account created."
  value       = module.storage.account_name
}