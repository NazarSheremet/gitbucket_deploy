# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "gitbucket2" {
  name     = "gitbucket2"
  location = "West Europe"

}

resource "azurerm_postgresql_server" "gitbucket2" {
  name                = "postgresql-gitbucket54543543"
  location            = azurerm_resource_group.gitbucket2.location
  resource_group_name = azurerm_resource_group.gitbucket2.name

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = "psqladmin"
  administrator_login_password = "P@ssw0rd"
  version                      = "11"
  ssl_enforcement_enabled      = true
}

# Create a database
resource "azurerm_postgresql_database" "gitbucket2" {
  name                = "gitbucket"
  resource_group_name = azurerm_resource_group.gitbucket2.name
  server_name         = azurerm_postgresql_server.gitbucket2.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_firewall_rule" "gitbucket2" {
  name                = "gitbucket"
  resource_group_name = azurerm_resource_group.gitbucket2.name
  server_name         = azurerm_postgresql_server.gitbucket2.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

resource "azurerm_service_plan" "gitbucket2" {
  name                = "gitbucket2-appserviceplan"
  location            = azurerm_resource_group.gitbucket2.location
  resource_group_name = azurerm_resource_group.gitbucket2.name
  os_type             = "Linux"
  sku_name            = "B1"
}


resource "azurerm_linux_web_app" "gitbucket2" {
  name                = "gitbucket2"
  location            = azurerm_resource_group.gitbucket2.location
  resource_group_name = azurerm_resource_group.gitbucket2.name
  service_plan_id     = azurerm_service_plan.gitbucket2.id


  site_config {
    application_stack {
      java_server  = "TOMCAT"
      java_version = "8"
    }
  }
  app_settings = {
    "GITBUCKET_DB_URL" = "jdbc:postgresql://postgresql-gitbucket54543543.postgres.database.azure.com:5432/gitbucket"
    "GITBUCKET_DB_USER" = "psqladmin@postgresql-gitbucket54543543"
    "GITBUCKET_DB_PASSWORD" = "P@ssw0rd"
  }

}

resource "azurerm_postgresql_server" "gitbucket3" {
  name                = "postgresql-gitbucket5454354"
  location            = azurerm_resource_group.gitbucket2.location
  resource_group_name = azurerm_resource_group.gitbucket2.name

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = "psqladmin"
  administrator_login_password = "P@ssw0rd"
  version                      = "11"
  ssl_enforcement_enabled      = true
}
resource "azurerm_postgresql_firewall_rule" "gitbucket3" {
  name                = "gitbucket"
  resource_group_name = azurerm_resource_group.gitbucket2.name
  server_name         = azurerm_postgresql_server.gitbucket2.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}