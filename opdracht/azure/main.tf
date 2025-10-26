terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  skip_provider_registration = true
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = [var.vnet_address_space]
  location            = var.location # Changed
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_address_prefix]
}

resource "azurerm_public_ip" "pip" {
  count               = var.vm_count
  name                = "${var.vm_name_prefix}-pip-${count.index}"
  location            = var.location # Changed
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "${var.vm_name_prefix}-nic-${count.index}"
  location            = var.location # Changed
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[count.index].id
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.vm_name_prefix}-nsg"
  location            = var.location # Changed
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*" # Allow web traffic from anywhere
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Read the cloud-init template
data "template_file" "cloudinit_azure" {
  template = file("${path.module}/cloudinit.yaml")

  vars = {
    # Changed to read from a local file
    ssh_key  = var.ssh_public_key_path
    username = var.admin_username
    #private_key = file(pathexpand("~/.ssh/id_rsa_azure"))
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.vm_count
  name                = "${var.vm_name_prefix}-${count.index}"
  location            = var.location # Changed
  resource_group_name = data.azurerm_resource_group.rg.name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # Pass the cloud-init script
  custom_data = base64encode(data.template_file.cloudinit_azure.rendered)

  disable_password_authentication = true
}

locals {
  azure_inventory_content = templatefile("${path.module}/inventory.tpl", {
    vms_pip = azurerm_public_ip.pip
    prefix  = var.vm_name_prefix
    user    = var.admin_username
  })

  existing_inventory_content = fileexists("../ansible/inventory.ini") ? file("../ansible/inventory.ini") : ""
}
# Append the Azure VM IPs to the Ansible inventory file
resource "local_file" "ansible_inventory_azure" {
  content = templatefile("${path.module}/inventory.tpl", {
    vms_pip = azurerm_public_ip.pip
    prefix  = var.vm_name_prefix
    user    = var.admin_username
  })
  filename        = "../ansible/inventory.ini"
  file_permission = "0644"
  depends_on = [
    azurerm_linux_virtual_machine.vm
  ]
}

#123