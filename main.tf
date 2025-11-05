# Read public key file
data "local_file" "pubkey" {
  filename = "/root/.ssh/jenkins_ec2_key.pub"
}

# Optionally accept ami as var, else you can set a default or use a data source
resource "aws_key_pair" "jenkins_key" {
  key_name   = var.key_name
  public_key = chomp(data.local_file.pubkey.content)
}

resource "aws_security_group" "web_sg" {
  name        = "jenkins-web-sg"
  description = "Allow SSH and HTTP"
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # restrict to admin IPs in production
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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

# EC2 instance
resource "aws_instance" "web" {
  ami                         = "ami-0bdd88bd06d16ba03"
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.jenkins_key.key_name
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "jenkins-deploy-ec2"
  }

  # Basic user_data to install prerequisites (optionally)
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              # Install node (or skip if you only transfer artifact)
              curl -sL https://rpm.nodesource.com/setup_18.x | bash -
              yum install -y nodejs
              # Make a deploy folder
              mkdir -p /opt/app
              chown ec2-user:ec2-user /opt/app
              EOF
}

output "public_ip" {
  value = aws_instance.web.public_ip
}

output "public_dns" {
  value = aws_instance.web.public_dns
}
