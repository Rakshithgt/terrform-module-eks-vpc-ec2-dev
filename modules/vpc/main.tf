resource "aws_vpc" "gtr" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.gtr.id
  tags = {
    Name = "${var.env}-igw"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.env}-nat"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.gtr.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.gtr.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 3)
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "${var.env}-private-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.gtr.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.env}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.gtr.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "${var.env}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
