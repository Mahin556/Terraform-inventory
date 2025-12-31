locals {
  public_subnets_id = [
    for subnet in aws_subnet.subnets : subnet.id if subnet.tags["Public"] == "true"
  ]

  private_subnets_id = [
    for subnet in aws_subnet.subnets : subnet.id if subnet.tags["Public"] == "false"
  ]
}