terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-bug-reproduction"
    storage_account_name = "terraformbugreproduction"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
  }
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.43.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "resource_group" {
  name = "terraform-bug-reproduction"
}

resource "azurerm_service_plan" "asp" {
  name                = "terraform-bug-reproduction"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  os_type             = "Linux"
  sku_name            = "P1v3"
}

resource "azurerm_linux_web_app" "web_app" {
  name                = "terraform-bug-reproduction"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = azurerm_service_plan.asp.location
  service_plan_id     = azurerm_service_plan.asp.id

  app_settings = {
    "RANDOM_ENV_VAR" = "I change this to delete the docker settings, whcih then can be reapplied by uncommenting the following workaround"
    # If you need to change app_settings uncommenting this might help to not brake it. Not tested though
    #"DOCKER_REGISTRY_SERVER_URL"      = var.docker_registry
    #"DOCKER_REGISTRY_SERVER_USERNAME" = var.docker_registry_user
    #"DOCKER_REGISTRY_SERVER_PASSWORD" = var.docker_registry_password
  }


  https_only = true

  public_network_access_enabled = true

  site_config {
    http2_enabled                     = true

    application_stack {
      docker_image_name        = "hello-world"
      docker_registry_url      = var.docker_registry
      docker_registry_username = var.docker_registry_user
      docker_registry_password = var.docker_registry_password
    }
  }

  logs {
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }

  #lifecycle {
  #  ignore_changes = [site_config[0].application_stack[0].docker_image_name]
  #}
}