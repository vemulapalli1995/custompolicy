pipeline {
  agent any

  environment {
    // Pull the token from Jenkins Credentials (do NOT hardcode secrets)
    SONAR_TOKEN        = credentials('sonar-token')        // Jenkins credential ID

    // Resolve SonarScanner from Tools (wrap tool() in "${ }")
    SONAR_SCANNER_HOME = "${tool 'sonarqube'}"
  }

  stages {

    stage('Git Checkout') {
      steps {
        git branch: 'main',
            url: 'https://github.com/vemulapalli1995/custompolicy.git'   // note the .git suffix
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('sonarserver') {  // must match configured SonarQube server name
          sh '''
            "${SONAR_SCANNER_HOME}/bin/sonar-scanner" \
              -Dsonar.projectKey=myprof-projects_project10 \
              -Dsonar.sources=. \
              -Dsonar.host.url=http://4.205.120.86:9000 \
              -Dsonar.login="${SONAR_TOKEN}"
          '''
        }
      }
    }

    // If you prefer quality gate waiting, you can add a waitForQualityGate stage instead of re-running
    stage('Publish SonarQube Results') {
      steps {
        echo 'Re-running scanner to publish results without quality gate blocking...'
        withSonarQubeEnv('sonarserver') {
          sh '''
            "${SONAR_SCANNER_HOME}/bin/sonar-scanner" \
              -Dsonar.projectKey=myprof-projects_project10 \
              -Dsonar.sources=. \
              -Dsonar.host.url=http://4.205.120.86:9000 \
              -Dsonar.login="${SONAR_TOKEN}" \
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
          // Optional: add your subscription as a secret text and uncomment below
          // , string(credentialsId: 'azure-subscription', variable: 'AZURE_SUBSCRIPTION_ID')
        ]) {
          sh '''
            az login --service-principal -u "$AZURE_APP_ID" -p "$AZURE_PASSWORD" --tenant "$AZURE_TENANT"
            # Set subscription context (uncomment and set if you added azure-subscription)
            # az account set --subscription "$AZURE_SUBSCRIPTION_ID"
          '''

          // Alternatively export ARM_* for Terraform instead of az account set:
          // withEnv([
          //   "ARM_TENANT_ID=$AZURE_TENANT",
          //   "ARM_CLIENT_ID=$AZURE_APP_ID",
          //   "ARM_CLIENT_SECRET=$AZURE_PASSWORD",
          //   "ARM_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID"
          // ]) { /* subsequent terraform steps will inherit */ }
        }
      }
    }

    stage('Terraform Initialize') {
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
}
