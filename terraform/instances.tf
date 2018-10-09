# Define SSH key pair for our instances
resource "aws_key_pair" "default" {
  key_name = "vpctestkeypair"
  public_key = "${file("${var.key_path}")}"
}

# Define proxy server inside the VPC1 and a  public subnet
resource "aws_instance" "pserver" {
   ami  = "${var.ami}"
   instance_type = "t2.micro"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${aws_subnet.public-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.sgrp.id}"]
   associate_public_ip_address = true
   source_dest_check = false
   ##user_data = "${file("install.sh")}"

  ##tags {Name = "ProxyServer"}
}

# Define web server inside the VPC2 and a private subnet
resource "aws_instance" "wserver" {
   ami  = "${var.ami}"
   instance_type = "t2.micro"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${aws_subnet.private-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.sgws.id}"]
   source_dest_check = false

  ##tags {Name = "WebServer"}
}
