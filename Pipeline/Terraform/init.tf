/**
**    This file is to execute the configuration required to initialise Terraform
*/

// Pin the Terraform version
terraform {
  required_version = "= 0.12.3"
}

// Provider declaration to manage azure resources and pin the provider version  
provider "azurerm" {
 version = "=1.30.1"

}

// Pre-created storage account for storing terraform state files.
// Backend access key is stored in Terraform and assigned to environment variable

terraform {
  backend "azurerm" {
    storage_account_name = "guillstorage"
    container_name       = "tf-state-backend"
    key                  = "terraform/backend-storage.tfstate"
  }
}
