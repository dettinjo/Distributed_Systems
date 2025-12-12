# Public IP for Application Gateway
resource "azurerm_public_ip" "app_gateway" {
  name                = "${var.project_name}-agw-pip-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Project = var.project_name
    Component = "LoadBalancer"
  }
}

# Application Gateway - Simplified
resource "azurerm_application_gateway" "main" {
  name                = "${var.project_name}-agw-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.public.id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "appGatewayFrontendIP"
    public_ip_address_id = azurerm_public_ip.app_gateway.id
  }

  # Blue Backend Pool
  backend_address_pool {
    name = "blue-backend-pool"
    ip_addresses = [azurerm_network_interface.blue_vm.private_ip_address]
  }

  # Green Backend Pool  
  backend_address_pool {
    name = "green-backend-pool"
    ip_addresses = [azurerm_network_interface.green_vm.private_ip_address]
  }

  # HTTP Settings
  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  # HTTP Listener
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "appGatewayFrontendIP"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  # Request Routing Rule - Start with Blue environment
  request_routing_rule {
    name                       = "blue-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "blue-backend-pool"
    backend_http_settings_name = "http-settings"
    priority                   = 100
  }

  tags = {
    Project = var.project_name
    Component = "LoadBalancer"
  }

  depends_on = [
    azurerm_linux_virtual_machine.blue,
    azurerm_linux_virtual_machine.green
  ]
}
