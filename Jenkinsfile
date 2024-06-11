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
    parameters {
        choice(name: 'action', choices: ['Apply', 'Destroy'], description: 'Pick if infra should be applied or destroyed')
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
            when {
                expression {
                    params.action == 'Apply'
                }
            }
            steps {
                sh """
                    cd 01-vpc
                    terraform plan
                """
            }
        }
        stage('Deploy') {
            when {
                expression {
                    params.action == 'Apply'
                }
            }
            input {
                    message "Should we continue and apply terraform?"
                    ok "Yes, please proceed with terraform apply"
                }
            steps {
                sh """
                    cd 01-vpc
                    terraform apply -auto-approve
                """
            }
        }
        stage('Destroy') {
            when {
                expression {
                    params.action == 'Destroy'
                }
            }
            steps {
                sh """
                    cd 01-vpc
                    terraform destroy -auto-approve
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