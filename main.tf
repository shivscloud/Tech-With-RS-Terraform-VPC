provider "aws" {
  region = "us-east-1" # Change this to your desired AWS region
}

resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet_a" {
  count = 1
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24" # Change this CIDR block as needed
  availability_zone       = "us-east-1a"  # Change to your desired availability zone
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_b" {
  count = 1
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.2.0/24" # Change this CIDR block as needed
  availability_zone       = "us-east-1b"  # Change to your desired availability zone
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.custom_vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }
}

resource "aws_route_table_association" "subnet_a" {
  subnet_id      = aws_subnet.subnet_a[0].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "subnet_b" {
  subnet_id      = aws_subnet.subnet_b[0].id
  route_table_id = aws_route_table.public.id
}
