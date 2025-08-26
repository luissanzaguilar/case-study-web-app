
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
  vpc_id = data.aws_vpc.default.id

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

}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_instance" "app_terraform" {
  ami           = data.aws_ami.amazon-linux.id
  instance_type = var.instance_type
  key_name = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.profile_terraform.name
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  subnet_id              = data.aws_subnets.default.ids[0]

  user_data = templatefile("user_data.sh", {
    runner_token = var.runner_token
  })

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "case-study-2-terraform"
    Emvironment = var.environment
  }

  depends_on = [
    aws_security_group.allow_web,
    aws_iam_instance_profile.profile_terraform
  ]
}


