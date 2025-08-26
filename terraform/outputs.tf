

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.app_terraform.public_ip
}

output "ssh_connection_command" {
  description = "Connect using SSH"
  value       = "ssh -i formacion.pem ec2-user@${aws_instance.app_terraform.public_ip}"
}

output "vpc_id" {
  description = "ID VPC"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "ID subnet"
  value       = data.aws_subnets.default.ids[0]
}
