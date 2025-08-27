#!/bin/bash
set -e
set -x

# Create log file
exec > >(tee /var/log/user-data.log) 2>&1
echo "=== EXECUTING USER_DATA == $(date) ==="

echo "--- Update system ---"
sudo yum update -y

echo "--- Install Docker ---"
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
sudo systemctl daemon-reload
sudo systemctl restart docker

echo "--- Install Minikube ---"
sudo yum install -y conntrack
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

echo "--- Install kubectl ---"
sudo curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.0/2024-01-04/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

echo "--- Install Terraform ---"
sudo yum install -y yum-utils shadow-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install -y terraform

echo "--- Start minikube with ec2-user ---"
sudo -u ec2-user minikube start

echo "--- Install GitHub Actions Runner ---"
sudo -u ec2-user bash << INNER_EOF
echo "Token: ${runner_token}"
sudo yum install -y dotnet-sdk-6.0 # We need this dependency to be installed before the Actions Runner
cd /home/ec2-user
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.328.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.328.0/actions-runner-linux-x64-2.328.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.328.0.tar.gz

./config.sh --url https://github.com/luissanzaguilar/case-study-web-app --token ${runner_token} --name k8s-runner --labels self-hosted-k8s --unattended

sudo ./svc.sh install
sudo ./svc.sh start
INNER_EOF

echo "=== Installation completed ==="
