pipeline {
    agent any
    
    stages {
        stage('GitCheckout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: "*/master"]],
                  userRemoteConfigs: [[url: 'https://github.com/pravintemghare/testapp-jenkins.git',
                                       credentialsId: 'github']]
                ])    
            }
        }

        stage('Terraform init') {
            steps {
                dir('infrastructure'){
                sh ('terraform init')
                }
            }
        }

        stage('Terraform plan') {
            steps {
                dir('infrastructure'){
                sh ('terraform plan')
                }
            }
        }        
        
        stage('Terraform action') {
            steps {
                echo "Terraform action is --> ${action}"
                dir('infrastructure'){
                sh ('terraform ${action} --auto-approve')
                }
            }
        }
    }
}        