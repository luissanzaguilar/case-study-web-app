# terraform {
#   backend "s3" {
#     bucket = "lsz-terraform-statefiles"
#     key    = "terraform.tfstate"
#     region = "eu-west-3"
#     encrypt = true
#   }
# }