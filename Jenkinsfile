pipeline{
  agent any
  tools{
    jdk 'java11'
    nodejs 'nodejs'
  }
  environment{
    SCANNER_HOME = tool('sonar-scanner')
    APP_NAME = "reddit-clone-app"
    DOCKER_USER = "rutvikg"
    DOCKER_PASS = "dockerhub"
    IMAGE_NAME = "${DOCKER_USER}" + "/" + "${APP_NAME}"
    IMAGE_TAG = "${BUILD_NUMBER}"
  }
  stages{
    stage("cleaning workspace"){
      steps{
        cleanWs()
      }
    }
    stage("code checkout"){
      steps{
        git branch: "main", url: "https://github.com/Rutvikgalale/reddit-clone-app.git"
      }
    }
    stage("sonarqube analysis"){
      steps{
        withSonarQubeEnv("sonar-server"){
          sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=reddit-clone-CI \
          -Dsonar.projectKey=reddit-clone-CI \
          -Dsonar.sources=. \
          -Dsonar.exclusions=**/*.js,**/*.ts
             '''
        }
      }
    }
    stage("Quality Gate"){
      steps{
        waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
      }
    }
    stage("install dependencies"){
      steps{
        sh "npm install"
      }
    }
    stage("docker build"){
      steps{
        sh "docker build -t reddit-app ."
      }
    }
    stage("trivy fs scan"){
      steps{
        sh "trivy fs . > trivyfs.txt"
      }
    }
  }
}
