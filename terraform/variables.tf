variable "instance_type" {
  type = string
  default = "m7i-flex.large"
  description = "The type of EC2 instance"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-3"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "formacion"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}