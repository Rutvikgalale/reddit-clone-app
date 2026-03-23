pipeline {
  agent any
  tools {
    jdk 'java11'
    nodejs 'nodejs'
  }
  environment {
    SCANNER_HOME = tool('sonar-scanner')
    APP_NAME = "reddit-clone-app"
    DOCKER_USER = "rutvikg"
    DOCKER_PASS = "dockerhub"
    IMAGE_NAME = "${DOCKER_USER}/${APP_NAME}"
    IMAGE_TAG = "${BUILD_NUMBER}"
  }
  stages {
    stage("cleaning workspace") {
      steps {
        cleanWs()
      }
    }
    stage("code checkout") {
      steps {
        git branch: "main", url: "https://github.com/Rutvikgalale/reddit-clone-app.git"
      }
    }
    stage("sonarqube analysis") {
      steps {
        withSonarQubeEnv("sonar-server") {
          sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=reddit-clone-CI \
          -Dsonar.projectKey=reddit-clone-CI \
          -Dsonar.sources=. \
          -Dsonar.exclusions=**/*.js,**/*.ts
          '''
        }
      }
    }
    stage("Quality Gate") {
      steps {
        waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
      }
    }
    stage("install dependencies") {
      steps {
        // Skip peer dependency conflicts
        sh "npm install --legacy-peer-deps"
      }
    }
    stage("trivy fs scan") {
      steps {
        sh "trivy fs . > trivyfs.txt || true"
      }
    }
    stage("docker build") {
      steps {
        sh "docker build -t ${APP_NAME} ."
        sh "docker tag ${APP_NAME} ${IMAGE_NAME}:${IMAGE_TAG}"
      }
    }
    stage("Trivy Image Scan") {
      steps {
        script {
          sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:0.49.1 image ${IMAGE_NAME}:${IMAGE_TAG} --no-progress --scanners vuln  --exit-code 0 --severity HIGH,CRITICAL --format table > trivyimage.txt"
        }
      }
    }
    stage("docker push") {
      steps {
        withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh """
          echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
          docker push ${IMAGE_NAME}:${IMAGE_TAG}
          """
        }
      }
    }
    stage("cleaning artifact"){
      steps{
        sh """
          
           echo "Stopping and removing containers..."
           docker ps -aq | xargs -r docker rm -f

           docker rmi -f ${IMAGE_NAME}:${IMAGE_TAG} || true"
           docker rmi -f ${IMAGE_NAME}:latest || true"
           docker image prune -af || true"
           """
      }
    }
  }
   post{
   always{
      emailtext attachLog: true,
          subject: "'${currentBuild.result}'",
          body: "Project: ${env.JOB_NAME}<br/>" +
              "Build Number: ${env.BUILD_NUMBER}<br/>" +
              "URL: ${env.BUILD_URL}<br/>",
          to: 'rutvikgalale@gmail.com',
          attachmentsPattern: 'trivyfs.txt,trivyimage.txt'
    }
  }
}
