
# Create a VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Create an internet gateway
resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.custom_vpc.id
}

# Create public and private subnets
resource "aws_subnet" "public_subnets" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = element(var.publicsubnet_cidr, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = element(var.privatesubnet_cidr, count.index)
  availability_zone = element(var.azs, count.index)
}

# Create NAT gateways for private subnets
resource "aws_eip" "nat_gw_ips" {
  count = length(var.azs)
}

resource "aws_nat_gateway" "nat_gateways" {
  count         = length(var.azs)
  allocation_id = aws_eip.nat_gw_ips[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id
}

# Create route tables for private subnets
resource "aws_route_table" "private_route_tables" {
  count  = 2
  vpc_id = aws_vpc.custom_vpc.id
}

resource "aws_route" "private_subnet_routes" {
  count                  = 2
  route_table_id         = aws_route_table.private_route_tables[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateways[count.index].id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_route_table_association" "public_association" {
  for_each      = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

# # Create a route table for each public subnet
# resource "aws_route_table" "public_route_tables" {
#   count = length(var.azs)
#   vpc_id = aws_vpc.custom_vpc.id
# }
# # Create a route in each public subnet route table to direct traffic to the Internet Gateway
# resource "aws_route" "public_subnet_routes" {
#   count = 2
#   route_table_id = aws_route_table.public_route_tables[count.index].id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id = aws_internet_gateway.vpc_igw.id
# }


