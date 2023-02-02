data "aws_availability_zones" "available" {
  state = "available"
}



resource "aws_vpc" "mini-project" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "project" 
  }  
}

resource "aws_subnet" "subnets" {
  count   = var.instance_count

  vpc_id     = aws_vpc.mini-project.id
  cidr_block = var.subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "dev"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.mini-project.id

  tags = {
    Name = "project-igw"
  }
}

resource "aws_route_table" "project-rt" {
  vpc_id = aws_vpc.mini-project.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
   tags = {
     Name = "project"
  }
}

resource "aws_route_table_association" "a" {
  count  = var.instance_count
  subnet_id = aws_subnet.subnets[count.index].id
  
  route_table_id = aws_route_table.project-rt.id
}

resource "aws_security_group" "project-load-balancer-sg" {
  name        = "project-load-balancer-sg"
  description = "Load balancer security group"
  vpc_id      = aws_vpc.mini-project.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "load-balancer-sg"
  }
}



