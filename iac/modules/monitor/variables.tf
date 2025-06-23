variable "resource_group_name" {
  description = "Nome do grupo de recursos"
  type        = string
}

variable "virtual_machine_id" {
  description = "ID da máquina virtual"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "ID do workspace do Log Analytics"
  type        = string
}

variable "environment" {
  description = "Ambiente (ex.: prod, dev)"
  type        = string
  validation {
    condition     = contains(["prod", "dev", "staging"], var.environment)
    error_message = "O ambiente deve ser prod, dev ou staging."
  }
}

variable "alert_email" {
  description = "Endereço de e-mail para notificações de alerta"
  type        = string
}