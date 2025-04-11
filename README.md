
# Jenkins + Docker + Ansible (Parameterized Pipeline)

---

This guide walks you through setting up a Jenkins CI/CD pipeline that allows users to **select which service to deploy** (`service-nginx` or `service-node`) via parameters. The pipeline will:

- Build a Docker image of the selected service
- Push the image to DockerHub
- Deploy the service using Ansible to a remote EC2 instance

---

## 📁 Project Structure

```bash
.
├── service-nginx/
│   ├── Dockerfile
│   └── index.html
├── service-node/
│   ├── Dockerfile
│   └── app.js
├── Jenkinsfile
├── inventory.ini
├── deploy-playbook.yml
└── README.md
```

---

## 🛠️ Prerequisites

### On your local or EC2 server:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Add current user to Docker group
sudo usermod -aG docker $USER
newgrp docker
```

---

## 🐳 Build Jenkins with Docker & Ansible

### Dockerfile.custom

Create a file called `Dockerfile.custom`:

```Dockerfile
FROM jenkins/jenkins:lts

USER root

RUN apt-get update && \
    apt-get install -y docker.io ansible && \
    apt-get clean

USER jenkins
```

### Build the image:

```bash
docker build -t custom-jenkins:latest -f Dockerfile.custom .
```

### Run the Jenkins container:

```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /usr/bin/docker:/usr/bin/docker \
  -u root \
  custom-jenkins:latest
```

---

## 🌐 Access Jenkins

Open Jenkins in your browser:  
`http://<your-ec2-ip>:8080`

Get the initial admin password:

```bash
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

---

## 🔐 Credentials Setup

Inside Jenkins:

1. Go to **Manage Jenkins → Credentials → Global → Add Credentials**
2. Add DockerHub credentials (username/password) → ID: `dockerhub-creds`
3. Add SSH private key for EC2 instance → ID: `ec2-ssh-key`

---

## 🧪 Jenkinsfile Parameters

```groovy
parameters {
    choice(name: 'SERVICE_NAME', choices: ['service-nginx', 'service-node'], description: 'Select service to deploy')
    string(name: 'VERSION', defaultValue: 'v1', description: 'Docker image version')
}
```

- `SERVICE_NAME`: Select the service to deploy.
- `VERSION`: Choose the tag version for Docker image.

---

## 📦 Pipeline Stages

1. **Build Docker Image**
   - Uses the selected service folder and builds the Docker image.
2. **Push to DockerHub**
   - Pushes the tagged image to your DockerHub account.
3. **Deploy with Ansible**
   - Runs a playbook that deploys the container to a remote host based on selected service.

---

## 📄 inventory.ini

```ini
[all]
<YOUR_EC2_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
```

---

## 📜 deploy-playbook.yml

```yaml
- hosts: all
  become: yes
  vars:
    service: "{{ service_name }}"
    tag: "{{ image_tag }}"
  tasks:
    - name: Define ports based on service
      set_fact:
        host_port: "{{ '8081' if service == 'service-nginx' else '8082' }}"
        container_port: "{{ '80' if service == 'service-nginx' else '3000' }}"

    - name: Run Docker container
      docker_container:
        name: "{{ service }}"
        image: "<yourDockerUser>/{{ service }}:{{ tag }}"
        state: started
        ports:
          - "{{ host_port }}:{{ container_port }}"
```

---

## ✅ Example Jenkins Pipeline Run

When you run the job:

- Select `service-node`
- Set `VERSION` to `v1`
- Jenkins builds and pushes `<youDockerUser>/service-node:v1`
- Ansible deploys it to port `8082`

---

## 🧹 Cleanup

```bash
docker rm -f jenkins
docker rmi custom-jenkins:latest
```
