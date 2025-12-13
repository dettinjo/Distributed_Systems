# Public IP for Load Balancer
resource "azurerm_public_ip" "lb" {
  name                = "${var.project_name}-lb-pip-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Project = var.project_name
    Component = "LoadBalancer"
  }
}

# Load Balancer
resource "azurerm_lb" "main" {
  name                = "${var.project_name}-lb-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.lb.id
  }

  tags = {
    Project = var.project_name
    Component = "LoadBalancer"
  }
}

# Backend Address Pool for Blue
resource "azurerm_lb_backend_address_pool" "blue" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "blue-backend-pool"
}

# Backend Address Pool for Green
resource "azurerm_lb_backend_address_pool" "green" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "green-backend-pool"
}

# Health Probe
resource "azurerm_lb_probe" "http" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "http-probe"
  protocol        = "Http"
  request_path    = "/"
  port            = 80
}

# Load Balancing Rule - Start with Blue
resource "azurerm_lb_rule" "http" {
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.blue.id]
  probe_id                       = azurerm_lb_probe.http.id
}

# Associate Blue VM with Blue Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "blue" {
  network_interface_id    = azurerm_network_interface.blue_vm.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.blue.id
}

# Associate Green VM with Green Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "green" {
  network_interface_id    = azurerm_network_interface.green_vm.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.green.id
}
