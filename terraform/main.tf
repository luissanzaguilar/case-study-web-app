
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

resource "aws_iam_instance_profile" "role_terraform" {
  name = "role-terraform"
  role = "role-terraform"
  path = "/"
}

resource "aws_instance" "app_terraform" {
  ami           = data.aws_ami.amazon-linux.id
  instance_type = "m7i-flex.large"
  key_name = "formacion"
  iam_instance_profile = "role-terraform"
  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "case-study-2-terraform"
  }
}