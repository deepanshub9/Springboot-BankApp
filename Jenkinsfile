pipeline {
  agent any

  tools {
    maven 'Maven-3.8.6' 
    jdk 'JDK-11'        
  }

  environment {
    SONARQUBE_ENV     = 'SonarQube'
    SONAR_PROJECT_KEY = 'springboot'
    SONAR_PROJECT_NAME = 'springboot'
    SONAR_HOST_URL    = 'http://54.82.143.205:9000'
    SONAR_AUTH_TOKEN  = credentials('SONAR_AUTH_TOKEN')
    
    DOCKER_REGISTRY   = 'docker.io'
    DOCKER_IMAGE_NAME = 'bankapp'
    DOCKER_TAG        = "${BUILD_NUMBER}"
    DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
    
    KUBECONFIG        = credentials('kubeconfig')
    K8S_NAMESPACE     = 'bankapp'
    
    SNYK_TOKEN        = credentials('snyk-token')
  
    APP_NAME          = 'bankapp'
    APP_VERSION       = "${BUILD_NUMBER}"
  }

  stages {
    stage('Declarative: Tool Install') {
      steps {
        script {
          echo "Installing required tools and dependencies..."
          sh '''
            # Update package lists
            sudo apt-get update
            
            # Install Docker if not present
            if ! command -v docker &> /dev/null; then
              curl -fsSL https://get.docker.com -o get-docker.sh
              sh get-docker.sh
            fi
            
            # Install kubectl if not present
            if ! command -v kubectl &> /dev/null; then
              curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              chmod +x kubectl
              sudo mv kubectl /usr/local/bin/
            fi
            
            # Install Snyk if not present
            if ! command -v snyk &> /dev/null; then
              npm install -g snyk
            fi
            
            # Verify installations
            docker --version
            kubectl version --client
            snyk --version
          '''
        }
      }
    }

    stage('Build') {
      steps {
        echo "Building the application..."
        sh 'mvn clean compile'
      }
    }

    stage('Unit Tests') {
      steps {
        echo "Running unit tests..."
        sh 'mvn test'
      }
      post {
        always {
          publishTestResults(
            testResultsPattern: 'target/surefire-reports/*.xml',
            allowEmptyResults: true
          )
        }
      }
    }

    stage('Package') {
      steps {
        echo "Packaging the application..."
        sh 'mvn package -DskipTests'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        echo "Running SonarQube analysis..."
        withSonarQubeEnv("${SONARQUBE_ENV}") {
          sh """
            mvn clean verify sonar:sonar \\
              -Dsonar.projectKey=${SONAR_PROJECT_KEY} \\
              -Dsonar.projectName='${SONAR_PROJECT_NAME}' \\
              -Dsonar.host.url=${SONAR_HOST_URL} \\
              -Dsonar.token=${SONAR_AUTH_TOKEN}
          """
        }
      }
    }

    stage('Quality Gate') {
      steps {
        echo "Waiting for SonarQube Quality Gate..."
        timeout(time: 5, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('OWASP Dependency Check') {
      steps {
        echo "Running OWASP Dependency Check..."
        dependencyCheck additionalArguments: '''
          --format XML
          --format HTML
          --suppression suppression.xml
        ''', odcInstallation: 'OWASP-Dependency-Check'
        
        dependencyCheckPublisher pattern: 'dependency-check-report.xml'
      }
    }

    stage('Snyk Scan and Monitor') {
      steps {
        echo "Running Snyk security scan..."
        script {
          withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
            sh '''
              snyk auth $SNYK_TOKEN
              
              snyk test --severity-threshold=high --json > snyk-test-results.json || true
              
              snyk monitor --project-name="${APP_NAME}" || true
            '''
          }
        }
      }
      post {
        always {
          archiveArtifacts artifacts: 'snyk-test-results.json', allowEmptyArchive: true
        }
      }
    }

    stage('Docker Build & Push') {
      steps {
        echo "Building and pushing Docker image..."
        script {
          withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', 
                                          usernameVariable: 'DOCKER_USERNAME', 
                                          passwordVariable: 'DOCKER_PASSWORD')]) {
            sh '''
             
              echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
              
             
              docker build -t $DOCKER_USERNAME/${DOCKER_IMAGE_NAME}:${DOCKER_TAG} .
              docker build -t $DOCKER_USERNAME/${DOCKER_IMAGE_NAME}:latest .
              
             
              docker push $DOCKER_USERNAME/${DOCKER_IMAGE_NAME}:${DOCKER_TAG}
              docker push $DOCKER_USERNAME/${DOCKER_IMAGE_NAME}:latest
              
              docker rmi $DOCKER_USERNAME/${DOCKER_IMAGE_NAME}:${DOCKER_TAG} || true
              docker rmi $DOCKER_USERNAME/${DOCKER_IMAGE_NAME}:latest || true
            '''
          }
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        echo "Deploying to Kubernetes cluster..."
        script {
          withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
            sh '''
        
              export KUBECONFIG=$KUBECONFIG_FILE
              
            
              kubectl create namespace ${K8S_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
              
            
              sed -i "s|image: .*bankapp.*|image: ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${DOCKER_TAG}|g" kubernetes/bankapp-deployment.yml
              
            
              kubectl apply -f kubernetes/ -n ${K8S_NAMESPACE}
              
      
              kubectl rollout status deployment/bankapp-deployment -n ${K8S_NAMESPACE} --timeout=300s
            '''
          }
        }
      }
    }

    stage('Deploy Verification') {
      steps {
        echo "Verifying deployment..."
        script {
          withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
            sh '''
              export KUBECONFIG=$KUBECONFIG_FILE
              
          
              kubectl get deployments -n ${K8S_NAMESPACE}
              kubectl get pods -n ${K8S_NAMESPACE}
              kubectl get services -n ${K8S_NAMESPACE}
              
   
              kubectl wait --for=condition=ready pod -l app=bankapp -n ${K8S_NAMESPACE} --timeout=300s
              
            
              EXTERNAL_IP=$(kubectl get service bankapp-service -n ${K8S_NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
              if [ -z "$EXTERNAL_IP" ]; then
                EXTERNAL_IP=$(kubectl get service bankapp-service -n ${K8S_NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
              fi
              
              echo "Application deployed successfully!"
              echo "Application URL: http://$EXTERNAL_IP"
              
              # Basic health check
              sleep 30
              if [ ! -z "$EXTERNAL_IP" ]; then
                curl -f http://$EXTERNAL_IP/actuator/health || echo "Health check failed, but deployment completed"
              fi
            '''
          }
        }
      }
    }
  }

  post {
    always {
      echo "Pipeline execution completed"
      
     
      cleanWs()
      
    
      archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
      archiveArtifacts artifacts: 'dependency-check-report.*', allowEmptyArchive: true
    }
    
    success {
      echo "Pipeline completed successfully!"
      
      
      emailext (
        subject: "✅ SUCCESS: Jenkins Pipeline - ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
        body: """
          <h2>Build Successful!</h2>
          <p><strong>Job:</strong> ${env.JOB_NAME}</p>
          <p><strong>Build Number:</strong> ${env.BUILD_NUMBER}</p>
          <p><strong>Build URL:</strong> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
          <p><strong>Docker Image:</strong> ${env.DOCKER_USERNAME}/${env.DOCKER_IMAGE_NAME}:${env.DOCKER_TAG}</p>
          <p>The application has been successfully deployed to Kubernetes!</p>
        """,
        mimeType: 'text/html',
        to: "${env.CHANGE_AUTHOR_EMAIL}"
      )
    }
    
    failure {
      echo "Pipeline failed!"
      
    
      emailext (
        subject: "❌ FAILURE: Jenkins Pipeline - ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
        body: """
          <h2>Build Failed!</h2>
          <p><strong>Job:</strong> ${env.JOB_NAME}</p>
          <p><strong>Build Number:</strong> ${env.BUILD_NUMBER}</p>
          <p><strong>Build URL:</strong> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
          <p><strong>Console Output:</strong> <a href="${env.BUILD_URL}console">${env.BUILD_URL}console</a></p>
          <p>Please check the console output for details.</p>
        """,
        mimeType: 'text/html',
        to: "${env.CHANGE_AUTHOR_EMAIL}"
      )
    }
    
    unstable {
      echo "Pipeline completed with warnings"
      
  
      emailext (
        subject: "⚠️ UNSTABLE: Jenkins Pipeline - ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
        body: """
          <h2>Build Unstable!</h2>
          <p><strong>Job:</strong> ${env.JOB_NAME}</p>
          <p><strong>Build Number:</strong> ${env.BUILD_NUMBER}</p>
          <p><strong>Build URL:</strong> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
          <p>The build completed but with some warnings or test failures.</p>
        """,
        mimeType: 'text/html',
        to: "${env.CHANGE_AUTHOR_EMAIL}"
      )
    }
  }
}