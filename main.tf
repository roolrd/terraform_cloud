provider "aws" {
  region "eu-central-1"
}

data "aws_availability_zones" "available" {}
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
resource "aws_instance" "web-prod" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = var.server_size

  vpc_security_group_ids = [aws_security_group.web-prod.id]

  user_data = <<UD
#!/bin/bash
yum update -y
yum install httpd -y
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h1>PROD Web Server with IP: $myip</h1><br> Build by Ruslan on Terraform WorkSpace - ${terraform.workspace}! " > /var/www/html/index.html
service httpd start && chkconfig httpd on
UD

  tags = {
    Name  = "var.server_name - ${terraform.workspace}"
    Owner = "Ruslan Riznyk"
  }
}

resource "aws_security_group" "web-prod" {
  name_prefix = "WebServer_sg Prod -"

  ingress {
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
  tags = {
    Name  = "PROD SecurityGroup - ${terraform.workspace}"
    Owner = "Ruslan Riznyk"
  }
}
