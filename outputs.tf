output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.server.id
}

output "public_ip" {
  description = "Public IP address"
  value       = aws_instance.server.public_ip
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.server.id
}

output "ami_id" {
  description = "AMI ID in use"
  value       = aws_instance.server.ami
}

