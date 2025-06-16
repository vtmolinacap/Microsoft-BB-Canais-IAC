
variable "resource_group_name" {
  description = "Nome do grupo de recursos"
  type        = string
}

variable "location" {
  description = "Localização do recurso"
  type        = string
}

variable "admin_username" {
  description = "Nome de usuário administrador da VM"
  type        = string
}

variable "admin_password" {
  description = "Senha do usuário administrador da VM"
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "Tamanho da VM"
  type        = string
  default     = "Standard_B1ms"
}
    