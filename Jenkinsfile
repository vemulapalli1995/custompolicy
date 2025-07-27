pipeline{
    agent{
        label "node"
    }
    stages{
        stage("Git Checkout") {
            steps{
                git branch: 'main', url: 'https://github.com/luckysuie/custompolicy.git'
            }
        }
        stage('sonarqube analysis') {
            environment {
                SCANNER_HOME = tool 'sonarqube' // Assuming 'sonarqube' is the name of the SonarQube scanner tool configured in Jenkins
                SONAR_TOKEN = credentials('sonar-token') // Assuming 'sonar-token' is the ID of the SonarQube token credential configured in Jenkins
            }
            steps {
                withSonarQubeEnv('sonarserver') { // Assuming 'sonarserver' is the name of the SonarQube server configured in Jenkins
                sh '''
                    ${SCANNER_HOME}/bin/sonar-scanner \
                    -Dsonar.projectKey=custompolicy \
                    -Dsonar.sources=. \
                    -Dsonar.host.url=http://172.190.143.248:9000 \
                    -Dsonar.login=${SONAR_TOKEN} \
                '''
                }
            }
            stage('publish results') {
                steps {
                    echo 'Publishing SonarQube results...'
                    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                        sh '''
                            ${SCANNER_HOME}/bin/sonar-scanner \
                            -Dsonar.projectKey=custompolicy \
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

}