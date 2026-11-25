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
  use_cli                    = true
}

data "azurerm_subscription" "current" {}

locals {
  multisite_tags = {
    Environment = "prod"
    Owner       = "finops-platform"
    CostCenter  = "CC-UK-GYMS"
    SiteID      = "LON-FLAGSHIP-01"
    ServiceTier = "member-booking-api"
  }
}

resource "azurerm_resource_group" "multisite_rg" {
  name     = "rg-finops-multisite-uk"
  location = "UK South"
  tags     = local.multisite_tags
}

resource "azurerm_virtual_network" "multisite_vnet" {
  name                = "vnet-finops-multisite-uk"
  address_space       = ["10.20.0.0/16"]
  location            = azurerm_resource_group.multisite_rg.location
  resource_group_name = azurerm_resource_group.multisite_rg.name
  tags                = local.multisite_tags
}

resource "azurerm_network_security_group" "pe_nsg" {
  name                = "nsg-snet-finops-pe-01"
  location            = azurerm_resource_group.multisite_rg.location
  resource_group_name = azurerm_resource_group.multisite_rg.name

  security_rule {
    name                       = "DenyAllInboundInternet"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  tags = local.multisite_tags
}

resource "azurerm_subnet" "storage_pe_subnet" {
  name                 = "snet-finops-pe-01"
  resource_group_name  = azurerm_resource_group.multisite_rg.name
  virtual_network_name = azurerm_virtual_network.multisite_vnet.name
  address_prefixes     = ["10.20.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "pe_subnet_nsg" {
  subnet_id                 = azurerm_subnet.storage_pe_subnet.id
  network_security_group_id = azurerm_network_security_group.pe_nsg.id
}

resource "azurerm_storage_account" "focus_exports" {
  #checkov:skip=CKV_AZURE_33:Queue service not used for FOCUS billing blob exports
  #checkov:skip=CKV2_AZURE_1:Platform-managed encryption (MMK) sufficient for non-PII billing exports
  name                            = "stfinopsfocusuk01"
  resource_group_name             = azurerm_resource_group.multisite_rg.name
  location                        = azurerm_resource_group.multisite_rg.location
  account_tier                    = "Standard"
  account_replication_type        = "GZRS"
  access_tier                     = "Cool"
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false

  sas_policy {
    expiration_period = "01.00:00:00"
  }

  blob_properties {
    delete_retention_policy {
      days = 30
    }
    container_delete_retention_policy {
      days = 30
    }
  }

  tags = local.multisite_tags
}

resource "azurerm_private_endpoint" "focus_storage_pe" {
  name                = "pe-st-finops-focus-uk-01"
  location            = azurerm_resource_group.multisite_rg.location
  resource_group_name = azurerm_resource_group.multisite_rg.name
  subnet_id           = azurerm_subnet.storage_pe_subnet.id

  private_service_connection {
    name                           = "psc-st-finops-focus-uk-01"
    private_connection_resource_id = azurerm_storage_account.focus_exports.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  tags = local.multisite_tags
}

resource "azurerm_storage_container" "focus_container" {
  #checkov:skip=CKV2_AZURE_21:Blob read logging handled via Storage Diagnostic Settings in central Log Analytics
  name                  = "focus-cost-exports"
  storage_account_name  = azurerm_storage_account.focus_exports.name
  container_access_type = "private"
}

resource "azurerm_storage_management_policy" "focus_retention" {
  storage_account_id = azurerm_storage_account.focus_exports.id

  rule {
    name    = "delete-focus-exports-after-90d"
    enabled = true
    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["focus-cost-exports/"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 90
      }
    }
  }
}

resource "azurerm_subscription_cost_management_export" "focus_daily" {
  name                         = "export-focus-daily-multisite"
  subscription_id              = data.azurerm_subscription.current.id
  recurrence_type              = "Daily"
  recurrence_period_start_date = "2026-12-01T00:00:00Z"
  recurrence_period_end_date   = "2027-12-01T00:00:00Z"

  export_data_storage_location {
    container_id     = azurerm_storage_container.focus_container.resource_manager_id
    root_folder_path = "/daily-focus"
  }

  export_data_options {
    type       = "ActualCost"
    time_frame = "MonthToDate"
  }
}
