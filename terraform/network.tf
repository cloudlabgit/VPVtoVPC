/**
 * Make AWS account ID available.
 *
 * This is added as an output so that other stacks can reference this. Usually
 * required for VPC peering.
 */
data "aws_caller_identity" "current" {}

# Define our VPC1_ProxyServer
resource "aws_vpc" "rpvpc" {
  cidr_block = "${var.vpc1_cidr}"
  enable_dns_hostnames = true

  ##tags { Name = "VPC1_ProxyServer" }
}


# Define our VPC2_WebServer
resource "aws_vpc" "wsvpc" {
  cidr_block = "${var.vpc2_cidr}"
  enable_dns_hostnames = true

  ##tags {Name = "VPC2_WebServer"}
}

# Define the Reverse Proxy Public Subnet for VPC1
resource "aws_subnet" "public-subnet" {
  vpc_id = "${aws_vpc.rpvpc.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "us-east-1a"

  ##tags {Name = "Reverse Proxy Public Subnet"}
}

# Define the Web Server Private Subnet for VPC2
resource "aws_subnet" "private-subnet" {
  vpc_id = "${aws_vpc.wsvpc.id}"
  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "us-east-1a"

  ##tags {Name = "Web Server Private Subnet"}
}

# Define the VPC1 Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.rpvpc.id}"

  ##tags {Name = "VPC1 IGT"}
}

# Define the route table
resource "aws_route_table" "rp-public-rt" {
  vpc_id = "${aws_vpc.rpvpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  ##tags {Name = "Reverse Proxy Public Subnet RT"}
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "rt-public-rt" {
  subnet_id = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.rp-public-rt.id}"
}

# Define the security group for public subnet
resource "aws_security_group" "sgrp" {
  name = "sg_vpc1_web"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  vpc_id="${aws_vpc.rpvpc.id}"

  ##tags {Name = "Web Server SG"}
}

# Define the security group for private subnet
resource "aws_security_group" "sgws"{
  name = "sg_vpc2_web"
  description = "Allow traffic from public subnet"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  vpc_id = "${aws_vpc.wsvpc.id}"

  ##tags {Name = "Application SG"}
}

/*
 * VPC peering connection.
 *
 * Establishes a relationship resource between the "primary" and "secondary" VPC.
 */
resource "aws_vpc_peering_connection" "rpvpc2wsvpc" {
  peer_owner_id = "${data.aws_caller_identity.current.account_id}"
  peer_vpc_id = "${aws_vpc.wsvpc.id}"
  vpc_id = "${aws_vpc.rpvpc.id}"
  auto_accept = true
}

/**
 * Route rule.
 *
 * Creates a new route rule on the "primary" VPC main route table. All requests
 * to the "secondary" VPC's IP range will be directed to the VPC peering
 * connection.
 */
resource "aws_route" "rpvpc2wsvpc" {
  route_table_id = "${aws_vpc.rpvpc.main_route_table_id}"
  destination_cidr_block = "${aws_vpc.wsvpc.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.rpvpc2wsvpc.id}"
}

/**
 * Route rule.
 *
 * Creates a new route rule on the "secondary" VPC main route table. All
 * requests to the "secondary" VPC's IP range will be directed to the VPC
 * peering connection.
 */
resource "aws_route" "wsvpc2rpvpc" {
  route_table_id = "${aws_vpc.wsvpc.main_route_table_id}"
  destination_cidr_block = "${aws_vpc.rpvpc.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.rpvpc2wsvpc.id}"
}
