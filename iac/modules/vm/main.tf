resource "azurerm_linux_virtual_machine" "vm" {
  name                  = var.vm_name
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.vm_size
  network_interface_ids = [var.nic_id]

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  os_disk {
    name                   = "${var.vm_name}-osdisk"
    caching                = "ReadWrite"
    storage_account_type   = "Standard_LRS"
    disk_size_gb           = 30
    disk_encryption_set_id = var.disk_encryption_set_id
  }

  admin_username = var.admin_username
  admin_password = var.admin_password

  disable_password_authentication = false

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = var.environment
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
}