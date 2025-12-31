resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_config.cidr
  
  tags = {
    Name = var.vpc_config.name
  }
}

resource "aws_subnet" "subnets" {
  vpc_id            = aws_vpc.vpc.id
  for_each          = var.subnet_config
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = {
    Name = each.key
    Public = each.value.public ? "true" : "false"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rt-ast" {
  count = length(local.public_subnets_id)
  route_table_id = aws_route_table.rt.id
  subnet_id = local.public_subnets_id[count.index]
  depends_on = [ aws_internet_gateway.igw, aws_route_table.rt, aws_subnet.subnets]
}
