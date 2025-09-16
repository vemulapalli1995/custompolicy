pipeline {
    agent any

    environment {
        SONAR_TOKEN = f8591764523c3ea1b08c4ea766173fb9541639ad         // Ensure this credential exists
        SONAR_SCANNER_HOME = tool 'sonarqube'            // Must match name configured in Global Tool Configuration
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/vemulapalli1995/custompolicy'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarserver') {         // 'sonarserver' must be configured under SonarQube servers
                    sh '''
                        ${SONAR_SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=myprof-projects_project10 \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=http://4.205.120.86:9000 \
                        -Dsonar.login=${SONAR_TOKEN}
                    '''
                }
            }
        }

        stage('Publish SonarQube Results') {
            steps {
                echo 'Re-running scanner to publish results without quality gate blocking...'
                withSonarQubeEnv('sonarserver') {
                    sh '''
                        ${SONAR_SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=myprof-projects_project10 \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=http://4.205.120.86:9000 \
                        -Dsonar.login=${SONAR_TOKEN} \
                        -Dsonar.qualitygate.wait=false
                    '''
                }
            }
        }

        stage('Login to Azure') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'azure-sp', usernameVariable: 'AZURE_APP_ID', passwordVariable: 'AZURE_PASSWORD'),
                    string(credentialsId: 'azure-tenant', variable: 'AZURE_TENANT')
                ]) {
                    sh '''
                        az login --service-principal -u $AZURE_APP_ID -p $AZURE_PASSWORD --tenant $AZURE_TENANT
                    '''
                }
            }
        }
        stage('Terraform Initialize') {
            steps {
                sh '''
                    terraform init
                '''
            }
        }
        stage('Terraform validate') {
            steps {
                sh '''
                    terraform validate
                '''
            }
        }
        stage('Terraform Plan') {
            steps {
                sh '''
                    terraform plan -out=tfplan
                '''
            }
        }
        stage('Terraform Apply') {
            steps {
                sh '''
                    terraform apply -auto-approve tfplan
                '''
            }
        }
    }
}
