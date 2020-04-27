#################################################################
#   Variables
#################################################################

# The following details are stored in Jenkins Credential store:
# - Azure subscription details
#   - subscription_id
#   - client_id
#   - client_secret
#   - tenant_id
# - Terraform Backend Storage Access Key
# - Local Admin username and password

# Generic info
location                                    = "eastus2"
# offering variable used as base for name of many azure resources eg Resource Group and Virtual Network 
offering                                    = "wld"
environment_name                            = "dev"
prefix                                      = "devwld"
wld_timezone                                = "AUS Eastern Standard Time"
artifactory_url                             = "https://artifactory.csc.com/artifactory/wm-pipeline/SOE/v1.0.0/"
artifactory_key                             = "AKCp5dKiMz4LcpzfDkBJZUWNaV36PB17eyqfz6CERtLwYkumPQjxZcLUcd883e7B4MmmyQHDn"

# Common tags
common_tags = {
    environment                             = "dev"
    application-id                          = "FRMWRK"
    owner                                   = "WLD"
}
# Network
address_space                               = "10.100.0.0/16"

dc_subnet_name                              = "subnet-dc"
dc_subnet_prefix                            = "10.100.1.0/24"
# Domain Controller VM
dc_private_ip_address                       = ""
dc_private_ip_address_prefix                = "10.100.1."

db_subnet_name                              = "subnet-db"
db_subnet_prefix                            = "10.100.2.0/24"
# prefix must end in '.'and  must align with db_subnet_prefix
sql_private_ip_address_prefix               = "10.100.2."
sql_private_ip_address                      = ""

app_subnet_name                             = "subnet-app"
app_subnet_prefix                           = "10.100.3.0/24"
# prefix must end in '.' and must align with app_subnet_prefix
app_private_ip_address_prefix               = "10.100.3."
app_private_ip_address                      = ""

# Domain Controller VM 
dc_server_role                              = "dc"

dc_vmcount                                  = 1
dc_vm_size                                  = "Standard_B2ms" 
dc_sku                                      = "2016-Datacenter-smalldisk"
dc_formatted_data_disk_count                = 0
// Where more than one disk then all disks will be same size if only one value specified in array below, otherwise define individual values per disk, comma separated
dc_formatted_data_disk_size_gb              = [10] 

# Master VM
mst_server_role                       = "dep"

mst_vmcount                           = 1
mst_vm_size                           = "Standard_B2ms" //"Standard_A1" 
mst_sku                               = "2016-Datacenter-smalldisk"
mst_formatted_data_disk_count         = 0
// Where more than one disk then all disks will be same size if only one value specified in array below, otherwise define individual values per disk, comma separated
mst_formatted_data_disk_size_gb       = [10] 

# SQL VM 
sql_server_role                             = "sql"

sql_vmcount                                 = 1
sql_vm_size                                 = "Standard_B2ms" 
sql_sku                                     = "2016-Datacenter" // small disk for SQL is not large enough
sql_formatted_data_disk_count               = 0 
// Where more than one disk then all disks will be same size if only one value specified in array below, otherwise define individual values per disk, comma separated
sql_formatted_data_disk_size_gb             = [10] 

# SharePoint VM 
spt_server_role                             = "spt"

spt_vmcount                                 = 1
spt_vm_size                                 = "Standard_B2ms" //"Standard_A1" 
spt_sku                                     = "2016-Datacenter-smalldisk"
spt_formatted_data_disk_count               = 0
// Where more than one disk then all disks will be same size if only one value specified in array below, otherwise define individual values per disk, comma separated
spt_formatted_data_disk_size_gb             = [10] 

# Azure Automation - DSC
# Resource group to host Azure automation. 
location_azure_automation                   = "eastus2"

automation_resource_group                   = "Automation"
automation_account_name                     = "DSC-AzureAutomationAccount"
azure_automation_sku                        = "Basic"
# Array of DSC modules to load.
#  - key of array must be the name of the module
#  - value of array must be uri to module
# If you have no modules to load then either comment out or remove the variable 'dsc_module_list' below
dsc_module_list                             = [ 
    {"ComputerManagementDsc" = "https://www.powershellgallery.com/api/v2/package/ComputerManagementDsc/6.4.0"}    ,
    {"xActiveDirectory"      = "https://www.powershellgallery.com/api/v2/package/xActiveDirectory/3.0.0.0"}       ,
    {"xReleaseManagement"    = "https://www.powershellgallery.com/api/v2/package/xReleaseManagement/1.0.0.0"}     ,
    {"SqlServerDsc"          = "https://www.powershellgallery.com/api/v2/package/SqlServerDsc/13.1.0.0"}          ,
    {"SecurityPolicyDsc"     = "https://www.powershellgallery.com/api/v2/package/SecurityPolicyDsc/2.9.0.0"}      ,
    {"cNtfsAccessControl"    = "https://www.powershellgallery.com/api/v2/package/cNtfsAccessControl/1.4.1.0"}      ,
    {"NetworkingDsc"         = "https://www.powershellgallery.com/api/v2/package/NetworkingDsc/7.3.0.0"}
]
