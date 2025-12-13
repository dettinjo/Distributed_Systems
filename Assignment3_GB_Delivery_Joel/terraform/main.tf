resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location_main
}

resource "random_id" "dns_suffix" {
  byte_length = 4
}

# --- BLUE ENVIRONMENT (Spain Central) ---
module "blue_env" {
  source              = "./modules/regional_environment"
  env_name            = "blue"
  location            = var.blue_region
  resource_group_name = azurerm_resource_group.main.name
  admin_username      = var.admin_username
  ssh_key_path        = var.ssh_key_path
  
  # User Data: Apache (Blue Background)
  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    cat << HTML > /var/www/html/index.html
    <html>
    <body bgcolor="#5DBCD2">
    <h1>Blue Environment (Spain Central)</h1>
    <h2>Apache Server</h2>
    </body>
    </html>
    HTML
    systemctl enable apache2
    systemctl start apache2
  EOF
  )
}

# --- GREEN ENVIRONMENT (France Central) ---
module "green_env" {
  source              = "./modules/regional_environment"
  env_name            = "green"
  location            = var.green_region
  resource_group_name = azurerm_resource_group.main.name
  admin_username      = var.admin_username
  ssh_key_path        = var.ssh_key_path

  # User Data: Nginx (Green Background)
  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    mv /var/www/html/index.nginx-debian.html /var/www/html/index.html.bak
    cat << HTML > /var/www/html/index.html
    <html>
    <body bgcolor="#98FB98">
    <h1>Green Environment (France Central)</h1>
    <h2>Nginx Server</h2>
    </body>
    </html>
    HTML
    systemctl enable nginx
    systemctl start nginx
  EOF
  )
}

# --- GLOBAL TRAFFIC MANAGER ---
resource "azurerm_traffic_manager_profile" "global" {
  name                   = "tm-bluegreen-${random_id.dns_suffix.hex}"
  resource_group_name    = azurerm_resource_group.main.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "lab-bluegreen-${random_id.dns_suffix.hex}"
    ttl           = 30 # Low TTL for faster testing of weight changes
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "blue" {
  name               = "blue-endpoint"
  profile_id         = azurerm_traffic_manager_profile.global.id
  weight             = var.blue_weight
  target_resource_id = module.blue_env.public_ip_id
}

resource "azurerm_traffic_manager_azure_endpoint" "green" {
  name               = "green-endpoint"
  profile_id         = azurerm_traffic_manager_profile.global.id
  weight             = var.green_weight
  target_resource_id = module.green_env.public_ip_id
}