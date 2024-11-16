provider "azurerm" {
  features {}
  subscription_id = "61f12577-4a11-4912-9c83-bfeee540b1f7"  # Replace with your subscription ID
}

# Resource Group
resource "azurerm_resource_group" "rg02" {
  location = "East US"
  name     = "rg02"
  tags = {
    env   = "dev"
    dep   = "finance"
    owner = "Swati"
    proj1 = "p1"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "vnet02" {
  location            = azurerm_resource_group.rg02.location
  resource_group_name = azurerm_resource_group.rg02.name
  name                = "Vnet02"
  address_space = [
    "192.168.0.0/19"  # 8192 addresses in total
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
  resource_group_name  = azurerm_resource_group.rg02.name
  virtual_network_name = azurerm_virtual_network.vnet02.name
  address_prefixes     = ["192.168.0.0/25"]  # 128 IPs (usable range: 192.168.0.1 - 192.168.0.126)
}

# Subnet 2 (For Windows 11 VM)
resource "azurerm_subnet" "subnet02" {
  name                 = "subnet02"
  resource_group_name  = azurerm_resource_group.rg02.name
  virtual_network_name = azurerm_virtual_network.vnet02.name
  address_prefixes     = ["192.168.0.128/25"]  # 128 IPs (usable range: 192.168.0.129 - 192.168.0.254)
}

# Subnet 3 (For future use or additional VMs)
resource "azurerm_subnet" "subnet03" {
  name                 = "subnet03"
  resource_group_name  = azurerm_resource_group.rg02.name
  virtual_network_name = azurerm_virtual_network.vnet02.name
  address_prefixes     = ["192.168.1.0/25"]  # 128 IPs
}

# Public IP for Linux VM
resource "azurerm_public_ip" "linux_public_ip" {
  name                = "linux-public-ip"
  resource_group_name = azurerm_resource_group.rg02.name
  location            = azurerm_resource_group.rg02.location
  allocation_method   = "Static"
}

# Public IP for Windows VM
resource "azurerm_public_ip" "win11_public_ip" {
  name                = "win11-public-ip"
  resource_group_name = azurerm_resource_group.rg02.name
  location            = azurerm_resource_group.rg02.location
  allocation_method   = "Static"
}

# Network Interface for Linux VM
resource "azurerm_network_interface" "nic_linux" {
  name                    = "nic-linux"
  location                = azurerm_resource_group.rg02.location
  resource_group_name     = azurerm_resource_group.rg02.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet01.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux_public_ip.id
  }
}

# Network Interface for Windows VM
resource "azurerm_network_interface" "nic_windows" {
  name                    = "nic-windows"
  location                = azurerm_resource_group.rg02.location
  resource_group_name     = azurerm_resource_group.rg02.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet02.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.win11_public_ip.id
  }
}

# Linux VM (Ubuntu)
resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                = "linuxVM"
  resource_group_name = azurerm_resource_group.rg02.name
  location            = azurerm_resource_group.rg02.location
  size                = "Standard_B1ms"
  admin_username      = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("../.ssh/authorized_keys")  # Ensure this points to your actual SSH public key file
  }

  network_interface_ids = [azurerm_network_interface.nic_linux.id]

  os_disk {
    name                    = "linux_os_disk"
    caching                 = "ReadWrite"
    disk_size_gb            = 30
    storage_account_type    = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }

  tags = {
    env   = "dev"
    dep   = "finance"
    owner = "Swati"
    proj1 = "p1"
  }
}

# Add 2GB Data Disk to Linux VM
resource "azurerm_managed_disk" "linux_data_disk" {
  name                 = "linux-data-disk"
  resource_group_name  = azurerm_resource_group.rg02.name
  location             = azurerm_resource_group.rg02.location
  storage_account_type = "Standard_LRS"
  disk_size_gb         = 2
  create_option        = "Empty"
}

resource "azurerm_virtual_machine_data_disk_attachment" "linux_data_disk_attach" {
  virtual_machine_id = azurerm_linux_virtual_machine.linux_vm.id
  managed_disk_id    = azurerm_managed_disk.linux_data_disk.id
  lun                 = 0
  caching             = "None"
}

# Windows VM (Windows 11)
resource "azurerm_windows_virtual_machine" "win11_vm" {
  name                = "win11VM"
  resource_group_name = azurerm_resource_group.rg02.name
  location            = azurerm_resource_group.rg02.location
  size                = "Standard_B1ms"
  admin_username      = "adminuser"
  admin_password      = "P@ssword123!"  # Replace with a secure password or use a secret management tool

  network_interface_ids = [azurerm_network_interface.nic_windows.id]

  os_disk {
    name                    = "win11_os_disk"
    caching                 = "ReadWrite"
    disk_size_gb            = 30
    storage_account_type    = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "21H2-pro"
    version   = "latest"
  }

  tags = {
    env   = "dev"
    dep   = "finance"
    owner = "Swati"
    proj1 = "p1"
  }
}

# Add 2GB Data Disk to Windows VM
resource "azurerm_managed_disk" "win11_data_disk" {
  name                 = "win11-data-disk"
  resource_group_name  = azurerm_resource_group.rg02.name
  location             = azurerm_resource_group.rg02.location
  storage_account_type = "Standard_LRS"
  disk_size_gb         = 2
  create_option        = "Empty"
}

resource "azurerm_virtual_machine_data_disk_attachment" "win11_data_disk_attach" {
  virtual_machine_id = azurerm_windows_virtual_machine.win11_vm.id
  managed_disk_id    = azurerm_managed_disk.win11_data_disk.id
  lun                 = 0
  caching             = "None"
}
