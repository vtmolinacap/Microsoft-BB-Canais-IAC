
resource "azurerm_virtual_machine" "vm" {
  name                  = "vm-suse"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [var.network_interface_id]
  size                  = var.vm_size
  os_profile {
    computer_name  = "vm-suse"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  storage_os_disk {
    name              = "osdisk-suse"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed           = true
    disk_size_gb      = 30
  }
  storage_image_reference {
    publisher = "SUSE"
    offer     = "SUSE-SLES"
    sku       = "12-SP5"
    version   = "latest"
  }
}

output "vm_id" {
  value = azurerm_virtual_machine.vm.id
}

output "vm_public_ip" {
  value = azurerm_public_ip.vm_ip.ip_address
}
    