provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "demo-server" {
  ami                    = "ami-04b70fa74e45c3917"
  instance_type          = "t2.micro"
  key_name               = "dpp"
  vpc_security_group_ids = [aws_security_group.demo-sg.id]
  subnet_id              = aws_subnet.dpp_subnet_01.id
  for_each               = toset(["Jenkins-master", "build-slave", "ansible"])
  tags = {
    Name = "${each.key}"
  }
}

resource "aws_security_group" "demo-sg" {
  name   = "demo-sg"
  vpc_id = aws_vpc.dpp_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
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
    Name = "ssh-port"
  }
}

resource "aws_vpc" "dpp_vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "dpp-vpc"
  }
}

resource "aws_subnet" "dpp_subnet_01" {
  vpc_id                  = aws_vpc.dpp_vpc.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"
  tags = {
    Namwe = "dpp-subnet"
  }
}


resource "aws_subnet" "dpp_subnet_02" {
  vpc_id                  = aws_vpc.dpp_vpc.id
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1b"
  tags = {
    Namwe = "dpp-subnet"
  }
}

resource "aws_internet_gateway" "dpp_igw" {
  vpc_id = aws_vpc.dpp_vpc.id
  tags = {
    Name = "dpp-igw"
  }
}

resource "aws_route_table" "dpp_rt" {
  vpc_id = aws_vpc.dpp_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dpp_igw.id
  }
  tags = {
    Name = "dpp-rt"
  }
}

resource "aws_route_table_association" "dpp_rtA-01" {
  subnet_id      = aws_subnet.dpp_subnet_01.id
  route_table_id = aws_route_table.dpp_rt.id
}

resource "aws_route_table_association" "dpp_rtA-02" {
  subnet_id      = aws_subnet.dpp_subnet_02.id
  route_table_id = aws_route_table.dpp_rt.id
}

module "sgs" {
  source = "../sg_eks"
  vpc_id = aws_vpc.dpp_vpc.id
}

module "eks" {
  source = "../eks"
  vpc_id = aws_vpc.dpp_vpc.id
  subnet_ids = [aws_subnet.dpp_subnet_01.id, aws_subnet.dpp_subnet_02.id]
  sg_ids = module.sgs.security_group_public
}