pipeline {
    agent any

    environment {
        // SonarQube Server ID configured in Jenkins
        SONARQUBE_SERVER = 'sonarserver'
        // SonarQube Scanner tool name configured in Jenkins
        SCANNER = 'sonarqube'
        // Azure credentials
        AZURE_CLIENT_ID = credentials('azure-sp')
        AZURE_TENANT_ID = credentials('azure-tenant')
        // SonarQube token
        SONAR_TOKEN = credentials('sonar-token')
    }

    triggers {
        githubPush()
    }

    stages {

        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/luckysuie/custompolicy.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    sh "${SCANNER}/bin/sonar-scanner \
                        -Dsonar.projectKey=jenkins1234 \
                        -Dsonar.projectName=jenkins \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=http://172.190.143.248:9000 \
                        -Dsonar.login=${SONAR_TOKEN}"
                }
            }
        }

        stage('Wait for Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Azure Login') {
            steps {
                sh '''
                az login --service-principal \
                    --username $AZURE_CLIENT_ID \
                    --password $AZURE_CLIENT_ID \
                    --tenant $AZURE_TENANT_ID
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed.'
        }
    }
}
