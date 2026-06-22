terraform {
  backend "azurerm" {
    resource_group_name  = "rg-kairoai-tfstate-ci"
    storage_account_name = "stkairoaitfstateci"
    container_name       = "prodtfstate"
    key                  = "kairoai/prod/terraform.tfstate"
    subscription_id      = "5b942f88-17e6-4026-ae23-d520365fb916"
    tenant_id            = "83474cb5-f1fa-4d06-906c-e5dad12ce3b9"
  }
}
