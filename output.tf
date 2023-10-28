output "vpc_id" {
  value = aws_vpc.custom_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.subnet_b[*].id
}

# output "private_subnet_ids" {
#   value = aws_subnet.private_subnets[*].id
# }