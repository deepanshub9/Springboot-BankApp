# 🏦 Spring Boot Banking Application Deployment using DevSecOps on AWS EKS

![Java](https://img.shields.io/badge/Java-17-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.3.3-brightgreen)
![MySQL](https://img.shields.io/badge/MySQL-8.0-blue)
![Maven](https://img.shields.io/badge/Maven-3.8+-red)
![Docker](https://img.shields.io/badge/Docker-Enabled-blue)

A comprehensive, secure banking web application built with Spring Boot, featuring modern web technologies and enterprise-grade security. This application provides essential banking operations with a user-friendly interface and robust backend architecture.

- This is a multi-tier bank an application written in Java (Springboot).

![Login diagram](<img width="1913" height="961" alt="Image" src="https://github.com/user-attachments/assets/959c2625-5f4f-4b3c-8002-4e279ddb32c9" />)
![Transactions diagram](<img width="1913" height="874" alt="Image" src="https://github.com/user-attachments/assets/eedecfc1-d817-41fc-9ded-e68462aa1b08" />)

## Tech stack used in this project:

- GitHub (Code)
- Docker (Containerization)
- Jenkins (CI)
- OWASP (Dependency check)
- SonarQube (Quality)
- Snyk (AI vulnerability)
- ArgoCD (CD)
- AWS EKS (Kubernetes)
- Helm (Monitoring using grafana and prometheus)

### Steps to deploy:

### Pre-requisites:

- root user access

```bash
sudo su
```

#

> [!Note]
> This project will be implemented on North Virginia region (us-east-1).

- <b>Create 1 Master machine on AWS (t3.large) and 25 GB of storage.</b>

#

- <b>Open the below ports in security group</b>
  ![image](https://github.com/user-attachments/assets/4e5ecd37-fe2e-4e4b-a6ba-14c7b62715a3)

- <b id="EKS">Create EKS Cluster on AWS</b>
- IAM user with **access keys and secret access keys**
- AWSCLI should be configured

  ```bash
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  sudo apt install unzip
  unzip awscliv2.zip
  sudo ./aws/install
  aws configure
  ```

- Install **kubectl**

  ```bash
  curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin
  kubectl version --short --client
  ```

- Install **eksctl**
  ```bash
  curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
  sudo mv /tmp/eksctl /usr/local/bin
  eksctl version
  ```
- <b>Create EKS Cluster</b>
  ```bash
  eksctl create cluster --name=bankapp \
                      --region=us-west-1 \
                      --version=1.30 \
                      --without-nodegroup
  ```
- <b>Associate IAM OIDC Provider</b>
  ```bash
  eksctl utils associate-iam-oidc-provider \
    --region us-west-1 \
    --cluster bankapp \
    --approve
  ```
- <b>Create Nodegroup</b>
  ```bash
  eksctl create nodegroup --cluster=bankapp \
                       --region=us-east-1 \
                       --name=bankapp \
                       --node-type=t3.medium \
                       --nodes=2 \
                       --nodes-min=2 \
                       --nodes-max=2 \
                       --node-volume-size=25 \
                       --ssh-access \
                       --ssh-public-key=eks-nodegroup-key
  ```

> [!Note]
> Make sure the ssh-public-key "eks-nodegroup-key is available in your aws account"

- <b>Install Jenkins</b>

```bash
sudo apt update -y
sudo apt install fontconfig openjdk-17-jre -y

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y
sudo apt-get install jenkins -y
```

- After installing Jenkins, change the default port of jenkins from 8080 to 8081. Because our bankapp application will be running on 8080.

  - Open /usr/lib/systemd/system/jenkins.service file and change JENKINS_PORT environment variable
    ![image](https://github.com/user-attachments/assets/6320ae49-82d4-4ae3-9811-bd6f06778483)
  - Reload daemon

  ```bash
  sudo systemctl daemon-reload
  ```

  - Restart Jenkins

  ```bash
  sudo systemctl restart jenkins
  ```

#

- <b id="docker">Install docker</b>

```bash
sudo apt install docker.io -y
sudo usermod -aG docker ubuntu && newgrp docker
```

#

- <b id="Sonar">Install and configure SonarQube</b>

```bash
docker pull sonarqube

docker run -d --name sonarqube -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true -p 9000:9000 sonarqube:latest
```

#

- <b id="OWASP">Install OWASP</b>

```bash
docker pull owasp/dependency-check
```

<img width="1892" height="887" alt="Image" src="https://github.com/user-attachments/assets/8208f425-2847-4d25-861a-5b65581a613b" />

> [!Note]
> OWASP setup take around 10-20min first its download all the vulnerability from there database into you system. With API key your process becomes quit faster. "

You can request you OWASP API key (FREE) <a href="https://nvd.nist.gov/developers/request-an-api-key">Link</a>

#

- <b id="Argo">Install and Configure ArgoCD</b>

  - <b>Create argocd namespace</b>

  ```bash
  kubectl create namespace argocd
  ```

  - <b>Apply argocd manifest</b>

  ```bash
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  ```

  - <b>Make sure all pods are running in argocd namespace</b>

  ```bash
  watch kubectl get pods -n argocd
  ```

  - <b>Install argocd CLI</b>

  ```bash
  curl --silent --location -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.4.7/argocd-linux-amd64
  ```

  - <b>Provide executable permission</b>

  ```bash
  chmod +x /usr/local/bin/argocd
  ```

  - <b>Check argocd services</b>

  ```bash
  kubectl get svc -n argocd
  ```

  - <b>Change argocd server's service from ClusterIP to NodePort</b>

  ```bash
  kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
  ```

  - <b>Confirm service is patched or not</b>

  ```bash
  kubectl get svc -n argocd
  ```

  - <b> Check the port where ArgoCD server is running and expose it on security groups of a k8s worker node</b>

  - <b>Access it on browser, click on advance and proceed with</b>

  ```bash
  <public-ip-worker>:<port>
  ```

  <img width="1326" height="669" alt="Image" src="https://github.com/user-attachments/assets/80c4d86a-cf5c-4b7d-904d-9bd425ac23e7" />

<img width="1899" height="886" alt="Image" src="https://github.com/user-attachments/assets/9bb6656e-5a80-480e-9ed2-f309d90a1f33" />

- <b>Fetch the initial password of argocd server</b>

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

- <b>Username: admin</b>
- <b> Now, go to <mark>User Info</mark> and update your argocd password

#

- <b>Go to Jenkins and click on <mark> Manage Jenkins --> Plugins --> Available plugins</mark> install the below plugins:</b>
  - OWASP
  - SonarQube Scanner
  - Synk
  - Docker
  - Pipeline: Stage View

#

- <b id="Owasp">Configure OWASP, move to <mark>Manage Jenkins --> Plugins --> Available plugins</mark>b>
  ![image](https://github.com/user-attachments/assets/da6a26d3-f742-4ea8-86b7-107b1650a7c2)

- <b id="Sonar">After OWASP plugin is installed, Now move to <mark>Manage jenkins --> Tools and configure it.</mark></b>

- <b id="Sonar">After Synk plugin is installed, Now move to <mark>Manage --> Tools and configure it.</mark></b>

<img width="1896" height="872" alt="Image" src="https://github.com/user-attachments/assets/20067f0e-e50e-41bd-93c1-edaa4cde288d" />

#

- <b>Login to SonarQube server and create the credentials for jenkins to integrate with SonarQube</b>
  - Navigate to <mark>Administration --> Security --> Users --> Token and paste into inside your jenkins credentials </mark>

#

- <b>Now, go to <mark> Manage Jenkins --> credentials</mark> and add Sonarqube credentials:</b>
  ![image](https://github.com/user-attachments/assets/0688e105-2170-4c3f-87a3-128c1a05a0b8)

#

- <b>Go to <mark> Manage Jenkins --> Tools</mark> and search for SonarQube Scanner installations:</b>
  ![image](https://github.com/user-attachments/assets/2fdc1e56-f78c-43d2-914a-104ec2c8ea86)

#

- <b>Go to <mark> Manage Jenkins --> credentials</mark> and add Docker credentials to push updated the updated docker image to dockerhub.</b>
  ![image](https://github.com/user-attachments/assets/77402c9c-fc2f-4df7-9a06-09f3f4c38751)

#

- <b>Go to <mark> Manage Jenkins --> System</mark> and search for SonarQube installations:</b>
  ![image](https://github.com/user-attachments/assets/ae866185-cb2b-4e83-825b-a125ec97243a)

#

- <b>Now again, Go to <mark> Manage Jenkins --> System</mark> and search for Global Trusted Pipeline Libraries:</b
  ![image](https://github.com/user-attachments/assets/874b2e03-49b9-4c26-9b0f-bd07ce70c0f1)
  ![image](https://github.com/user-attachments/assets/1ca83b43-ce85-4970-941d-9a819ce4ecfd)

#

- <b>Login to SonarQube server, go to <mark>Administration --> Webhook</mark> and click on create </b>
  ![image](https://github.com/user-attachments/assets/16527e72-6691-4fdf-a8d2-83dd27a085cb)
  ![image](https://github.com/user-attachments/assets/a8b45948-766a-49a4-b779-91ac3ce0443c)

<img width="1877" height="889" alt="Image" src="https://github.com/user-attachments/assets/e899de37-ef97-48a4-921a-bdb42da79fc6" />

#

#

- <b> Go to Master Machine and add our own eks cluster to argocd for application deployment using cli</b>

  - <b>Login to argoCD from CLI</b>

  ```bash
   argocd login 52.53.156.187:32738 --username admin
  ```

  > [!Tip]
  > 52.53.156.187:32738 --> This should be your argocd url

  ![image](https://github.com/user-attachments/assets/7d05e5ca-1a16-4054-a321-b99270ca0bf9)

  - <b>Check how many clusters are available in argocd </b>

  ```bash
  argocd cluster list
  ```

  ![image](https://github.com/user-attachments/assets/76fe7a45-e05c-422d-9652-bdaee02d630f)

  - <b>Get your cluster name</b>

  ```bash
  kubectl config get-contexts
  ```

  - <b>Add your cluster to argocd</b>

  ```bash
  argocd cluster add bankapp-cluster.us-east-1.eksctl.io --name bankapp-eks-cluster
  ```

  > [!Tip] > bankapp-cluster.us-east-1.eksctl.io --> This should be your EKS Cluster Name.

![image](https://github.com/user-attachments/assets/1061fe66-17ec-47b7-9d2e-371f58d3fd90)

- <b> Once your cluster is added to argocd, go to argocd console <mark>Settings --> Clusters</mark> and verify it</b>
  ![image](https://github.com/user-attachments/assets/6aebb871-4dea-4e09-955a-a4aa43b8f4ef)

#

- <b>Go to <mark>Settings --> Repositories</mark> and click on <mark>Connect repo</mark> </b>
  ![image](https://github.com/user-attachments/assets/cc8728e5-546b-4c46-bd4c-538f4cd6a63d)

> [!Note]
> Connection should be successful

- Create BankApp-CI job
  ![image](https://github.com/user-attachments/assets/17467b79-3110-470a-87a2-2bbfe197551b)
  <img width="1895" height="877" alt="Image" src="https://github.com/user-attachments/assets/44474526-b963-409e-aa34-34088d6ef602" />

- Create BankApp-CD job, same as CI job.

#

- <b>Provide permission to docker socket so that docker build and push command do not fail</b>

```bash
chmod 777 /var/run/docker.sock
```

![image](https://github.com/user-attachments/assets/e231c62a-7adb-4335-b67e-480758713dbf)

- <b>Now, go to <mark>Applications</mark> and click on <mark>New App</mark></b>

![image](https://github.com/user-attachments/assets/d5b08e06-6256-4f46-afdc-fc43a9e44562)

> [!Important]
> Make sure to click on the <mark>Auto-Create Namespace</mark> option while creating argocd application

![image](https://github.com/user-attachments/assets/a3aa1d22-50ef-4eb1-97fe-9c3ffb504fc3)

- <b>Congratulations, your application is deployed on AWS EKS Cluster</b>
  ![image](https://github.com/user-attachments/assets/03f3b69a-d6e0-42ad-992e-11124e7d0898)

- <b>Open port 30080 on worker node and Access it on browser</b>

```bash
<worker-public-ip>:30080
```

#

## How to monitor EKS cluster, kubernetes components and workloads using prometheus and grafana via HELM (On Master machine)

- <p id="Monitor">Install Helm Chart</p>

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
```

```bash
chmod 700 get_helm.sh
```

```bash
./get_helm.sh
```

#

- Add Helm Stable Charts for Your Local Client

```bash
helm repo add stable https://charts.helm.sh/stable
```

#

- Add Prometheus Helm Repository

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

#

- Create Prometheus Namespace

```bash
kubectl create namespace prometheus
```

```bash
kubectl get ns
```

#

- Install Prometheus using Helm

```bash
helm install stable prometheus-community/kube-prometheus-stack -n prometheus
```

#

- Verify prometheus installation

```bash
kubectl get pods -n prometheus
```

#

- Check the services file (svc) of the Prometheus

```bash
kubectl get svc -n prometheus
```

#

- Expose Prometheus and Grafana to the external world through Node Port
  > [!Important]
  > change it from Cluster IP to NodePort after changing make sure you save the file and open the assigned nodeport to the service.

<img width="1916" height="892" alt="Image" src="https://github.com/user-attachments/assets/9c2abcf0-0b49-4166-8197-f892d375e0fc" />

```bash
kubectl edit svc stable-kube-prometheus-sta-prometheus -n prometheus
```

![image](https://github.com/user-attachments/assets/90f5dc11-23de-457d-bbcb-944da350152e)
![image](https://github.com/user-attachments/assets/ed94f40f-c1f9-4f50-a340-a68594856cc7)

#

- Verify service

```bash
kubectl get svc -n prometheus
```

#

- Now,let’s change the SVC file of the Grafana and expose it to the outer world

```bash
kubectl edit svc stable-grafana -n prometheus
```

![image](https://github.com/user-attachments/assets/4a2afc1f-deba-48da-831e-49a63e1a8fb6)

#

- Check grafana service

```bash
kubectl get svc -n prometheus
```

#

- Get a password for grafana

```bash
kubectl get secret --namespace prometheus stable-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

> [!Note]
> Username: admin

#

- Now, view the Dashboard in Grafana

  ![image](https://github.com/user-attachments/assets/647b2b22-cd83-41c3-855d-7c60ae32195f)

 <img width="1918" height="889" alt="Image" src="https://github.com/user-attachments/assets/b7257f3b-1948-492a-b0de-f712c19b8ac8" />

<img width="1912" height="891" alt="Image" src="https://github.com/user-attachments/assets/92f13e66-d5d5-419b-8bfa-557ce13b2445" />

<img width="1899" height="887" alt="Image" src="https://github.com/user-attachments/assets/cf3ed6f0-5fe6-46a2-a01b-9ae5807eb36d" />

## Clean Up

- <b id="Clean">Delete eks cluster</b>

```bash
eksctl delete cluster --name=bankapp --region=us-east-1
```

---

## 📚 Additional Resources

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Spring Security Reference](https://spring.io/projects/spring-security)
- [MySQL Documentation](https://dev.mysql.com/doc/)
- [Docker Documentation](https://docs.docker.com/)
- [Maven User Guide](https://maven.apache.org/users/index.html)

Happy Coding! 🏦💳
