pipeline {
  agent any

  environment {
    // Jenkins credential that holds your Sonar token from http://4.205.120.86:9000
    SONARQUBE_TOKEN    = credentials('sonar-token')
    // SonarScanner tool name from Manage Jenkins > Tools
    SONAR_SCANNER_HOME = "${tool 'sonarqube'}"
  }

  stages {
    stage('Git Checkout') {
      steps {
        git branch: 'main',
            url: 'https://github.com/vemulapalli1995/custompolicy.git'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('sonarserver') {
          sh '''
            "${SONAR_SCANNER_HOME}/bin/sonar-scanner" \
              -Dsonar.projectKey=project10 \
              -Dsonar.sources=. \
              -Dsonar.host.url="$SONAR_HOST_URL" \
              -Dsonar.token="$SONARQUBE_TOKEN"
          '''
        }
      }
    }

    stage('Publish SonarQube Results') {
      steps {
        withSonarQubeEnv('sonarserver') {
          sh '''
            "${SONAR_SCANNER_HOME}/bin/sonar-scanner" \
              -Dsonar.projectKey=project10 \
              -Dsonar.sources=. \
              -Dsonar.host.url="$SONAR_HOST_URL" \
              -Dsonar.token="$SONARQUBE_TOKEN" \
              -Dsonar.qualitygate.wait=false
          '''
        }
      }
    }

    stage('Login to Azure') {
      steps {
        withCredentials([
          usernamePassword(credentialsId: 'azure-sp',
                           usernameVariable: 'AZURE_APP_ID',
                           passwordVariable: 'AZURE_PASSWORD'),
          string(credentialsId: 'azure-tenant', variable: 'AZURE_TENANT')
        ]) {
          sh '''
            az login --service-principal -u "$AZURE_APP_ID" -p "$AZURE_PASSWORD" --tenant "$AZURE_TENANT"
            # az account set --subscription "<YOUR_SUBSCRIPTION_ID>"
          '''
        }
      }
    }

    stage('Terraform Initialize') { steps { sh 'terraform init' } }
    stage('Terraform Validate')    { steps { sh 'terraform validate' } }
    stage('Terraform Plan')        { steps { sh 'terraform plan -out=tfplan' } }
    stage('Terraform Apply')       { steps { sh 'terraform apply -auto-approve tfplan' } }
  }
}
