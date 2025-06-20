variable "location" {
  description = "Localização dos recursos de rede"
  type        = string
}

variable "resource_group_name" {
  description = "Nome do grupo de recursos"
  type        = string
}

variable "environment" {
  description = "Ambiente (ex.: prod, dev)"
  type        = string
}