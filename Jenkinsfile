pipeline {
    agent any

    parameters {
        choice(name: 'SERVICE_NAME', choices: ['service-nginx', 'service-node'], description: 'Select service to deploy')
        string(name: 'VERSION', defaultValue: 'v1', description: 'Docker image version')
    }

    environment {
        DOCKER_HUB_USER = '<your-docker-hub-username>'
    }

    stages {
        stage('Build Docker Image') {
            steps {
                dir("${params.SERVICE_NAME}") {
                    sh "docker build -t ${DOCKER_HUB_USER}/${params.SERVICE_NAME}:${params.VERSION} ."
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_HUB_USER}/${SERVICE_NAME}:${VERSION}
                    '''
                }
            }
        }

        stage('Deploy with Ansible') {
            steps {
                sshagent(credentials: ['ec2-ssh-key']) {
                    sh '''
                        ansible-playbook -i inventory.ini deploy-playbook.yml \
                        --extra-vars "service_name=${SERVICE_NAME} image_tag=${VERSION}"
                    '''
                }
            }
        }
    }
}