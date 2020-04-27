
##########################################################
## Create Azure Automation  
##########################################################
module "azure-automation" {
  source                    = "git::https://github.dxc.com/workplace/Terraform-Gallery.git//modules/Azure/azure-automation?ref=v0.3.0"
  location_azure_automation = var.location_azure_automation
  automation_resource_group = var.automation_resource_group
  automation_account_name   = var.automation_account_name
  azure_automation_sku      = var.azure_automation_sku
  dsc_module_list           = var.dsc_module_list
  common_tags               = var.common_tags
}

##########################################################
## Create Resource group Network & subnets   
##########################################################
module "network" {
  source            = "git::https://github.dxc.com/workplace/Terraform-Gallery.git//modules/Azure/network?ref=v0.3.0"
  resource_group_name = var.automation_resource_group
  address_space     = var.address_space
  offering          = var.offering
  location          = var.location
  dc_subnet_name    = var.dc_subnet_name
  dc_subnet_prefix  = var.dc_subnet_prefix
  app_subnet_name   = var.app_subnet_name
  app_subnet_prefix = var.app_subnet_prefix
  db_subnet_name    = var.db_subnet_name
  db_subnet_prefix  = var.db_subnet_prefix
  common_tags       = var.common_tags
}

##########################################################
## Create DC VM 
##########################################################
module "dc-vm" {
  source                           = "git::https://github.dxc.com/workplace/Terraform-Gallery.git//modules/Azure/vm-base?ref=v0.3.0"
  resource_group_name              = var.automation_resource_group
  location                         = var.location
  prefix                           = var.prefix
  server_role                      = var.dc_server_role
  subnet_id                        = module.network.out_dc_subnet_subnet_id
  admin_username                   = var.ADMIN_ACCOUNT
  admin_password                   = var.ADMIN_PASSWORD
  vm_size                          = var.dc_vm_size
  sku                              = var.dc_sku
  vmcount                          = var.dc_vmcount
  private_ip_address_prefix        = var.dc_private_ip_address_prefix
  private_ip_address               = var.dc_private_ip_address
  data_disk_formatted_count        = var.dc_formatted_data_disk_count
  data_disk_formatted_size_gb      = var.dc_formatted_data_disk_size_gb
  dsc_server_endpoint              = module.azure-automation.out_dsc_server_endpoint
  dsc_primary_access_key           = module.azure-automation.out_dsc_primary_access_key
  artifactory_url                  = var.artifactory_url
  artifactory_key                  = var.artifactory_key
  vm_timezone                      = var.wld_timezone
  common_tags                      = var.common_tags
  create_public_ip                 = false
}

##########################################################
## Create Master Server VM  
##########################################################
module "master-vm" {
  source                           = "git::https://github.dxc.com/workplace/Terraform-Gallery.git//modules/Azure/vm-base?ref=v0.3.0"
  resource_group_name              = var.automation_resource_group
  location                         = var.location
  prefix                           = var.prefix
  server_role                      = var.mst_server_role
  subnet_id                        = module.network.out_app_subnet_subnet_id
  admin_username                   = var.ADMIN_ACCOUNT
  admin_password                   = var.ADMIN_PASSWORD
  vm_size                          = var.mst_vm_size
  sku                              = var.mst_sku
  vmcount                          = var.mst_vmcount
  private_ip_address_prefix        = var.app_private_ip_address_prefix
  private_ip_address               = var.app_private_ip_address
  data_disk_formatted_count        = var.mst_formatted_data_disk_count
  data_disk_formatted_size_gb      = var.mst_formatted_data_disk_size_gb
  dsc_server_endpoint              = module.azure-automation.out_dsc_server_endpoint
  dsc_primary_access_key           = module.azure-automation.out_dsc_primary_access_key
  artifactory_url                  = var.artifactory_url
  artifactory_key                  = var.artifactory_key
  vm_timezone                      = var.wld_timezone
  common_tags                      = var.common_tags
  create_public_ip                 = false
}

##########################################################
## Create SQL VM  
##########################################################
module "sql-vm" {
  source                           = "git::https://github.dxc.com/workplace/Terraform-Gallery.git//modules/Azure/vm-base?ref=v0.3.0"
  resource_group_name              = var.automation_resource_group
  location                         = var.location
  prefix                           = var.prefix
  server_role                      = var.sql_server_role
  subnet_id                        = module.network.out_db_subnet_subnet_id
  admin_username                   = var.ADMIN_ACCOUNT
  admin_password                   = var.ADMIN_PASSWORD
  vm_size                          = var.sql_vm_size
  sku                              = var.sql_sku
  vmcount                          = var.sql_vmcount
  private_ip_address_prefix        = var.sql_private_ip_address_prefix
  private_ip_address               = var.sql_private_ip_address
  data_disk_formatted_count        = var.sql_formatted_data_disk_count
  data_disk_formatted_size_gb      = var.sql_formatted_data_disk_size_gb
  dsc_server_endpoint              = module.azure-automation.out_dsc_server_endpoint
  dsc_primary_access_key           = module.azure-automation.out_dsc_primary_access_key
  artifactory_url                  = var.artifactory_url
  artifactory_key                  = var.artifactory_key
  vm_timezone                      = var.wld_timezone
  common_tags                      = var.common_tags
  create_public_ip                 = false
}
/*
##########################################################
## Create SharePoint VM  
##########################################################
module "spt-vm" {
  source                           = "git::https://github.dxc.com/workplace/Terraform-Gallery.git//modules/Azure/vm-base?ref=v0.3.0"
  resource_group_name              = var.automation_resource_group
  location                         = var.location
  prefix                           = var.prefix
  server_role                      = var.spt_server_role
  subnet_id                        = module.network.out_app_subnet_subnet_id
  admin_username                   = var.ADMIN_ACCOUNT
  admin_password                   = var.ADMIN_PASSWORD
  vm_size                          = var.spt_vm_size
  sku                              = var.spt_sku
  vmcount                          = var.spt_vmcount
  private_ip_address_prefix        = var.app_private_ip_address_prefix
  private_ip_address               = var.app_private_ip_address
  data_disk_formatted_count        = var.spt_formatted_data_disk_count
  data_disk_formatted_size_gb      = var.spt_formatted_data_disk_size_gb
  dsc_server_endpoint              = module.azure-automation.out_dsc_server_endpoint
  dsc_primary_access_key           = module.azure-automation.out_dsc_primary_access_key
  artifactory_url                  = var.artifactory_url
  artifactory_key                  = var.artifactory_key
  vm_timezone                      = var.wld_timezone
  common_tags                      = var.common_tags
  create_public_ip                 = false
}
*/
