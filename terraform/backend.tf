terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "terraform/terraform.tfstate"
    region = "eu-west-3"
    encrypt = true
  }
}