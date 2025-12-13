# Network Security Group for Web Servers
resource "azurerm_network_security_group" "web" {
  name                = "${var.project_name}-web-nsg-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Allow HTTP
  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow SSH
  security_rule {
    name                       = "SSH"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow Application Gateway Health Probes
  security_rule {
    name                       = "AppGatewayHealthProbe"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  tags = {
    Project = var.project_name
  }
}

# Associate NSG with Blue subnet
resource "azurerm_subnet_network_security_group_association" "blue" {
  subnet_id                 = azurerm_subnet.blue.id
  network_security_group_id = azurerm_network_security_group.web.id
}

# Associate NSG with Green subnet
resource "azurerm_subnet_network_security_group_association" "green" {
  subnet_id                 = azurerm_subnet.green.id
  network_security_group_id = azurerm_network_security_group.web.id
}
