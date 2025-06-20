variable "vm_name" {
  description = "Nome da máquina virtual"
  type        = string
}

variable "resource_group_name" {
  description = "Nome do grupo de recursos"
  type        = string
}

variable "location" {
  description = "Localização da VM"
  type        = string
}

variable "vm_size" {
  description = "Tamanho da VM"
  type        = string
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
}

variable "environment" {
  description = "Ambiente (ex.: prod, dev)"
  type        = string
}