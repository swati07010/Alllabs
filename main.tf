# provider "azurerm"{
#     features{}
#     subscription_id = "61f12577-4a11-4912-9c83-bfeee540b1f7"
# }
# resource "azurerm_resoucre_group" "rg01"{
#     location = "East US"
#     name = "rg01"
#     tags = {
#         env = "dev"
#         dep = "finance"
#         owner = "Swati"
#         proj = "p1"
#     }
# }
# resource "azurerm_virtual_network" "vnet01"{
#     location = azurerm_resource_group.rg01.location
#     resource_group_name = azurerm_resource_group.rg01.name
#     name = "Vnet01"
#     address_space = ["10.10.0.0/16"]
#     tags = {
#         env = "dev"
#         dep = "finance"
#         owner = "Swati"
#         proj = "p1"
#     }
# }

# Provider configuration

# provider "azurerm" {  # declaring the cloud provider
#   features {}
#   subscription_id = "61f12577-4a11-4912-9c83-bfeee540b1f7"
# }
 
# resource "azurerm_resource_group" "rg01" {  # creating a new resource group
#   location = "East US"
#   name = "rg01"
#   tags = {
#     env = "dev"
#     dep = "finance"
#     owner = "Swati"
#     proj1 = "p1"
#   }
# }
# resource "azurerm_virtual_network" "vnet-01" {  # here resource is vnet
#   location = azurerm_resource_group.rg01.location
#   resource_group_name = azurerm_resource_group.rg01.name
#   name = "Vnet01"
#   address_space = ["10.10.0.0/16"]  # we can add multiple address spaces 10.20.1.0/24","10.20.2.0/24
#   tags = {
#     env = "dev"
#     dep = "finance"
#     owner = "Swati"
#     proj1 = "p1"
# }
# }


provider "azurerm" {  # declaring the cloud provider
  features {}
  subscription_id = "61f12577-4a11-4912-9c83-bfeee540b1f7"  # Optional if you have 'az login' configured
}

resource "azurerm_resource_group" "rg01" {  # creating a new resource group
  location = "East US"
  name     = "rg01"
  tags = {
    env   = "dev"
    dep   = "finance"
    owner = "Swati"
    proj1 = "p1"
  }
}

resource "azurerm_virtual_network" "vnet01" {  # defining the virtual network
  location            = azurerm_resource_group.rg01.location
  resource_group_name = azurerm_resource_group.rg01.name
  name                = "Vnet01"
  # Multiple address spaces can be defined here
  address_space = [
    "10.10.0.0/16",
    "10.20.1.0/24",  # Additional address space
    "10.20.2.0/24"   # Additional address space
  ]
  tags = {
    env   = "dev"
    dep   = "finance"
    owner = "Swati"
    proj1 = "p1"
  }
}
# Subnet 1
resource "azurerm_subnet" "subnet01" {
  name                 = "subnet01"
  resource_group_name  = azurerm_resource_group.rg01.name
  virtual_network_name = azurerm_virtual_network.vnet01.name
  address_prefixes     = ["10.20.1.0/25"]  # First subnet, using part of 10.20.1.0/24
}

# Subnet 2
resource "azurerm_subnet" "subnet02" {
  name                 = "subnet02"
  resource_group_name  = azurerm_resource_group.rg01.name
  virtual_network_name = azurerm_virtual_network.vnet01.name
  address_prefixes     = ["10.20.1.128/25"]  # Second subnet, using the remaining part of 10.20.1.0/24
}
