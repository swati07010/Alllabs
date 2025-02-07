provider "azurerm" {
  features {}
  subscription_id = "61f12577-4a11-4912-9c83-bfeee540b1f7"  # Optional if 'az login' is configured
}

# Resource Group
resource "azurerm_resource_group" "rg01" {
  location = "East US"
  name     = "rg01"
  tags = {
    env   = "dev"
    dep   = "finance"
    owner = "Swati"
    proj1 = "p1"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "vnet01" {
  location            = azurerm_resource_group.rg01.location
  resource_group_name = azurerm_resource_group.rg01.name
  name                = "Vnet01"
  address_space = [
    "192.168.0.0/19"
  ]
  tags = {
    env   = "dev"
    dep   = "finance"
    owner = "Swati"
    proj1 = "p1"
  }
}

# Subnet 1 (For Linux VM)
resource "azurerm_subnet" "subnet01" {
  name                 = "subnet01"
  resource_group_name  = azurerm_resource_group.rg01.name
  virtual_network_name = azurerm_virtual_network.vnet01.name
  address_prefixes     = ["192.168.0.0/25"]  # First subnet, using part of 192.168.0.0/19
}

# Subnet 2 (For Windows 11 VM)
resource "azurerm_subnet" "subnet02" {
  name                 = "subnet02"
  resource_group_name  = azurerm_resource_group.rg01.name
  virtual_network_name = azurerm_virtual_network.vnet01.name
  address_prefixes     = ["192.168.0.128/25"]  # Second subnet, using the remaining part of 192.168.0.0/19
}

# Subnet 3 (For possible future use or other VMs)
resource "azurerm_subnet" "subnet03" {
  name                 = "subnet03"
  resource_group_name  = azurerm_resource_group.rg01.name
  virtual_network_name = azurerm_virtual_network.vnet01.name
  address_prefixes     = ["192.168.1.0/25"]  # Third subnet
}

# Linux VM (Ubuntu)
