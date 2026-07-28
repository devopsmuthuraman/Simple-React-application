pipeline {
    agent any

    parameters {
        choice(
            name: 'BRANCH_NAME',
            choices: ['dev', 'main'],
            description: 'Select the branch to build and deploy'
        )
    }

    environment {
        DEV_REGISTRY  = "mubha/dev"
        PROD_REGISTRY = "mubha/prod"
        IMAGE_TAG     = "latest"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: "${params.BRANCH_NAME}",
                    url: 'https://github.com/devopsmuthuraman/Simple-React-application.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    chmod +x build.sh
                    ./build.sh ${BRANCH_NAME}
                '''
            }
        }

        stage('Login to DockerHub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {

                    sh '''
                        echo "$DOCKER_PASS" | docker login \
                        -u "$DOCKER_USER" \
                        --password-stdin
                    '''
                }
            }
        }

        stage('Push Image') {

            steps {

                script {

                    if (params.BRANCH_NAME == "dev") {

                        sh "docker push ${DEV_REGISTRY}:${IMAGE_TAG}"

                    } else if (params.BRANCH_NAME == "main") {

                        sh "docker push ${PROD_REGISTRY}:${IMAGE_TAG}"

                    }

                }

            }

        }

        stage('Deploy') {

            steps {

                sh '''
                    chmod +x deploy.sh
                    ./deploy.sh ${BRANCH_NAME}
                '''

            }

        }

        stage('Logout DockerHub') {
            steps {
                sh 'docker logout'
            }
        }

    }

    post {

        success {

            echo "Pipeline completed successfully."

        }

        failure {

            echo "Pipeline failed."

        }

    }

}