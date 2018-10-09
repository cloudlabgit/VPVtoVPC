variable "aws_region" {
  description = "Region to use"
  default = "us-east-1"
}

variable "vpc1_cidr" {
  description = "CIDR for the VPC"
  default = "10.0.0.0/16"
}

variable "vpc2_cidr" {
  description = "CIDR for the VPC"
  default = "10.2.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the VPC1 public subnet"
  default = "10.0.0.0/17"
}

variable "private_subnet_cidr" {
  description = "CIDR for the VPC2 private subnet"
  default = "10.2.0.0/17"
}

variable "ami" {
  description = "AMI for EC2 Redhat Enterprises Linux 7.5"
  default = "ami-6871a115"
}

variable "key_path" {
  description = "SSH Public Key path"
  default = "/app/id_rsa_example.pub"
}

variable "access_key" {}

variable "secret_key" {}

