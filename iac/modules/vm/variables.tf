variable "vm_name" {
  description = "Nome da máquina virtual"
  type        = string
  validation {
    condition     = length(var.vm_name) >= 1 && length(var.vm_name) <= 64
    error_message = "O nome da VM deve ter entre 1 e 64 caracteres."
  }
}

variable "resource_group_name" {
  description = "Nome do grupo de recursos"
  type        = string
}

variable "location" {
  description = "Localização da VM"
  type        = string
  validation {
    condition     = contains(["eastus", "westus", "northeurope"], var.location)
    error_message = "A localização deve ser uma região válida do Azure (ex.: eastus, westus, northeurope)."
  }
}

variable "vm_size" {
  description = "Tamanho da VM"
  type        = string
  validation {
    condition     = contains(["Standard_B1ms", "Standard_D2s_v3"], var.vm_size)
    error_message = "O tamanho da VM deve ser válido (ex.: Standard_B1ms, Standard_D2s_v3)."
  }
}

variable "admin_username" {
  description = "Nome de usuário administrador"
  type        = string
}

variable "admin_password" {
  description = "Senha do administrador"
  type        = string
  sensitive   = true
}

variable "nic_id" {
  description = "ID da interface de rede"
  type        = string
}

variable "image_publisher" {
  description = "Publicador da imagem"
  type        = string
  validation {
    condition     = contains(["SUSE", "Oracle"], var.image_publisher)
    error_message = "O publicador deve ser SUSE ou Oracle."
  }
}

variable "image_offer" {
  description = "Oferta da imagem"
  type        = string
}

variable "image_sku" {
  description = "SKU da imagem"
  type        = string
}

variable "image_version" {
  description = "Versão da imagem"
  type        = string
  validation {
    condition     = var.image_version == "latest" || can(regex("^[0-9]{4}\\.[0-9]{2}\\.[0-9]{2}$", var.image_version))
    error_message = "A versão da imagem deve ser 'latest' ou no formato 'YYYY.MM.DD'."
  }
}

variable "environment" {
  description = "Ambiente (ex.: prod, dev)"
  type        = string
  validation {
    condition     = contains(["prod", "dev", "staging"], var.environment)
    error_message = "O ambiente deve ser prod, dev ou staging."
  }
}

variable "disk_encryption_set_id" {
  description = "ID do Disk Encryption Set"
  type        = string
}