#!/bin/bash

set -o errexit -o noglob -o pipefail

[ -n "${TF_VAR_ARM_SUBSCRIPTION_ID}" ] || { echo "ARM_SUBSCRIPTION_ID environment variable not defined"; exit 1; }
[ -n "${TF_VAR_ARM_CLIENT_ID}" ] || { echo "ARM_CLIENT_ID environment variable not defined"; exit 1; }
[ -n "${TF_VAR_ARM_CLIENT_SECRET}" ] || { echo "ARM_CLIENT_SECRET environment variable not defined"; exit 1; }
[ -n "${TF_VAR_ARM_TENANT_ID}" ] || { echo "ARM_TENANT_ID environment variable not defined"; exit 1; }
[ -n "${TF_VAR_REGION}" ] || { echo "REGION environment variable not defined"; exit 1; }
[ -n "${TF_VAR_ADMIN_ACCOUNT}" ] || { echo "ADMIN_ACCOUNT environment variable not defined"; exit 1; }
[ -n "${TF_VAR_ADMIN_PASSWORD}" ] || { echo "ADMIN_PASSWORD environment variable not defined"; exit 1; }
[ -n "${TF_VAR_ARM_ACCESS_KEY}" ] || { echo "ARM_ACCESS_KEY environment variable not defined"; exit 1; }

if [ "$1" == "plan" ]; then
    terraformAction="plan"
elif [ "$1" == "apply" ]; then
    terraformAction="apply"
elif [ "$1" == "destroy" ]; then
    terraformAction="destroy"
fi

# set directory to the where the Terraform scripts reside
workspaceDir="$3"
#cd\\
cd "${workspaceDir}"
cd "Terraform"

# Prepare Terraform
rm -rf .terraform
terraform --version
terraform init -upgrade
terraform get -update

# set Azure related secrets as environment variables for Terraform to use 
export ARM_SUBSCRIPTION_ID="${TF_VAR_ARM_SUBSCRIPTION_ID}"
export ARM_CLIENT_ID="${TF_VAR_ARM_CLIENT_ID}"
export ARM_CLIENT_SECRET="${TF_VAR_ARM_CLIENT_SECRET}"
export ARM_TENANT_ID="${TF_VAR_ARM_TENANT_ID}"
export ARM_ACCESS_KEY="${TF_VAR_ACCOUNT_KEY}"

export TF_ADMIN_ACCOUNT="${TF_ADMIN_ACCOUNT}"
export TF_ADMIN_PASSWORD="${TF_ADMIN_PASSWORD}"

# sh "az login --service-principal -u ${TF_VAR_ARM_CLIENT_ID} -p ${TF_VAR_ARM_CLIENT_SECRET} -t ${TF_VAR_ARM_TENANT_ID} "

if [ "${terraformAction}" == "plan" ]; then
    case "$2" in
        network )
            echo "Plan network"
            terraform plan -target=module.network
            ;;
        simple-vm )
            echo "Plan vm-base"
            terraform plan -target=module.app-vm
            ;;
        domain-controller )
            echo "Plan Domain Controller"
            terraform plan -target=module.dc-vm
            ;;
        sql )
            echo "Plan sql"
            terraform plan -target=module.sql-vm
            ;;
        config-mgr )
            echo "Plan config-mgr"
            terraform plan -target=module.configmgr-vm
            ;;
        azure-automation )
            echo "Plan azure-automation"
            terraform plan -target=module.azure-automation
            ;;
        * )
            echo "Pattern not matching in Plan"
            ;;
    esac
elif [ "${terraformAction}" == "apply" ]; then
    case "$2" in
        network )
            echo "Apply network"
            terraform apply -auto-approve -target=module.network
            ;;
        simple-vm )
            echo "Apply simple-vm"
            terraform apply -auto-approve -target=module.app-vm
            ;;
        domain-controller )
            echo "Apply Domain Controller"
            terraform apply -auto-approve -target=module.dc-vm
            ;;
        sql )
            echo "Apply sql"
            terraform apply -auto-approve -target=module.sql-vm
            ;;
        config-mgr )
            echo "Apply config-mgr"
            terraform apply -auto-approve -target=module.configmgr-vm
            ;;
        azure-automation )
            echo "Apply azure-automation"
            terraform apply -auto-approve -target=module.azure-automation
            ;;
        * )
            echo "Pattern not matching in Apply"
            ;;
    esac
elif [ "${terraformAction}" == "destroy" ]; then
    case "$2" in
        all )
            echo "Destroy ALL!!!"
            terraform destroy -auto-approve
            ;;
        network )
            echo "Destroy network!!!"
            terraform destroy -auto-approve -target=module.network
            ;;
        sql )
            echo "Destroy sql!!!"
            terraform destroy -auto-approve -target=module.sql-vm
            ;;
        configmgr )
            echo "Destroy configmgr!!!"
            terraform destroy -auto-approve -target=module.configmgr-vm
            ;;
        * )
            echo "Pattern not matching"
            ;;
    esac
else
    echo "Invalid terraform action: ${terraformAction}"
    exit 2
fi

