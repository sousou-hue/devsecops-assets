provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# TABLE DYNAMODB
resource "aws_dynamodb_table" "history_table" {
  name           = "DevSecOpsHistory" # Identique au main.py
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "scan_id"
  attribute {
    name = "scan_id"
    type = "S"
  }
}

# ROLE IAM
resource "aws_iam_role" "ec2_role" {
  name = "DevSecOpsEC2Role" 
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Principal = { Service = "ec2.amazonaws.com" }, Effect = "Allow" }]
  })
}

resource "aws_iam_role_policy_attachment" "admin_rights" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "DevSecOpsProfile"
  role = aws_iam_role.ec2_role.name
}

# SECURITY GROUP
resource "aws_security_group" "app_sg" {
  name = "devsecops-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

BUCKET S3 
resource "aws_s3_bucket" "frontend_bucket" {
  # 
  bucket = "devsecops-assets-front-soumia-wiame-amine" 
  force_destroy = true
}

# SERVEUR EC2
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = "devsecops-key" 
  
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io git
              sudo systemctl start docker
              sudo usermod -aG docker ubuntu
              EOF
  tags = { Name = "DevSecOps-Server" }
}

output "server_ip" { value = aws_instance.app_server.public_ip }