# Definindo o grupo de recursos
resource "azurerm_resource_group" "rg" {
  name     = "rg-suseweblogic-prod-eastus"
  location = "eastus"
  tags = {
    environment = "prod"
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
}

# Azure Key Vault
resource "azurerm_key_vault" "kv" {
  name                        = "kvsuseweblogicprod"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  tags = {
    environment = "prod"
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
}

# Permissões de acesso ao Key Vault
resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "Set",
    "List",
    "Delete",
    "Purge"
  ]

  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey",
    "Create",
    "Delete"
  ]
}

# Chave para Disk Encryption
resource "azurerm_key_vault_key" "des_key" {
  name         = "des-key"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "verify",
    "wrapKey",
    "unwrapKey"
  ]
}

# Senha gerada para o administrador
resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "!@#$%^&*"
}

# Armazenar senha no Key Vault
resource "azurerm_key_vault_secret" "admin_password" {
  name         = "vm-admin-password"
  value        = random_password.admin_password.result
  key_vault_id = azurerm_key_vault.kv.id
}

# Dados do cliente para Key Vault
data "azurerm_client_config" "current" {}

# Módulo para a VM SUSE
module "suse_vm" {
  source                 = "./modules/vm"
  vm_name                = "vm-suse-prod-eastus"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  vm_size                = "Standard_B1ms"
  admin_username         = var.admin_username
  admin_password         = azurerm_key_vault_secret.admin_password.value
  nic_id                 = module.network.nic_id
  image_publisher        = "SUSE"
  image_offer            = "sles-15-sp5"
  image_sku              = "gen2"
  image_version          = "2024.01.01"
  environment            = "prod"
  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}

# Módulo para a VM WebLogic
module "weblogic_vm" {
  source                 = "./modules/vm"
  vm_name                = "vm-weblogic-prod-eastus"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  vm_size                = "Standard_D2s_v3"
  admin_username         = var.admin_username
  admin_password         = azurerm_key_vault_secret.admin_password.value
  nic_id                 = module.network.weblogic_nic_id
  image_publisher        = "Oracle"
  image_offer            = "weblogic-server"
  image_sku              = "weblogic-12"
  image_version          = "2024.01.01"
  environment            = "prod"
  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
}

# Módulo de rede
module "network" {
  source                     = "./modules/network"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  environment                = "prod"
  trusted_ip                 = var.trusted_ip
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
  storage_account_id         = azurerm_storage_account.tfstate.id
}

# Workspace do Log Analytics
resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "log-suseweblogic-prod-eastus"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 90
  tags = {
    environment = "prod"
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
}

# Módulo de monitoramento para VM SUSE
module "suse_monitor" {
  source                     = "./modules/monitor"
  resource_group_name        = azurerm_resource_group.rg.name
  virtual_machine_id         = module.suse_vm.vm_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
  environment                = "prod"
  alert_email                = var.alert_email
}

# Módulo de monitoramento para VM WebLogic
module "weblogic_monitor" {
  source                     = "./modules/monitor"
  resource_group_name        = azurerm_resource_group.rg.name
  virtual_machine_id         = module.weblogic_vm.vm_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
  environment                = "prod"
  alert_email                = var.alert_email
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

# Azure Disk Encryption Set
resource "azurerm_disk_encryption_set" "des" {
  name                = "des-prod-eastus"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  identity {
    type = "SystemAssigned"
  }

  encryption_type = "EncryptionAtRestWithCustomerKey"
  key_vault_key_id = azurerm_key_vault_key.des_key.id

  tags = {
    environment = "prod"
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
}

resource "azurerm_key_vault_access_policy" "des_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_disk_encryption_set.des.identity[0].principal_id

  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey"
  ]
}

# Azure Blob Storage para Terraform State
resource "azurerm_storage_account" "tfstate" {
  name                     = "tfsuseweblogicprod"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "prod"
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

# Azure Cost Management Alert
resource "azurerm_cost_anomaly_alert" "cost_alert" {
  name            = "cost-alert-prod-eastus"
  display_name    = "Alerta de Anomalia de Custo"
  email_subject   = "Alerta de Anomalia de Custo no Projeto SUSE-WebLogic"
  email_addresses = [var.alert_email]
}

# Azure Backup
resource "azurerm_recovery_services_vault" "vault" {
  name                = "vault-prod-eastus"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  tags = {
    environment = "prod"
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
}

resource "azurerm_backup_policy_vm" "policy" {
  name                = "policy-prod-eastus"
  resource_group_name = azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 7
  }
}

resource "azurerm_backup_protected_vm" "suse_backup" {
  resource_group_name = azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  source_vm_id        = module.suse_vm.vm_id
  backup_policy_id    = azurerm_backup_policy_vm.policy.id
}

resource "azurerm_backup_protected_vm" "weblogic_backup" {
  resource_group_name = azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  source_vm_id        = module.weblogic_vm.vm_id
  backup_policy_id    = azurerm_backup_policy_vm.policy.id
}

# Application Insights para WebLogic
resource "azurerm_application_insights" "app_insights" {
  name                = "appinsights-prod-eastus"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "java"
  retention_in_days   = 90
  sampling_percentage = 100

  tags = {
    environment = "prod"
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
}

# Custom Script Extension para configurar WebLogic
resource "azurerm_virtual_machine_extension" "weblogic_setup" {
  name                 = "weblogic-setup-prod-eastus"
  virtual_machine_id   = module.weblogic_vm.vm_id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = jsonencode({
    "commandToExecute" = <<EOF
    #!/bin/bash
    # Instalar agente do Application Insights
    wget https://dc.services.visualstudio.com/agents/applicationinsights-linux.zip
    unzip applicationinsights-linux.zip -d /opt/appinsights
    /opt/appinsights/install.sh ${azurerm_application_insights.app_insights.instrumentation_key}
    # Configuração básica do WebLogic
    sudo mkdir -p /u01/app/oracle
    sudo chown -R oracle:oracle /u01/app/oracle
    sudo -u oracle /u01/app/oracle/product/12.2.1.4.0/wlserver/server/bin/setWLSEnv.sh
    # Criar domínio padrão
    sudo -u oracle /u01/app/oracle/product/12.2.1.4.0/wlserver/common/bin/config.sh -mode=console <<CONFIG
    1
    1
    /u01/app/oracle/user_projects/domains/base_domain
    weblogic
    ${azurerm_key_vault_secret.admin_password.value}
    ${azurerm_key_vault_secret.admin_password.value}
    7001
    CONFIG
    # Iniciar servidor
    sudo -u oracle /u01/app/oracle/user_projects/domains/base_domain/bin/startWebLogic.sh
    EOF
  })

  tags = {
    environment = "prod"
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
}

# Private Endpoint para Storage
resource "azurerm_private_endpoint" "storage" {
  name                = "pe-storage-prod-eastus"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = module.network.endpoints_subnet_id

  private_service_connection {
    name                           = "storage-connection"
    private_connection_resource_id = azurerm_storage_account.tfstate.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  tags = {
    environment = "prod"
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
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

output "key_vault_id" {
  description = "ID do Azure Key Vault"
  value       = azurerm_key_vault.kv.id
}

output "app_insights_instrumentation_key" {
  description = "Chave de instrumentação do Application Insights"
  value       = azurerm_application_insights.app_insights.instrumentation_key
  sensitive   = true
}