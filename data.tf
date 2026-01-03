#data source to get all the available zones 

data "aws_availability_zones" "available_zones_primary" {
  provider = aws.USA-primary
  state    = "available"
}

data "aws_availability_zones" "available_zones_secondary" {
  provider = aws.USA-secondary
  state    = "available"
}


# Data source for Primary region AMI (Ubuntu 24.04 LTS)
data "aws_ami" "primary_ami" {
  provider    = aws.USA-primary
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


data "aws_ami" "secondary_ami" {
  provider    = aws.USA-secondary
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
