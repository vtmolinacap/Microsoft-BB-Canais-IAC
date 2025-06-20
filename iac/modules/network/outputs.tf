output "nic_id" {
  description = "ID da interface de rede para a VM SUSE"
  value       = azurerm_network_interface.suse_nic.id
}

output "weblogic_nic_id" {
  description = "ID da interface de rede para a VM WebLogic"
  value       = azurerm_network_interface.weblogic_nic.id
}