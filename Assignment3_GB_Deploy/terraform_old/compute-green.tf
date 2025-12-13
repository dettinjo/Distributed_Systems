# Public IP for Green VM
resource "azurerm_public_ip" "green_vm" {
  name                = "${var.project_name}-green-vm-pip-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Project = var.project_name
    Environment = "Green"
  }
}

# Network Interface for Green VM
resource "azurerm_network_interface" "green_vm" {
  name                = "${var.project_name}-green-vm-nic-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.green.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.green_vm.id
  }

  tags = {
    Project = var.project_name
    Environment = "Green"
  }
}

# Green Virtual Machine
resource "azurerm_linux_virtual_machine" "green" {
  name                = "${var.project_name}-green-vm-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.green_vm.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Project = var.project_name
    Environment = "Green"
    WebServer = "Nginx"
  }
}
