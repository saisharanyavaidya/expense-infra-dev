pipeline {
    agent {
        label 'AGENT-1'
    }
    options {
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
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
                sh 'echo This is Test'
                sh 'sleep 10'
            }
        }
        stage('Deploy') {
            steps {
                sh 'echo This is Deploy'
            }
        }
    }

    post {
        always {
            echo "I will always run even when pipeline is success or failure"
        }
        success {
            echo "I will run when pipeline is success"
        }
        failure {
            echo "I will run when pipeline is failure"
        }
    }
}