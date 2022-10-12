terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "foodaddictstate"
    container_name       = "devstate"
    key                  = "devstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

locals {
  resource_group_name = "${var.short_location}-${var.project_name}-rg"
  apim_name           = "${var.short_location}-${var.project_name}-apim"

  function_app_storage_name = "${var.short_location}foodaddictfappstg"
  function_app_service_name = "${var.short_location}-${var.project_name}-fapp-service"
  function_app_name         = "${var.short_location}-${var.project_name}-fapp"
}

resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
}

resource "azurerm_api_management" "apim" {
  name                = local.apim_name
  location            = var.location
  resource_group_name = resource.azurerm_resource_group.rg.name
  publisher_name      = var.project_name
  publisher_email     = "${var.project_name}@gmail.com"

  sku_name = "Consumption_0"
}

resource "azurerm_api_management_api" "foodaddict_api" {
  name                = "FoodAddict"
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "FoodAddict"
  path                = "app"
  protocols           = ["https"]

  import {
    content_format = "openapi"
    content_value  = file("../api_specification/app.yml")
  }
}


resource "azurerm_storage_account" "stg" {
  name                     = local.function_app_storage_name
  resource_group_name      = resource.azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "plan" {
  name                = local.function_app_service_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "fapp" {
  name                = local.function_app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  storage_account_name       = azurerm_storage_account.stg.name
  storage_account_access_key = azurerm_storage_account.stg.primary_access_key
  service_plan_id            = azurerm_service_plan.plan.id

  site_config {}
}
