
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