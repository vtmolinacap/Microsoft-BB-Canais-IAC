# Definindo o grupo de recursos
resource "azurerm_resource_group" "rg" {
  name     = "rg-suseweblogic-prod-eastus"
  location = "eastus"
}

# Módulo para a VM SUSE
module "suse_vm" {
  source              = "./modules/vm"
  vm_name             = "vm-suse-prod-eastus"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vm_size             = "Standard_B1ms"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  nic_id              = module.network.nic_id
  image_publisher     = "SUSE"
  image_offer         = "sles-15-sp5"
  image_sku           = "gen2"
  image_version       = "2024.01.01" # Versão fixa para consistência
  environment         = "prod"
}

# Módulo para a VM WebLogic
module "weblogic_vm" {
  source              = "./modules/vm"
  vm_name             = "vm-weblogic-prod-eastus"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vm_size             = "Standard_D2s_v3" # Maior para WebLogic
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  nic_id              = module.network.weblogic_nic_id
  image_publisher     = "Oracle"
  image_offer         = "weblogic-server"
  image_sku           = "weblogic-12"
  image_version       = "latest"
  environment         = "prod"
}

# Módulo de rede
module "network" {
  source              = "./modules/network"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  environment         = "prod"
}

# Workspace do Log Analytics
resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "log-suseweblogic-prod-eastus"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Módulo de monitoramento para VM SUSE
module "suse_monitor" {
  source                     = "./modules/monitor"
  resource_group_name        = azurerm_resource_group.rg.name
  virtual_machine_id         = module.suse_vm.vm_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
  environment                = "prod"
}

# Módulo de monitoramento para VM WebLogic
module "weblogic_monitor" {
  source                     = "./modules/monitor"
  resource_group_name        = azurerm_resource_group.rg.name
  virtual_machine_id         = module.weblogic_vm.vm_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
  environment                = "prod"
}

# Módulo de dashboard para VM SUSE
module "suse_dashboard" {
  source              = "./modules/dashboard"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_machine_id  = module.suse_vm.vm_id
  nic_id              = module.network.nic_id
  environment         = "prod"
}

# Módulo de dashboard para VM WebLogic
module "weblogic_dashboard" {
  source              = "./modules/dashboard"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_machine_id  = module.weblogic_vm.vm_id
  nic_id              = module.network.weblogic_nic_id
  environment         = "prod"
}

# Outputs
output "suse_vm_id" {
  description = "ID da máquina virtual SUSE"
  value       = module.suse_vm.vm_id
}

output "weblogic_vm_id" {
  description = "ID da máquina virtual WebLogic"
  value       = module.weblogic_vm.vm_id
}