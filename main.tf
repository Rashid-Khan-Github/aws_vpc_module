resource "aws_vpc" "main_vpc" {

  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags                 = merge(var.common_tags, { Name = var.project_name }, var.vpc_tags)

}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags   = merge(var.common_tags, { Name = var.project_name }, var.igw_tags)
}

resource "aws_subnet" "public_subnet" {

  count                   = length(var.public_subnet_cidr)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = local.azs[count.index]
  tags = merge(var.common_tags,
    {
      Name = "${var.project_name}-public-sub-${local.azs[count.index]}"
    }
  )
}

resource "aws_subnet" "private_subnet" {

  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = local.azs[count.index]
  tags = merge(var.common_tags,
    {
      Name = "${var.project_name}-private-sub-${local.azs[count.index]}"
    }
  )
}

resource "aws_subnet" "database_subnet" {

  count             = length(var.database_subnet_cidr)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.database_subnet_cidr[count.index]
  availability_zone = local.azs[count.index]
  tags = merge(var.common_tags,
    {
      Name = "${var.project_name}-database-sub-${local.azs[count.index]}"
    }
  )
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  tags   = merge(var.common_tags, { Name = "${var.project_name}-public-rt" })

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }
}

resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet[0].id
  tags          = merge(var.common_tags, { Name = "${var.project_name}-natGw" }, var.nat_gw_tags)
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main_igw]
}


resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  tags   = merge(var.common_tags, { Name = "${var.project_name}-private-rt" })

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }
}

resource "aws_route_table" "database_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  tags   = merge(var.common_tags, { Name = "${var.project_name}-database-rt" })

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_rt_assoc" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "database_rt_assoc" {
  count          = length(var.database_subnet_cidr)
  subnet_id      = element(aws_subnet.database_subnet[*].id, count.index)
  route_table_id = aws_route_table.database_route_table.id
}

# grouping database subnets 
resource "aws_db_subnet_group" "database-sub-group" {
  name       = var.project_name
  subnet_ids = aws_subnet.public_subnet[*].id

  tags = merge(var.common_tags, {Name = "${var.project_name}-db-sub-group"})
}


