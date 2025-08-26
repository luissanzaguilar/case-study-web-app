
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
}

resource "aws_iam_instance_profile" "profile_terraform" {
  name = "profile-terraform"
  role = aws_iam_role.role_terraform.name
}

resource "aws_security_group" "allow_web" {
  name_prefix = "allow-web-terraform-"
  description = "Allow SSH, HTTP and HTTP traffic"

  # Regla de entrada para SSH (puerto 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # Regla de entrada para HTTP (puerto 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # Regla de entrada para HTTP alternativo (puerto 8080)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Alternative HTTP access"
  }

  # Regla de salida (todo el tráfico)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Outbound traffic"
  }

  tags = {
    Name = "allow-web-terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-con-dns-habilitado"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-con-dns"
  }
}

resource "aws_instance" "app_terraform" {
  ami           = data.aws_ami.amazon-linux.id
  instance_type = "m7i-flex.large"
  key_name = "formacion"
  iam_instance_profile   = aws_iam_instance_profile.profile_terraform.name
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  subnet_id              = aws_subnet.main.id

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
    aws_security_group.allow_web,
    aws_iam_instance_profile.profile_terraform
  ]
}