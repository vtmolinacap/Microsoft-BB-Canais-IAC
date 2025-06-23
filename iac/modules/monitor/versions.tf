# Versionamento do módulo
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.0"
}

# Metadados do módulo
locals {
  module_version = "v1.0.0"
}