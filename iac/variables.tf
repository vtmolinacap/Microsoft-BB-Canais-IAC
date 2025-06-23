variable "admin_username" {
  description = "Nome de usuário administrador para as VMs"
  type        = string
  default     = "adminuser"

  validation {
    condition     = length(var.admin_username) >= 4 && length(var.admin_username) <= 20
    error_message = "O nome de usuário deve ter entre 4 e 20 caracteres."
  }
}

variable "trusted_ip" {
  description = "IP confiável para acesso SSH"
  type        = string
  default     = "YOUR_TRUSTED_IP/32"
  validation {
    condition     = can(cidrsubnet(var.trusted_ip, 0, 0))
    error_message = "O IP confiável deve ser um CIDR válido."
  }
}

variable "alert_email" {
  description = "Endereço de e-mail para notificações de alerta"
  type        = string
  default     = "admin@example.com"
}