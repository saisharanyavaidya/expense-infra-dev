pipeline {
    agent {
        label 'AGENT-1'
    }
    options {
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
        ansiColor('xterm')
    }
    environment {
        DEPLOY_TO = 'Production'
        GREETING = 'Good Morning'
    }
    stages {
        stage('init') {
            steps {
                sh """
                    cd 01-vpc
                    terraform init -reconfigure
                """
            }
        }
        stage('plan') {
            steps {
                sh """
                    cd 01-vpc
                    terraform plan
                """
            }
        }
        stage('Deploy') {
            steps {
                input {
                    message "Should we continue and apply terraform?"
                    ok "Yes, please proceed"
                }
                sh """
                    cd 01-vpc
                    terraform apply -auto-approve
                """
            }
        }
    }

    post {
        always {
            echo "I will always run even when pipeline is success or failure"
            deleteDir()
        }
        success {
            echo "I will run when pipeline is success"
        }
        failure {
            echo "I will run when pipeline is failure"
        }
    }
}