terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"  # Defina a versão que você deseja usar
    }
  }

  required_version = ">= 1.0"  # Certifique-se de que você está usando uma versão do Terraform compatível
}

provider "azurerm" {
  features {}
}