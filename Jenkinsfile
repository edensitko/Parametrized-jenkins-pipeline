pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'edensit139'
        IMAGE_NAME = 'eden-app'
        VERSION = 'v1.0.4'
    }

    stages {
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKERHUB_USER/$IMAGE_NAME:$VERSION .'
            }
        }

         stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-pass', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push edensit139/eden-app:v1.0.0
                    '''
                }
            }
        }


        stage('Deploy with Ansible') {
            steps {
                sh 'ansible-playbook deploy-playbook.yml -i inventory.ini'
            }
        }
    }

    post {
        success {
            echo "✅ הפרויקט נבנה והופץ בהצלחה!"
        }
        failure {
            echo "❌ הבנייה נכשלה, בדוק את ה־Console ."
        }
    }
}
