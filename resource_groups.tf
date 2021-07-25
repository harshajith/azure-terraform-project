# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "RG-non-prod-engineering" {
    name     = "RG-non-prod-engineering"
    location = "australiasoutheast"

    tags = {
        environment = "Terraform NP pipeline"
    }
}