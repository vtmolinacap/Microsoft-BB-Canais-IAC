variable "admin_username" {
  description = "Nome de usuário administrador para as VMs"
  type        = string
  default     = "adminuser"
}

variable "admin_password" {
  description = "Senha do administrador para as VMs"
  type        = string
  sensitive   = true
}