# main.tf

# Fetch available availability zones
data "aws_availability_zones" "available" {}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "MainVPC"
  }
}

# Create public subnets
resource "aws_subnet" "public" {
  #count             = length(var.public_subnet_cidr_blocks)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr_blocks[count.index]
  #availability_zone = element(data.aws_availability_zones.available.names, count.index)
  availability_zone = data.aws_availability_zones.available.names

  tags = {
    #Name = "PublicSubnet-${count.index + 1}"
    Name = "PublicSubnet"
  }
}

/*# Create private subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "PrivateSubnet-${count.index + 1}"
  }
}*/

# Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "MainIGW"
  }
}

# Create Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  #count          = length(aws_subnet.public)
  #subnet_id      = aws_subnet.public[count.index].id
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


# Create Key Pair for SSH access
resource "aws_key_pair" "ssh_key" {
  key_name   = "terraform_key"
  public_key = file("./id_rsa.pub") # Change path accordingly
}

# Create Web Server in Public Subnet
resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  #subnet_id                   = aws_subnet.public[0].id # Choose the appropriate public subnet
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh_key.key_name # Use the created key pair for SSH access
  security_groups             = [aws_security_group.web.id]

  tags = {
    Name = "WebServer"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Your web server setup script here
                EOF
}

/*# Create Application Server in Private Subnet
resource "aws_instance" "app_server" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.private[0].id      # Choose the appropriate private subnet
  key_name        = aws_key_pair.ssh_key.key_name # Use the created key pair for SSH access
  security_groups = [aws_security_group.app.id]

  tags = {
    Name = "AppServer"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Your application server setup script here
              EOF
}

# Create Database Server in Private Subnet
resource "aws_instance" "db_server" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.private[1].id      # Choose the appropriate private subnet
  key_name        = aws_key_pair.ssh_key.key_name # Use the created key pair for SSH access
  security_groups = [aws_security_group.db.id]

  tags = {
    Name = "DBServer"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Your database server setup script here
              EOF
}*/


