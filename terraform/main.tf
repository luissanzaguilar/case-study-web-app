
data "aws_ami" "amazon-linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.8.20250818.0-kernel-6.1-x86_64"]
  }

  owners = ["099720109477"] # Canonical
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