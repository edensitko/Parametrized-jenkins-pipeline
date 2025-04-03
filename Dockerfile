FROM jenkins/jenkins:lts

USER root

# התקנת Docker CLI
RUN apt-get update && \
    apt-get install -y docker.io docker-compose git ansible && \
    usermod -aG docker jenkins

# חזרה ל־Jenkins user
USER jenkins
