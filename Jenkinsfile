pipeline {
    agent {
        label 'node'
    }

    tools {
        // Ensure the tool name matches the one configured in Jenkins under Global Tool Configuration
        sonarScanner 'sonarqube'
    }

    environment {
        SONAR_TOKEN = credentials('sonar-token') // Reference to the Jenkins credentials ID
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/luckysuie/custompolicy.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarserver') { // 'sonarserver' should match your configured SonarQube server name in Jenkins
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

        stage('Publish Results (Optional)') {
            steps {
                echo 'Publishing SonarQube results...'
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
        }
    }
}
