resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-suseweblogic-prod-eastus"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = var.environment
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-suseweblogic-prod-eastus"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "suse_pip" {
  name                = "pip-suse-prod-eastus"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"

  tags = {
    environment = var.environment
  }
}

resource "azurerm_public_ip" "weblogic_pip" {
  name                = "pip-weblogic-prod-eastus"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"

  tags = {
    environment = var.environment
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-suseweblogic-prod-eastus"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowWebLogic"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "7001"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
  }
}

resource "azurerm_network_interface" "suse_nic" {
  name                = "nic-suse-prod-eastus"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.suse_pip.id
  }

  tags = {
    environment = var.environment
  }
}

resource "azurerm_network_interface" "weblogic_nic" {
  name                = "nic-weblogic-prod-eastus"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.weblogic_pip.id
  }

  tags = {
    environment = var.environment
  }
}

resource "azurerm_network_interface_security_group_association" "suse_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.suse_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface_security_group_association" "weblogic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.weblogic_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
