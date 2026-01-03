resource "aws_vpc_peering_connection" "primary_to_secondary_vpc_peering" {
  provider    = aws.USA-primary
  peer_vpc_id = aws_vpc.vpc_secondary.id
  vpc_id      = aws_vpc.vpc_primary.id
  peer_region = "us-west-1"
  auto_accept = false # Must be false for cross-region peering

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-primary-secondary-vpc-peering"
  })
}


resource "aws_vpc_peering_connection_accepter" "Accepter" {
  provider                  = aws.USA-secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary_vpc_peering.id
  auto_accept               = true

  tags = merge(local.common_tags, {
    Side = "Accepter"
  })
}

# Add route to Secondary VPC in Primary route table
resource "aws_route" "primary_to_secondary" {
  provider                  = aws.USA-primary
  route_table_id            = aws_route_table.rt_primary.id
  destination_cidr_block    = var.vpc_cidr_blocks[1]
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary_vpc_peering.id

  depends_on = [aws_vpc_peering_connection_accepter.Accepter]
}

# Add route to Primary VPC in Secondary route table
resource "aws_route" "secondary_to_primary" {
  provider                  = aws.USA-secondary
  route_table_id            = aws_route_table.rt_secondary.id
  destination_cidr_block    = var.vpc_cidr_blocks[0]
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary_vpc_peering.id

  depends_on = [aws_vpc_peering_connection_accepter.Accepter]
}

