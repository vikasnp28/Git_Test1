// Declaring Environment variables passing from JenkinsFile.
/*variable "REGION" {
}

variable "ARM_SUBSCRIPTION_ID" {
}

variable "ARM_CLIENT_ID" {
}

variable "ARM_CLIENT_SECRET" {
}

variable "ARM_TENANT_ID" {
}
*/
// Common variables
variable "location" {
}

variable "offering" {
}

variable "environment_name" {
}

variable "prefix" {
}
variable artifactory_url {}
variable artifactory_key {}
variable "wld_timezone" {
  description = "The timezone the VM should be assigned"
}

// Common tags
#variable tag_environment {}
#variable tag_application_id {}
#variable tag_owner {}
variable "common_tags" {
  type = map(string)
}

// Network module variables
variable "address_space" {
}

# Domain Controller resources
variable "dc_subnet_name" {
}

variable "dc_subnet_prefix" {
}

// Domain Controller variables
variable "dc_server_role" {
}

variable "dc_vmcount" {
}

variable "dc_private_ip_address" {
}

variable "dc_vm_size" {
  description = "The size of the VM"
}

variable "dc_sku" {
  description = "The windows server OS"
}

variable "dc_formatted_data_disk_count" {
  description = "How many formatted disks to create"
}

variable "dc_formatted_data_disk_size_gb" {
  description = "The size of the formatted disk"
}

variable "dc_private_ip_address_prefix" {
}

# SQL resources
variable "db_subnet_name" {
}

variable "db_subnet_prefix" {
}

# Application resources
variable "app_subnet_name" {
}

variable "app_subnet_prefix" {
}

variable "app_private_ip_address_prefix" {
}

variable "app_private_ip_address" {
}

variable "ADMIN_ACCOUNT" {
}

variable "ADMIN_PASSWORD" {
}

// SQL variables
variable "sql_server_role" {
}

variable "sql_vm_size" {
  description = "The size of the VM"
}

variable "sql_sku" {
  description = "The windows server OS"
}

variable "sql_vmcount" {
}

variable "sql_private_ip_address_prefix" {
}

variable "sql_private_ip_address" {
}

variable "sql_formatted_data_disk_count" {
  description = "How many formatted disks to create"
}

variable "sql_formatted_data_disk_size_gb" {
  description = "The size of the formatted disk"
}

// SharePoint variables
variable "spt_server_role" {
}

variable "spt_vm_size" {
  description = "The size of the VM"
}

variable "spt_sku" {
  description = "The windows server OS"
}

variable "spt_vmcount" {
}

variable "spt_formatted_data_disk_count" {
  description = "How many formatted disks to create"
}

variable "spt_formatted_data_disk_size_gb" {
  description = "The size of the formatted disk"
}

// Master Server variables
variable "mst_server_role" {
}

variable "mst_vm_size" {
  description = "The size of the VM"
}

variable "mst_sku" {
  description = "The windows server OS"
}

variable "mst_vmcount" {
}

variable "mst_formatted_data_disk_count" {
  description = "How many formatted disks to create"
}

variable "mst_formatted_data_disk_size_gb" {
  description = "The size of the formatted disk"
}

# Azure Automation - DSC
variable "location_azure_automation" {
  description = "Region where Azure Automation resource will be created"
}

variable "automation_resource_group" {
  description = "Resource group to host Azure automation. May not be able to resue existing resource group due to automation not beiong avao;able in all regions/locations."
}

variable "automation_account_name" {
  description = "Name of Azure Automation account"
}

variable "azure_automation_sku" {
  description = "Azure Automation SKU"
}

variable "dsc_module_list" {
  type = "list"
  description = "Array of DSC modules to load."

  default = []
}
