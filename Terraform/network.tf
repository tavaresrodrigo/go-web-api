
resource "aws_vpc" "ecs-vpc" {
  cidr_block = "172.17.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = merge(
    local.tags,{
    Name = "${var.name}-vpc"
  }
  )
}

resource "aws_subnet" "private-subnet" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.ecs-vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.ecs-vpc.id
    tags = merge(
    local.tags,{
    Name = "${var.name}-private-subnet"
  })
}

resource "aws_subnet" "public-subnet" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.ecs-vpc.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.ecs-vpc.id
  map_public_ip_on_launch = true
    tags = merge(
    local.tags,{
    Name = "${var.name}-public-subnet"
  })
}

resource "aws_internet_gateway" "ecs-igw" {
  vpc_id = aws_vpc.ecs-vpc.id
  tags = merge(
    local.tags,
    {
      Name = "${var.name}-igw"
    },
  )
}

resource "aws_route" "internet-access-route" {
  route_table_id         = aws_vpc.ecs-vpc.main_route_table_id 
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ecs-igw.id
}

resource "aws_security_group" "ecs-cluster-sg" {
  name = "${var.name}-ecs-cluster-sg"
  vpc_id = aws_vpc.ecs-vpc.id

  ingress {
    from_port = "${var.container_port}"
    to_port = "${var.container_port}"   
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  tags = merge(
    local.tags,
    {
      Name = "${var.name}-ecs-cluster-sg"
    },
  )
}