# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "terraform_rg" {
    name     = "terraform-rg-1"
    location = "australiasoutheast"

    tags = {
        environment = "Terraform NP pipeline"
    }
}