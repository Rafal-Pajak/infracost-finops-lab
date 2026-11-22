terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
  use_cli                    = false
}

locals {
  common_tags = {
    Environment = "prod"
    Owner       = "platform-team"
    CostCenter  = "CC-4100"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-finops-prod-weu"
  location = "West Europe"
  tags     = local.common_tags
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-app-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/default"
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.common_tags
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "vm-app-prod-01"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_D2s_v5"
  admin_username                  = "azureuser"
  disable_password_authentication = true
  allow_extension_operations      = false
  network_interface_ids           = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl lab@finops"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 64
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = local.common_tags
}

resource "azurerm_key_vault" "core_kv" {
  name                            = "kv-finops-dora-prod-01"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  tenant_id                       = "00000000-0000-0000-0000-000000000000"
  sku_name                        = "standard"
  purge_protection_enabled        = true
  soft_delete_retention_days      = 90
  enabled_for_disk_encryption     = true
  enable_rbac_authorization       = true
  public_network_access_enabled   = false

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = local.common_tags
}

resource "azurerm_private_endpoint" "kv_pe" {
  name                = "pe-kv-finops-dora-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/default"

  private_service_connection {
    name                           = "psc-kv-finops-dora-01"
    private_connection_resource_id = azurerm_key_vault.core_kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  tags = local.common_tags
}
