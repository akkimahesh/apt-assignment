resource "aws_vpc" "assignment-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "assignment-vpc"
  }
}

resource "aws_subnet" "public-1" {
  vpc_id            = aws_vpc.assignment-vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public-2" {
  vpc_id            = aws_vpc.assignment-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "private-1" {
  vpc_id            = aws_vpc.assignment-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private-2" {
  vpc_id            = aws_vpc.assignment-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "private-subnet-2"
  }
}

#create IGW
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.assignment-vpc.id
  tags = {
    Name = "assignment-igw"
  }
}


resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.assignment-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.assignment-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT.id
  }
  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "public-1-assoc" {
  subnet_id      = aws_subnet.public-1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-2-assoc" {
  subnet_id      = aws_subnet.public-2.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_eip" "eip" {
  domain = "vpc"

  tags = {
    Name = "NAT-EIP"
  }
}

resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public-1.id
  tags = {
    Name = "gw NAT"
  }
}

resource "aws_route_table_association" "private-1-assoc" {
  subnet_id      = aws_subnet.private-1.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private-2-assoc" {
  subnet_id      = aws_subnet.private-2.id
  route_table_id = aws_route_table.private-rt.id
}
