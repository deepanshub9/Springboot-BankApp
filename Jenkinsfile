pipeline {
  agent any

  tools {
    maven 'Maven-3.8.6'  // ✅ Matches the configured Maven tool name
    // Remove or update JDK if needed; currently no valid "Java 21" install
  }

  environment {
    SONARQUBE_ENV     = 'SonarQube'
    SONAR_PROJECT_KEY = 'springboot'
    SONAR_PROJECT_NAME = 'springboot'
    SONAR_HOST_URL    = 'http://54.82.143.205:9000'
    SONAR_AUTH_TOKEN  = credentials('SONAR_AUTH_TOKEN')  // ✅ Secure token from Jenkins credentials
  }

  stages {
    stage('Build') {
      steps {
        sh 'mvn clean package -DskipTests'
      }
    }

    stage('SonarQube Analysis') {
      steps {
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
        timeout(time: 2, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }
  }
}

