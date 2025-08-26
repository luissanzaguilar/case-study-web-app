
data "aws_ami" "amazon-linux" {
  most_recent = true
  owners = ["amazon"] # Canonical

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_iam_role" "role_terraform" {
  name = "role-terraform"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "role-terraform"
  }
}

resource "aws_iam_role_policy_attachment" "admin_access" {
  role       = aws_iam_role.role_terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  depends_on = [aws_iam_role.role_terraform]
}

resource "aws_iam_instance_profile" "profile_terraform" {
  name = "profile-terraform"
  role = aws_iam_role.role_terraform.name

  depends_on = [
    aws_iam_role.role_terraform
  ]

}

resource "aws_instance" "app_terraform" {
  ami           = data.aws_ami.amazon-linux.id
  instance_type = "m7i-flex.large"
  key_name = "formacion"
  iam_instance_profile = aws_iam_instance_profile.profile_terraform.name

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # Update system
              sudo yum update -y

              # Install Docker
              sudo yum install -y docker
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ec2-user
              sudo systemctl daemon-reload
              sudo systemctl restart docker

              # Install Minikube
              curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
              sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

              # Install kubectl
              sudo curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.0/2024-01-04/bin/linux/amd64/kubectl
              sudo chmod +x ./kubectl
              sudo mv ./kubectl /usr/local/bin/kubectl

              # Install Terraform
              sudo yum install -y yum-utils shadow-utils
              sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
              sudo yum install -y terraform

              echo "=== Instalación completada ==="
              EOF

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "case-study-2-terraform"
  }

  depends_on = [
    aws_iam_instance_profile.profile_terraform
  ]
}