
resource "aws_vpc" "ninja_vpc" {
  cidr_block = "10.0.0.0/22"
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_names)
  cidr_block              = "10.0.${count.index}.0/24"
  vpc_id                  = aws_vpc.ninja_vpc.id
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = var.public_subnet_names[count.index]
  }
}

resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_names)
  cidr_block              = "10.0.${count.index + 2}.0/24"
  vpc_id                  = aws_vpc.ninja_vpc.id
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = var.private_subnet_names[count.index]
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.ninja_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_instance_sg" {
  name        = "private-instance-sg"
  description = "Security group for private instance"
  vpc_id      = aws_vpc.ninja_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami           = var.instance_ami
  instance_type = var.instance
  subnet_id     = aws_subnet.public[0].id
  key_name      = var.key
  security_groups = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "bastion"
  }
}

resource "aws_instance" "private_instance" {
  count =2
  ami           = var.instance_ami
  instance_type = var.instance
  subnet_id     = aws_subnet.private[count.index].id
  key_name      = var.key
  security_groups = [aws_security_group.private_instance_sg.id]

  tags = {
    Name = "private_instance-${count.index +1}"
  }
}

resource "aws_internet_gateway" "ninja_igw" {
  vpc_id = aws_vpc.ninja_vpc.id
  tags = {
    Name = var.igw_name
  }
}

resource "aws_eip" "nat" {
  instance = null
}

resource "aws_nat_gateway" "ninja_nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
}

resource "aws_route_table" "public" {
  count  = 1
  vpc_id = aws_vpc.ninja_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ninja_igw.id
  }
  tags = {
    Name = "ninja-route-pub-01/02"
  }
}

resource "aws_route_table" "private" {
  count  = 1
  vpc_id = aws_vpc.ninja_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ninja_nat.id
  }
  tags = {
    Name = "ninja-route-priv-01/02"
  }
}

resource "aws_route_table_association" "private_subnets" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

resource "aws_route_table_association" "public_subnets" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}