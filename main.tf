



# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "australiasoutheast"
    resource_group_name = azurerm_resource_group.terraform_rg.name

    tags = {
        environment = "Terraform Demo"
        development = "true"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.terraform_rg.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes       = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = "australiasoutheast"
    resource_group_name          = azurerm_resource_group.terraform_rg.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "australiasoutheast"
    resource_group_name = azurerm_resource_group.terraform_rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "myNIC"
    location                  = "australiasoutheast"
    resource_group_name       = azurerm_resource_group.terraform_rg.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.myterraformnic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.terraform_rg.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.terraform_rg.name
    location                    = "australiasoutheast"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {

  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" { 
    value = tls_private_key.example_ssh.private_key_pem 
    sensitive = true
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
    name                  = "myVM"
    location              = "australiasoutheast"
    resource_group_name   = azurerm_resource_group.terraform_rg.name
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "myvm"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDIzjF1dUwLoMd9MrfBJTN15WKkjDCQ++Thd7ObvqhHLGNxptQkzr4oaqjwVb8vs1mDtaqsVDmeCDnMsvI50TBiO9pfFFs4SvyFBTGCJi6ybKGDN18/ndU8w5We8DN1jlYgAUXtDSARpl2GEuCtek/n1Bq7uZaXZ0m+FlaiD9XkPQxO7bvVcTZwQeOynSMIXoX/MxG6JMoe/xlR4xQXE8vgzaG9savAgQg91DZiB3Z1TB1A3pzcz8m6z0c+hzzcnUBhAVAycrDTPI8jT+45yEPPDq7FlhNZgDGa0MSf7hpfOr07ZISRg1RqNN+fCiWqswil9jIm1O2r2DYRN+zEf+3eK25xr7lZU8zqWoFVMbYN1b/zP2nbzFRl4jfgK5cI+4CWf4WInAv6Q/PiX0C8bTTSVyj8mIeQul+Z0Fo3yQvAAXvQ/NQTQNw6ONgZBQ+QYBCR9fMZOKd2jW0UY/fJkQksuyhn8C9xq5/drToj3H+SIrJ+M0JbBBcr0fFU94IKEFk= harsha@Harshas-MacBook-Pro-2.local"
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform Demo"
    }
}