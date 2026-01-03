# What is needed - 2 vpc in 2 differnt regions and cidr range
# Inside 2 vpc i need to create 2 subnets

resource "aws_vpc" "vpc_primary" {
  provider             = aws.USA-primary
  cidr_block           = var.vpc_cidr_blocks[0]
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-primary-vpc"
  })
}

resource "aws_vpc" "vpc_secondary" {
  provider             = aws.USA-secondary
  cidr_block           = var.vpc_cidr_blocks[1]
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-secondary-vpc"
  })
}



# Inside 2 vpc i need to create 2 subnets
resource "aws_subnet" "subnet_primary" {
  provider   = aws.USA-primary
  vpc_id     = aws_vpc.vpc_primary.id
  cidr_block = var.subnet_cidr_blocks[0]
  #need to include a availability zone
  #availablity zones are present inside the region
  availability_zone       = data.aws_availability_zones.available_zones_primary.names[0]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-primary-subnet"
  })
}

resource "aws_subnet" "subnet_secondary" {
  provider   = aws.USA-secondary
  vpc_id     = aws_vpc.vpc_secondary.id
  cidr_block = var.subnet_cidr_blocks[1]
  #need to include a availability zone
  #availablity zones are present inside the region
  availability_zone       = data.aws_availability_zones.available_zones_secondary.names[0]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-secondary-subnet"
  })
}



/*
Now i need to create internet gateway for each vpc such that
each subnet inside the vpc --- connected to internet gatewat of that vpc
this allows the resources inside the subnet to access the internet
*/
resource "aws_internet_gateway" "igw_primary" {
  provider = aws.USA-primary
  vpc_id   = aws_vpc.vpc_primary.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-primary-igw"
  })
}

resource "aws_internet_gateway" "igw_secondary" {
  provider = aws.USA-secondary
  vpc_id   = aws_vpc.vpc_secondary.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-secondary-igw"
  })
}


/*
Now that the internet gateway is created,
we need to link each subnet in a vpc --- to its igw in that vpc
we can do that using route table 
route table also allows us to add route traffic rules 
destination - from where the traffic can come from the internet to the igw
*/

resource "aws_route_table" "rt_primary" {
  provider = aws.USA-primary
  vpc_id   = aws_vpc.vpc_primary.id

  route {
    cidr_block = "0.0.0.0/0" #meaning - it allows traffic from any ip address into the igw
    gateway_id = aws_internet_gateway.igw_primary.id
  }
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-primary-rt"
  })
}

resource "aws_route_table" "rt_secondary" {
  provider = aws.USA-secondary
  vpc_id   = aws_vpc.vpc_secondary.id

  route {
    cidr_block = "0.0.0.0/0" #meaning - it allows traffic from any ip address into the igw
    gateway_id = aws_internet_gateway.igw_secondary.id
  }
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-secondary-rt"
  })
}

#linking to the subnets
resource "aws_route_table_association" "rt_association_primary" {
  provider       = aws.USA-primary
  subnet_id      = aws_subnet.subnet_primary.id
  route_table_id = aws_route_table.rt_primary.id

}

resource "aws_route_table_association" "rt_association_secondary" {
  provider       = aws.USA-secondary
  subnet_id      = aws_subnet.subnet_secondary.id
  route_table_id = aws_route_table.rt_secondary.id
}
