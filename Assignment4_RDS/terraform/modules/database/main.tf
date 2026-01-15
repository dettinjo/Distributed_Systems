resource "azurerm_cosmosdb_account" "acc" {
  name                = var.db_account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB" # NoSQL API

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "db" {
  name                = "WeatherDB"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.acc.name
}

resource "azurerm_cosmosdb_sql_container" "coll" {
  name                = "WeatherContainer"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.acc.name
  database_name       = azurerm_cosmosdb_sql_database.db.name
  partition_key_paths = ["/RegionID"]
  throughput          = 400
}