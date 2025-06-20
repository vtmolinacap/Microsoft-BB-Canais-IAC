variable "resource_group_name" {
  description = "Nome do grupo de recursos"
  type        = string
}

variable "virtual_machine_id" {
  description = "ID da máquina virtual"
  type        = string
}

variable "nic_id" {
  description = "ID da interface de rede"
  type        = string
}

variable "environment" {
  description = "Ambiente (ex.: prod, dev)"
  type        = string
}

variable "time_range_ms" {
  description = "Intervalo de tempo do dashboard em milissegundos"
  type        = number
  default     = 3600000 # 1 hora
}