provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ec2" {
  ami             = "ami-0ae8f15ae66fe8cda"
  instance_type   = "t2.micro"
  key_name        = "dpp"
  security_groups = ["demo-sg"]
}

resource "aws_security_group" "demo-sg" {
  name = "demo-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
  }
}