terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}


# Create a resource group
resource "azurerm_resource_group" "gitbucket" {
  name     = "gitbucket"
  location = "West Europe"

}

resource "azurerm_postgresql_server" "gitbucket" {
  name                = "postgresql-gitbucket"
  location            = azurerm_resource_group.gitbucket.location
  resource_group_name = azurerm_resource_group.gitbucket.name

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = var.db_user
  administrator_login_password = var.db_password
  version                      = "11"
  ssl_enforcement_enabled      = true
}

# Create a database
resource "azurerm_postgresql_database" "gitbucket" {
  name                = "gitbucket"
  resource_group_name = azurerm_resource_group.gitbucket.name
  server_name         = azurerm_postgresql_server.gitbucket.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_firewall_rule" "gitbucket" {
  count               = length(var.outbound_ip_address_list)
  name                = count.index
  resource_group_name = azurerm_resource_group.gitbucket.name
  server_name         = azurerm_postgresql_server.gitbucket.name
  start_ip_address    = element(var.outbound_ip_address_list, count.index)
  end_ip_address      = element(var.outbound_ip_address_list, count.index)
}


resource "azurerm_service_plan" "gitbucket" {
  name                = "gitbucket-appserviceplan"
  location            = azurerm_resource_group.gitbucket.location
  resource_group_name = azurerm_resource_group.gitbucket.name
  os_type             = "Linux"
  sku_name            = "B1"
}


resource "azurerm_linux_web_app" "gitbucket" {
  name                = "gitbucket"
  location            = azurerm_resource_group.gitbucket.location
  resource_group_name = azurerm_resource_group.gitbucket.name
  service_plan_id     = azurerm_service_plan.gitbucket.id

  site_config {
    application_stack {
      java_server  = "TOMCAT"
      java_version = "11"
    }
  }
  app_settings = {
    "GITBUCKET_DB_URL"      = var.db_url
    "GITBUCKET_DB_USER"     = var.db_user
    "GITBUCKET_DB_PASSWORD" = var.db_password
  }

}
