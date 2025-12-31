output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnets_id" {
  value = local.public_subnets_id
}

output "private_subnets_id" {
  value = local.private_subnets_id
}