pipeline {
    agent any

    parameters {
        choice(name: 'SERVICE_NAME', choices: ['service1-nginx', 'service2-node'], description: 'Select service to deploy')
        string(name: 'VERSION', defaultValue: 'v1', description: 'Docker image version')
    }

    environment {
        DOCKER_HUB_USER = 'edensit139'
    }

    stages {
        stage('Build Docker Image') {
            steps {
                dir("${params.SERVICE_NAME}") {
                    script {
                        docker.build("${DOCKER_HUB_USER}/${params.SERVICE_NAME}:${params.VERSION}")
                    }
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        sh "docker push ${DOCKER_HUB_USER}/${params.SERVICE_NAME}:${params.VERSION}"
                    }
                }
            }
        }

        stage('Deploy with Ansible') {
            steps {
                sh """
                ansible-playbook -i inventory.ini deploy-playbook.yml \
                --extra-vars "service_name=${params.SERVICE_NAME} image_tag=${params.VERSION}"
                """
            }
        }
    }
}
