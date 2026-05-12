terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.41.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  # To use a named profile instead of default, add: profile = "profile-name"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  iam_instance_profile = "LabInstanceProfile"
  vpc_security_group_ids = [aws_security_group.server.id]
  key_name = var.key_name
  
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    delete_on_termination = true
}

  tags = {
    Name  = "cs312-minecraft-server"
  }
}

resource "aws_security_group" "server" {
  name        = "ops3-server-sg"
  description = "Security group for minecraft server, Ops 3"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Minecraft Default Port"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Minecraft Security Group"
  }
}

resource "null_resource" "ansible_trigger" {
  depends_on = [aws_instance.server, aws_ecr_repository.minecraft]
  
  triggers = {
    instance_id = aws_instance.server.id
  }

  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook \
    	-i '${aws_instance.server.public_ip},' \
        -u ubuntu \
	--private-key ~/.ssh/cs312-key.pem \
	--extra-vars "erc_registry_url=${aws_ecr_repository.minecraft.repository_url} s3_bucket_name=ops3_world_backups" \
	playbook.yml
      EOT
  }
}

