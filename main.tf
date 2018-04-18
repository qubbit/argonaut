provider "azurerm" {}

resource "azurerm_resource_group" "argonaut" {
  name = "${terraform.workspace}-argonaut-development"
  location = "East US"
}
