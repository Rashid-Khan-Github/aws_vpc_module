output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "azs_output" {
  value = local.azs
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "database_subnet_ids" {
  value = aws_subnet.database_subnet[*].id
}