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
          sh """
            $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=reddit-clone-CI \
              -Dsonar.projectKey=reddit-clone-CI \
              -Dsonar.sources=. \
              -Dsonar.exclusions=**/node_modules/**,**/coverage/**,**/*.spec.js,**/*.test.ts \
              -Dsonar.sourceEncoding=UTF-8 \
              -Dsonar.typescript.tsconfigPath=tsconfig.json
          """
        }
      }
    }
    /*
    stage("Quality Gate") {
      steps {
        waitForQualityGate abortPipeline: true, credentialsId: 'sonar-token'
      }
    }
    */
    
    stage("install dependencies") {
      steps {
        // Skip peer dependency conflicts
        sh "npm ci --legacy-peer-deps"
      }
    }
    stage("trivy fs scan") {
      steps {
        sh "trivy fs . --exit-code 0 --severity HIGH,CRITICAL --format table > trivyfs.txt"
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
    stage("trigger downstream") {
      steps {
        build job: 'reddit-clone-app',
          parameters: [string(name: 'IMAGE_TAG', value: IMAGE_TAG)],
          propagate: false,
          wait: false
      }
    }

    stage("docker push") {
    steps {
        withCredentials([string(credentialsId: 'JENKINS_API_TOKEN', variable: 'JENKINS_API_TOKEN')]) {
            script {
                sh """
                curl -v -k --user admin:${env.JENKINS_API_TOKEN} \
                  -X POST \
                  -H 'cache-control: no-cache' \
                  -H 'content-type: application/x-www-form-urlencoded' \
                  --data 'IMAGE_TAG=${IMAGE_TAG}' \
                  'http://ec2-65-0-97-54.ap-south-1.compute.amazonaws.com:8080/job/reddit-clone-app/buildWithParameters?token=gitops-token'
                """
            }
        }
    }
}

    stage("cleaning artifact"){
      steps{
        sh """
          
           echo "Stopping and removing containers..."
           docker ps -aq | xargs -r docker rm -f

           docker rmi -f ${IMAGE_NAME}:${IMAGE_TAG} || true
           docker rmi -f ${IMAGE_NAME}:latest || true
           docker image prune -af || true
           """
      }
    }
  }
   post {
    always {
        emailext(
            attachLog: true,
            subject: "${currentBuild.currentResult}",
            body: """
                Project: ${env.JOB_NAME}<br/>
                Build Number: ${env.BUILD_NUMBER}<br/>
                URL: <a href="${env.BUILD_URL}">${env.BUILD_URL}</a><br/>
            """,
            mimeType: 'text/html',
            to: 'rutvikgalale@gmail.com',
            attachmentsPattern: 'trivyfs.txt,trivyimage.txt'
        )
    }
   }
}
