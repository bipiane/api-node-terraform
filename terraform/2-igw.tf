resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.node-api_vpc.id

  tags = {
    Name = "igw"
  }
}
