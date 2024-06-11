pipeline {
    agent any // This tells Jenkins to use any available agent to run the pipeline

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_USERNAME = 'mecit35'
        REMOTE_HOST = 'nginx'
        REMOTE_USER = 'mecit_tuksoy'
        PROJEKT_ID = 'deneme-426109'
        GCLOUD_CREDS = credentials('gcloud-creds')
        ZONE = 'us-central1-a'

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
                        

        stage('Check and Push Docker Image') {
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
        
    

        stage('Test Google Cloud SDK') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKERHUB_CREDENTIALS_PSW', usernameVariable: 'DOCKERHUB_CREDENTIALS_USR')]) {
                    sh '''
                      gcloud version
                      gcloud auth activate-service-account --key-file="$GCLOUD_CREDS"
                      gcloud compute ssh ${REMOTE_USER}@${REMOTE_HOST} --zone=${ZONE} --project=${PROJEKT_ID} --command="
                          echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                          docker pull ${DOCKER_USERNAME}/${IMAGE_TAG}:latest
                          docker run -d -p 8080:8080 ${DOCKER_USERNAME}/${IMAGE_TAG}:latest
                          sleep 30
                          curl http://localhost:8080
                      "
                    '''
                }
            }         
        }
    }
}

