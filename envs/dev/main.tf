terraform {
  required_version = ">= 1.8.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
  }
}

provider "azurerm" {
  features {}
}

module "platform" {
  source = "../../modules/platform"

  environment = "dev"
  location    = var.location
  name_prefix = var.name_prefix
}
