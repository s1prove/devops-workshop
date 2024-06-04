provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "demo-server" {
  ami = "ami-00beae93a2d981137"
  instance_type = "t2.micro"
  key_name = "dpp"
}