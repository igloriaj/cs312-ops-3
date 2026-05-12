variable "ami_id" {
  description = "AMI ID for the EC2 instance (Ubuntu 26.04 in us-east-1)"
  type        = string
  default     = "ami-0d13e2317a7e75c95"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Name of the SSH key pair (must already exist in AWS)"
  type        = string
}

