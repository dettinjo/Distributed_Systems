resource "azurerm_resource_group" "this" {
  name     = var.rg_name
  location = var.region
}

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.this.name
  location            = var.region
  address_space       = [var.address_space]
}

resource "azurerm_subnet" "public" {
  name                 = var.public_subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.public_subnet_prefix]
}

resource "azurerm_subnet" "private" {
  name                 = var.private_subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.private_subnet_prefix]
}

# --- NAT GATEWAY CONFIGURATION (NEW) ---
# This provides outbound internet access to the Private Subnet
# enabling "Ping 8.8.8.8" and package installation (apt/pip).

resource "azurerm_public_ip" "nat" {
  name                = "${var.vnet_name}-nat-pip"
  location            = var.region
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "this" {
  name                = "${var.vnet_name}-natgw"
  location            = var.region
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "this" {
  subnet_id      = azurerm_subnet.private.id
  nat_gateway_id = azurerm_nat_gateway.this.id
}
# ---------------------------------------

resource "azurerm_public_ip" "public" {
  name                = "${var.vnet_name}-publicip"
  location            = var.region
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# --- TRANSFORMATION STEP: UNCOMMENT TO MAKE PRIVATE VM PUBLIC ---
resource "azurerm_public_ip" "private" {
  name                = "${var.vnet_name}-private-publicip"
  location            = var.region
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "web" {
  name                = "${var.vnet_name}-nsg"
  location            = var.region
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow-SSH"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.ssh_ip
    destination_address_prefix = "*"
  }
  
  # --- FIX: ADDED ICMP (PING) RULE ---
  security_rule {
    name                       = "Allow-ICMP"
    priority                   = 104
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "public" {
  name                = "${var.vnet_name}-nic-public"
  location            = var.region
  resource_group_name = azurerm_resource_group.this.name
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public.id
  }
}

resource "azurerm_network_interface" "private" {
  name                = "${var.vnet_name}-nic-private"
  location            = var.region
  resource_group_name = azurerm_resource_group.this.name
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
    # UNCOMMENT FOR TRANSFORMATION:
    public_ip_address_id          = azurerm_public_ip.private.id   
  }
}

locals {
  cloud_init_feedback = <<EOT
#!/bin/bash
apt update
apt install -y python3-pip
pip3 install flask
cat <<PYEOF >/home/azureuser/app.py
from flask import Flask, request, render_template_string
app = Flask(__name__)
FEEDBACKS = []
VM_NAME = "{vm_name}"
@app.route("/", methods=['GET', 'POST'])
def home():
    if request.method == "POST":
        fb = request.form.get("feedback")
        if fb: FEEDBACKS.append(fb)
    return render_template_string('''
    <h2>Feedback Form</h2>
    <p style="font-weight:bold;color:blue;">You are visiting: <span style="font-size:larger;">{{vm_name}}</span></p>
    <form method="post">
      <input name="feedback" placeholder="Write your feedback" required>
      <button type="submit">Send</button>
    </form>
    <h3>Submitted feedback:</h3>
    <ul>{% for fb in feedbacks %}<li>{{fb}}</li>{% endfor %}</ul>
    ''', feedbacks=FEEDBACKS, vm_name=VM_NAME)
app.run(host="0.0.0.0", port=80)
PYEOF
nohup python3 /home/azureuser/app.py &
EOT
}

resource "azurerm_linux_virtual_machine" "public" {
  name                  = "${var.vnet_name}-publicvm"
  resource_group_name   = azurerm_resource_group.this.name
  location              = var.region
  size                  = "Standard_B1s"
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.public.id]
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_key
  }
  os_disk {
    caching                = "ReadWrite"
    storage_account_type   = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  custom_data = base64encode(replace(local.cloud_init_feedback, "{vm_name}", var.vm_name_public))
}

resource "azurerm_linux_virtual_machine" "private" {
  name                  = "${var.vnet_name}-privatevm"
  resource_group_name   = azurerm_resource_group.this.name
  location              = var.region
  size                  = "Standard_B1s"
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.private.id]
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_key
  }
  os_disk {
    caching                = "ReadWrite"
    storage_account_type   = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  custom_data = base64encode(replace(local.cloud_init_feedback, "{vm_name}", var.vm_name_private))
}

resource "azurerm_network_interface_security_group_association" "public" {
  network_interface_id      = azurerm_network_interface.public.id
  network_security_group_id = azurerm_network_security_group.web.id
}
resource "azurerm_network_interface_security_group_association" "private" {
  network_interface_id      = azurerm_network_interface.private.id
  network_security_group_id = azurerm_network_security_group.web.id
}