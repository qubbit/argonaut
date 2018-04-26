variable "pg_admin_password" {}
variable "pg_developer_password" {}

provider "azurerm" {}

resource "azurerm_resource_group" "argonaut" {
  name     = "${terraform.workspace}-argonaut-development"
  location = "East US"
}

resource "azurerm_postgresql_server" "argonaut" {
  name                = "argonaut-development"
  resource_group_name = "${azurerm_resource_group.argonaut.name}"
  location            = "${azurerm_resource_group.argonaut.location}"

  sku {
    tier     = "Basic"
    capacity = 50
    name     = "PGSQLB50"
  }

  administrator_login          = "mpfefferle"
  administrator_login_password = "${var.pg_admin_password}"
  version                      = "9.6"
  storage_mb                   = "51200"
  ssl_enforcement              = "Enabled"
}

resource "azurerm_postgresql_database" "argonaut" {
  name                = "argonaut"
  resource_group_name = "${azurerm_resource_group.argonaut.name}"
  server_name         = "${azurerm_postgresql_server.argonaut.name}"
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_firewall_rule" "miranova" {
  name                = "miranova"
  resource_group_name = "${azurerm_resource_group.argonaut.name}"
  server_name         = "${azurerm_postgresql_server.argonaut.name}"
  start_ip_address    = "63.84.60.226"
  end_ip_address      = "63.84.60.226"
}

resource "azurerm_log_analytics_workspace" "argonaut" {
  name                = "argonaut-${terraform.workspace}"
  resource_group_name = "${azurerm_resource_group.argonaut.name}"
  location            = "${azurerm_resource_group.argonaut.location}"
  sku                 = "Free"
}

resource "azurerm_log_analytics_solution" "argonaut" {
  solution_name         = "AzureWebAppsAnalytics"
  resource_group_name   = "${azurerm_resource_group.argonaut.name}"
  location              = "${azurerm_resource_group.argonaut.location}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.argonaut.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.argonaut.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/AzureWebAppsAnalytics"
  }
}

provider "postgresql" {
  version = "0.1"
  host    = "${azurerm_postgresql_server.argonaut.fqdn}"

  # host = "argonaut-development.postgres.database.azure.com"

  database = "argonaut"
  username = "mpfefferle@argonaut-development"
  password = "${var.pg_admin_password}"
  sslmode  = "require"
}

resource "postgresql_role" "developer" {
  name     = "developer"
  login    = true
  password = "${var.pg_developer_password}"
}

resource "postgresql_schema" "argonaut" {
  name  = "argonaut"
  owner = "mpfefferle"

  policy {
    usage = true
    role  = "developer"
  }
}

resource "azurerm_template_deployment" "argonaut" {
  name                = "argonaut"
  resource_group_name = "${azurerm_resource_group.argonaut.name}"
  deployment_mode     = "Incremental"
  template_body       = "${file("azuredeploy.json")}"

  parameters {
    "appName" = "argonaut-${terraform.workspace}"

    # "publishingUsername" = "${azurerm_app_service.argonaut.site_credential.0.username}"
    # "publishingPassword" = "${azurerm_app_service.argonaut.site_credential.0.password}"
    # "siteName"           = "${azurerm_app_service.argonaut.name}"
  }
}

# output "docker_registry_hostname" {
#   value = "${azurerm_container_registry.argonaut.login_server}"
# }


# output "docker_username" {
#   value = "${azurerm_container_registry.argonaut.admin_username}"
# }


# output "docker_password" {
#   value     = "${azurerm_container_registry.argonaut.admin_password}"
#   sensitive = true
# }

