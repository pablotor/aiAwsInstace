# Create a VPC
resource "aws_vpc" "instance_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.instance_name_short}-vpc"
  }
}

# Create a subnet within the VPC
resource "aws_subnet" "instance_subnet" {
  vpc_id            = aws_vpc.instance_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
  # if public ip not preset at launch, provisioning won't work
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.instance_name_short}-subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "instance_igw" {
  vpc_id = aws_vpc.instance_vpc.id
  tags = {
    Name = "${var.instance_name_short}-igw"
  }
}

# Create a route table and associate it with the subnet
resource "aws_route_table" "instance_route_table" {
  vpc_id = aws_vpc.instance_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.instance_igw.id
  }

  tags = {
    Name = "${var.instance_name_short}-route-table"
  }
}

resource "aws_route_table_association" "instance_route_assoc" {
  subnet_id      = aws_subnet.instance_subnet.id
  route_table_id = aws_route_table.instance_route_table.id
}

# Create a security group allowing SSH and HTTP/HTTPS
resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.instance_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere (restrict in production)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "${var.instance_name_short}-sg"
  }
}
