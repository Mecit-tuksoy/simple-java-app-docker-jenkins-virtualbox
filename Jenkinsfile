pipeline {
    agent any 

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_USERNAME = 'mecit35'
    }

    stages {
        stage('Clone repository') {
            steps {
                sh 'rm -rf simple-java-container-CI-CD || true'
                sh 'git clone https://github.com/Mecit-tuksoy/simple-java-container-CI-CD.git'
            }
        }

        stage('Package Application') {
            steps {
                echo 'Compiling source code'
                sh '. ./jenkins/package-application.sh'
            }
        }
        
        stage('Prepare Tags for Docker Images') {
            steps {
                echo 'Preparing Tags for Docker Images'
                script {
                    MVN_VERSION = sh(script: '. ${WORKSPACE}/target/maven-archiver/pom.properties && echo $version', returnStdout: true).trim()
                    env.IMAGE_TAG = "my-java-app-v${MVN_VERSION}".toLowerCase()
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build --force-rm -t ${IMAGE_TAG} .'
            }
        }
                        

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKERHUB_CREDENTIALS_PSW', usernameVariable: 'DOCKERHUB_CREDENTIALS_USR')]) {
                        sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                        sh "docker tag ${IMAGE_TAG}:latest ${DOCKER_USERNAME}/${IMAGE_TAG}:latest"
                        sh "docker push ${DOCKER_USERNAME}/${IMAGE_TAG}:latest"
                        }
                    }
                }
            }
        
    

        stage('Deploy on other linux machine') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'deploy-credentials', passwordVariable: 'DEPLOY_PASSWORD', usernameVariable: 'DEPLOY_USER')]) {
                    sh '''
                      sshpass -p "${DEPLOY_PASSWORD}" ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_MACHINE} "
                          echo 'Connected to deploy machine'
                      "
                    '''
                }

                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKERHUB_CREDENTIALS_PSW', usernameVariable: 'DOCKERHUB_CREDENTIALS_USR')]) {
                    sh '''
                      echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                      docker rmi ${DOCKER_USERNAME}/${IMAGE_TAG}:latest || true
                      docker pull ${DOCKER_USERNAME}/${IMAGE_TAG}:latest
                      docker run -d -p 9090:9090 ${DOCKER_USERNAME}/${IMAGE_TAG}:latest
                      sleep 30
                      curl http://${DEPLOY_MACHINE}:9090
                    '''  
            }         
        }
    }
}

