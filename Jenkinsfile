pipeline {
    agent any
    environment {
        SONAR_TOKEN = credentials('sonar-token') // Make sure this is credential ID exists in Jenkins UI
        SONAR_SCANNER_HOME = tool 'sonarqube' // Ensure this tool is configured in Jenkins
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/luckysuie/custompolicy.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarserver') { // 'sonarserver' must be the cofigured name in Jenkins → SonarQube servers
                    sh '''
                        ${SONAR_SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=jenkins1234 \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=http://172.190.143.248:9000 \
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
                        -Dsonar.projectKey=jenkins1234 \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=http://172.190.143.248:9000 \
                        -Dsonar.login=${SONAR_TOKEN} \
                        -Dsonar.qualitygate.wait=false
                    '''
                }
            }
        stage('Login to Azure') {
                steps {
                    withcredentials([
                        usernamePassword(credentialsId: 'azure-sp', passwordVariable: 'AZURE_PASSWORD', usernameVariable: 'AZURE_APP_ID'),
                        string(credentialsId: 'azure-tenant', variable: 'AZURE_TENANT')
                    ]) {
                        sh '''
                            az login --service-principal -u $AZURE_APP_ID -p $AZURE_PASSWORD --tenant $AZURE_TENANT
                        '''
                    }
                }
            }
        }
    }
}
