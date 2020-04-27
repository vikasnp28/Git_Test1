pipeline {
    agent {
        dockerfile {
            filename 'Dockerfile'
            dir 'Jenkins'
        }
    }

// Environment variables
    environment {
        // WARNING: if DESTROY_ALL="true" then all resource will be destroyed
        // Used to simplify testing and re-runs
        DESTROY_ALL                 = "false"
        executeStepAzureAutomation  = "false"
        executeStepNetwork          = "false"
        executeStepDC               = "false"
        executeStepSQL              = "false"
        executeStepCfgMgr           = "false"

        // Terraform variables
        TF_VAR_REGION               = "EastUS"

        TF_VAR_ARM_SUBSCRIPTION_ID  = credentials('ARM_SUBSCRIPTION_ID')
        TF_VAR_ARM_CLIENT_ID        = credentials('ARM_CLIENT_ID')
        TF_VAR_ARM_CLIENT_SECRET    = credentials('ARM_CLIENT_SECRET')
        TF_VAR_ARM_TENANT_ID        = credentials('ARM_TENANT_ID')
        TF_VAR_ARM_ACCESS_KEY       = credentials('ARM_ACCESS_KEY')

        // Account details for Domain & VM admin
        TF_VAR_ADMIN_ACCOUNT        = credentials('ADMIN_ACCOUNT')
        TF_VAR_ADMIN_PASSWORD       = credentials('ADMIN_PASSWORD')

    }
    // Keep Build history upto 10 days.
    // Keep last 10 build artifacts at a time.
    // Ads Build Time stamp to log file.
    // Disable concurrent builds.
    // Set timeout to 1 hour
    options {
        buildDiscarder(logRotator(daysToKeepStr: '10', artifactNumToKeepStr: '10'))
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 1, unit: 'HOURS'
    }
    stages {
        stage('Destroy ALL') {
            when { branch 'gvargas2' }
            steps {
                script {
                    if (env.DESTROY_ALL == 'true') { 
                        // TODO: sort out dependancies when destroying eg subnet is in use error
                        echo 'Running terraform destroy for ALL'
                        sh "bash -x ${WORKSPACE}/Jenkins/deploy-to-azure.sh destroy all"

                     //     throw new Exception("Throw to stop pipeline")
                    }
                }
            }  
        }  
        stage('Plan, Apply Azure Automation') {
            when { branch 'gvargas2' }
            steps {
                script {
                    if (env.executeStepAzureAutomation == 'true') { 
                        echo 'Running terraform plan for Azure Automation module'
                        sh "bash -x ${WORKSPACE}/Jenkins/deploy-to-azure.sh plan azure-automation ${WORKSPACE}"
                        echo 'Running terraform apply for Azure Automation module'
                        sh "bash -x ${WORKSPACE}/Jenkins/deploy-to-azure.sh apply azure-automation ${WORKSPACE}"
                    }
                }
            }
        }   
   
        stage('Plan, Apply Virtual Network Resources') {
            when { branch 'gvargas2' }
            steps {
                script {
                    if (env.executeStepNetwork == 'true') { 
                        echo 'Running terraform plan for network module'
                        sh "bash -x ${WORKSPACE}/Jenkins/deploy-to-azure.sh plan network"
                        echo 'Running terraform apply for network module'
                        sh "bash -x ${WORKSPACE}/Jenkins/deploy-to-azure.sh apply network"
                    }
                }
            }
        }   
        stage('Plan, Apply DC VM') { 
            when { branch 'gvargas2' }
            steps {
                script {
                    if (env.executeStepDC == 'true') { 
                        echo 'Running terraform plan for Domain Controller module'
                        sh "bash -x ${WORKSPACE}/Jenkins/deploy-to-azure.sh plan domain-controller"
                        echo 'Running terraform apply for Domain Controller module'
                        sh "bash -x ${WORKSPACE}/Jenkins/deploy-to-azure.sh apply domain-controller"
                    }
                }
            }
        }             
        stage('Plan, Apply SQL VM') {
            when { branch 'gvargas2' }
            steps {
                script {
                    if (env.executeStepSQL == 'true') { 
                        echo 'Running terraform plan for SQL module'
                        sh "bash -x ${WORKSPACE}/Jenkins/deploy-to-azure.sh plan sql"
                        echo 'Running terraform apply for SQL module'
                        sh "bash -x ${WORKSPACE}/Jenkins/deploy-to-azure.sh apply sql"
                    }
                }
            }
        }             
        stage('Plan, Apply ConfigMgr VM') {
            when { branch 'gvargas2' }
            steps {
                script {
                    if (env.executeStepCfgMgr == 'true') { 
                        echo 'Running terraform plan for ConfigMgr module'
                        sh "bash -x ${WORKSPACE}/Jenkins/deploy-to-azure.sh plan config-mgr"
                        echo 'Running terraform apply for ConfigMgr module'
                        sh "bash -x ${WORKSPACE}/Jenkins/deploy-to-azure.sh apply config-mgr"
                    }
                }
            }
        }             
    }
    post { 
        always { 
            echo 'One way or another, I have finished'
            /*
            Clean up workspace.
            This should be commented until Backend storage is configured 
            as it will 'break' Terraform by deleting the tfstate file.
            Only use if the tfstate file falls out of sync with actual infrastrucutre within Azure.
            */
            deleteDir()
        }
        success {
            echo 'I succeeeded!'
        }
        unstable {
            echo 'I am unstable :/'
        }
        failure {
            echo 'I failed :('
        }
        changed {
            echo 'Things were different before...'
        }
    }
}
