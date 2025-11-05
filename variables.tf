variable "aws_region" {
  type    = string
  default = "us-east-1"  # change as needed
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

# Recommend user supplies an AMI (safer than hardcoding)
variable "ami_id" {
  type    = string
  default = "" # set to a valid AMI id for your region or override during apply
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/jenkins_ec2_key.pub"
}

variable "key_name" {
  type    = string
  default = "jenkins-ec2-key"
}

