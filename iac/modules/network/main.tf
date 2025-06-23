resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-suseweblogic-prod-eastus"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  tags = {
    environment = var.environment
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
}

resource "azurerm_subnet" "suse_subnet" {
  name                 = "subnet-suse-prod-eastus"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_prefixes["suse"]
}

resource "azurerm_subnet" "weblogic_subnet" {
  name                 = "subnet-weblogic-prod-eastus"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_prefixes["weblogic"]
}

resource "azurerm_subnet" "firewall_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_prefixes["firewall"]
}

resource "azurerm_subnet" "endpoints_subnet" {
  name                 = "subnet-endpoints-prod-eastus"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_prefixes["endpoints"]
}

resource "azurerm_public_ip" "suse_pip" {
  name                = "pip-suse-prod-eastus"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = var.environment
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
}

resource "azurerm_public_ip" "weblogic_pip" {
  name                = "pip-weblogic-prod-eastus"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = var.environment
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
}

resource "azurerm_public_ip" "firewall_pip" {
  name                = "pip-firewall-prod-eastus"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = var.environment
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
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
    source_address_prefix      = var.trusted_ip
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
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
}

resource "azurerm_network_interface" "suse_nic" {
  name                = "nic-suse-prod-eastus"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.suse_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.suse_pip.id
  }

  tags = {
    environment = var.environment
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
}

resource "azurerm_network_interface" "weblogic_nic" {
  name                = "nic-weblogic-prod-eastus"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.weblogic_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.weblogic_pip.id
  }

  tags = {
    environment = var.environment
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
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

resource "azurerm_firewall" "firewall" {
  name                = "fw-prod-eastus"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.firewall_pip.id
  }

  tags = {
    environment = var.environment
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
}

resource "azurerm_network_watcher" "watcher" {
  name                = "network-watcher-prod-eastus"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = {
    environment = var.environment
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
}

resource "azurerm_private_endpoint" "log_analytics" {
  name                = "pe-loganalytics-prod-eastus"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = azurerm_subnet.endpoints_subnet.id

  private_service_connection {
    name                           = "loganalytics-connection"
    private_connection_resource_id = var.log_analytics_workspace_id
    subresource_names              = ["azuremonitor"]
    is_manual_connection           = false
  }

  tags = {
    environment = var.environment
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
}