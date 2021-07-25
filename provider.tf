# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
  backend "azurerm" {
    resource_group_name = "tstate"
    storage_account_name = "harsha1985storageaccount"
    container_name = "devopscontainer"
  }
}
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

