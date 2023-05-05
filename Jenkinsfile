pipeline {
    agent any
    
    stages {
        stage('GitCheckout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: "*/master"]],
                  userRemoteConfigs: [[url: 'https://github.com/pravintemghare/myapp.git',
                                       credentialsId: 'GitHub cred']]
                ])    
            }
        }
    }
}        