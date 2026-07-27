pipeline {
    agent any

    environment {
        DEV_REGISTRY  = "mubha/dev"
        PROD_REGISTRY = "mubha/prod"
        IMAGE_NAME    = "react-static-app"
        IMAGE_TAG     = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/devopsmuthuraman/Simple-React-application.git',
                    branch: "${BRANCH_NAME}"
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'chmod +x build.sh'
                sh "./build.sh ${BRANCH_NAME}"
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"

                        if (env.BRANCH_NAME == 'dev') {
                            sh "docker push ${DEV_REGISTRY}:${IMAGE_TAG}"
                        } else if (env.BRANCH_NAME == 'master') {
                            sh "docker push ${PROD_REGISTRY}:${IMAGE_TAG}"
                        } else {
                            echo "Branch is neither dev nor master. Skipping Docker push."
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                sh 'chmod +x deploy.sh'
                sh "./deploy.sh ${BRANCH_NAME}"
            }
        }
    }

    post {
        success {
            echo "Deployment completed successfully for branch ${BRANCH_NAME}!"
        }
        failure {
            echo "Pipeline failed. Check logs."
        }
    }
}
