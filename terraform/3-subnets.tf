# Public Subnets
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.node-api_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet_a-vpc_api_node"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.node-api_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}c"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet_c-vpc_api_node"
  }
}
