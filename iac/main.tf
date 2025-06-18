resource "azurerm_resource_group" "rg" {
  name     = "rg-suse-vm"
  location = "eastus"
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "example-suse-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  vm_size               = "Standard_B1ms"  # Tamanho da VM
  network_interface_ids = [module.network.nic_id]  # Referência à interface de rede do módulo

storage_image_reference {
  publisher = "SUSE"
  offer     = "sles-15-sp5"  # ou a versão que deseja
  sku       = "gen2"
  version   = "latest"
}
  storage_os_disk {
    name           = "os-disk"
    caching        = "ReadWrite"
    create_option  = "FromImage"
    disk_size_gb   = 30  # Tamanho do disco
  }

  os_profile {
    computer_name  = "example-suse-vm"
    admin_username = "adminuser"
    admin_password = "P@ssw0rd1234"  # Exemplo de senha
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "production"
  }
}

module "network" {
  source                = "./modules/network"
  location             = azurerm_resource_group.rg.location  # Passando a localização do grupo de recursos
  resource_group_name  = azurerm_resource_group.rg.name     # Passando o nome do grupo de recursos
}

resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "example-log-analytics"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

module "monitor" {
  source                     = "./modules/monitor"
  resource_group             = azurerm_resource_group.rg
  virtual_machine            = azurerm_virtual_machine.vm
  log_analytics_workspace    = azurerm_log_analytics_workspace.workspace
}

module "dashboard" {
  source          = "./modules/dashboard"
  resource_group  = azurerm_resource_group.rg
  virtual_machine = azurerm_virtual_machine.vm
}

output "vm_id" {
  description = "ID da máquina virtual"
  value       = azurerm_virtual_machine.vm.id
}

