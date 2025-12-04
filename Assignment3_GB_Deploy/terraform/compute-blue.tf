# Public IP for Blue VM (for SSH access during development)
resource "azurerm_public_ip" "blue_vm" {
  name                = "${var.project_name}-blue-vm-pip-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Project = var.project_name
    Environment = "Blue"
  }
}

# Network Interface for Blue VM
resource "azurerm_network_interface" "blue_vm" {
  name                = "${var.project_name}-blue-vm-nic-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.blue.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.blue_vm.id
  }

  tags = {
    Project = var.project_name
    Environment = "Blue"
  }
}

# Blue Virtual Machine
resource "azurerm_linux_virtual_machine" "blue" {
  name                = "${var.project_name}-blue-vm-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_B1s"  # Small size for student subscription
  admin_username      = var.admin_username
  
  # Disable password authentication, use SSH keys only
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.blue_vm.id,
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

  # Custom data script for Apache installation
  custom_data = base64encode(<<-EOF
    #!/bin/bash
    
    # Update system
    apt-get update
    
    # Install Apache
    apt-get install -y apache2
    
    # Create blue environment web page
    cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Blue Environment - Apache Server</title>
    <style>
        body {
            background-color: #4A90E2;
            color: white;
            font-family: Arial, sans-serif;
            text-align: center;
            padding: 50px;
        }
        .container {
            background-color: rgba(255,255,255,0.1);
            padding: 30px;
            border-radius: 10px;
            margin: 0 auto;
            max-width: 600px;
        }
        h1 { font-size: 3em; margin-bottom: 20px; }
        h2 { color: #87CEEB; }
        .server-info {
            background-color: rgba(0,0,0,0.2);
            padding: 15px;
            border-radius: 5px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>BLUE ENVIRONMENT</h1>
        <h2>Apache HTTP Server</h2>
        <p>This is the Blue environment running Apache web server.</p>
        <p>Current production version serving traffic.</p>
        <div class="server-info">
            <strong>Server:</strong> Apache/2.4<br>
            <strong>Environment:</strong> Blue (Production)<br>
            <strong>Status:</strong> Active<br>
            <strong>Hostname:</strong> $(hostname)
        </div>
        <p><em>Blue/Green Deployment Lab - Session 3</em></p>
    </div>
</body>
</html>
HTML
    
    # Enable and start Apache
    systemctl enable apache2
    systemctl start apache2
    
    # Ensure Apache is running
    systemctl status apache2
    
    EOF
  )

  tags = {
    Project = var.project_name
    Environment = "Blue"
    WebServer = "Apache"
  }
}
