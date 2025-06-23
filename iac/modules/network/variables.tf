variable "location" {
  description = "Localização dos recursos de rede"
  type        = string
  validation {
    condition     = contains(["eastus", "westus", "northeurope"], var.location)
    error_message = "A localização deve ser uma região válida do Azure (ex.: eastus, westus, northeurope)."
  }
}

variable "resource_group_name" {
  description = "Nome do grupo de recursos"
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

variable "address_space" {
  description = "Espaço de endereços para a VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
  validation {
    condition     = alltrue([for cidr in var.address_space : can(cidrsubnet(cidr, 0, 0))])
    error_message = "O endereço CIDR fornecido é inválido."
  }
}

variable "subnet_prefixes" {
  description = "Prefixos das sub-redes"
  type        = map(list(string))
  default     = {
    suse      = ["10.0.1.0/24"]
    weblogic  = ["10.0.2.0/24"]
    firewall  = ["10.0.3.0/24"]
    endpoints = ["10.0.4.0/24"]
  }
  validation {
    condition     = alltrue([for k, prefixes in var.subnet_prefixes : alltrue([for cidr in prefixes : can(cidrsubnet(cidr, 0, 0))])])
    error_message = "Os prefixos das sub-redes são inválidos."
  }
}

variable "trusted_ip" {
  description = "IP confiável para acesso SSH"
  type        = string
  validation {
    condition     = can(cidrsubnet(var.trusted_ip, 0, 0))
    error_message = "O IP confiável deve ser um CIDR válido."
  }
}

variable "log_analytics_workspace_id" {
  description = "ID do workspace do Log Analytics"
  type        = string
}

variable "storage_account_id" {
  description = "ID do storage account para Terraform state"
  type        = string
}