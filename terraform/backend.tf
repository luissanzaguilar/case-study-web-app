terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "terraform/terraform.tfstate"
    region = var.aws_region
    encrypt = true
  }
}