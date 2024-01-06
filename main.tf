terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

# random id of 8 characters with only lowercase letters
resource "random_integer" "random" {
    min = 1
    max = 50000000
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "100DaysDevOps2"
  location = "westeurope"
}

# create a storage account with a random name
resource "azurerm_storage_account" "storage" {
  name                     = "100daysdevops${random_integer.random.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  static_website {
    index_document = "index.html"
    error_404_document = "index.html"
  }
}

# create an azure CDN with endpoint pointing to the storage account
resource "azurerm_cdn_profile" "cdn" {
  name                = "100daysdevops${random_integer.random.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard_Microsoft"
  
}

resource "azurerm_cdn_endpoint" "endpoint" {
  name                = "100daysdevops${random_integer.random.result}"
  profile_name        = azurerm_cdn_profile.cdn.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  origin {
    name      = azurerm_storage_account.storage.name
    host_name = azurerm_storage_account.storage.primary_web_host
  }
}
