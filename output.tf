output "vpc_primary_id" {
  value = aws_vpc.vpc_primary.id
}

output "vpc_secondary_id" {
  value = aws_vpc.vpc_secondary.id
}

output "subnet_primary_id" {
  value = aws_subnet.subnet_primary.id
}

output "subnet_secondary_id" {
  value = aws_subnet.subnet_secondary.id
}

output "igw_primary_id" {
  value = aws_internet_gateway.igw_primary.id
}

output "igw_secondary_id" {
  value = aws_internet_gateway.igw_secondary.id
}
