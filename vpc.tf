# Provision VPC

resource "aws_vpc" "javahome_vpc" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name  = "JavaHomeVpc"
    Batch = "Weekend"
  }
}

# Provision subnets for hosting webservers

resource "aws_subnet" "webservers" {
  count             = "${length(data.aws_availability_zones.azs.names)}"
  vpc_id            = "${aws_vpc.javahome_vpc.id}"
  availability_zone = "${data.aws_availability_zones.azs.names[count.index]}"
  cidr_block        = "${element(var.subets_cidr,count.index)}"

  tags {
    Name        = "Webservers"
    Environment = "Dev"
  }
}

# Setup IGW for webservers subent
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.javahome_vpc.id}"

  tags {
    Name = "JavaHomeIGW"
  }
}

# Add route table for webservers

resource "aws_route_table" "webservers_rt" {
  vpc_id = "${aws_vpc.javahome_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "webservers_rt"
  }
}

# Associate subnets with webservers_rt

resource "aws_route_table_association" "a" {
  count          = "${length(aws_subnet.webservers.*.id)}"
  subnet_id      = "${element(aws_subnet.webservers.*.id,count.index)}"
  route_table_id = "${aws_route_table.webservers_rt.id}"
}

# Add Security groups for webservers

resource "aws_security_group" "webservers_sg" {
  name        = "webservers_sg"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.javahome_vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["49.205.217.185/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Add EC2 instances to public subnets
resource "aws_instance" "webservers" {
  count                       = "${length(aws_subnet.webservers.*.id)}"
  vpc_security_group_ids      = ["${aws_security_group.webservers_sg.id}"]
  ami                         = "${var.ec2_ami}"
  instance_type               = "t2.micro"
  subnet_id                   = "${element(aws_subnet.webservers.*.id,count.index)}"
  user_data                   = "${file("scripts/user_data.sh")}"
  associate_public_ip_address = true

  tags {
    Name = "Webserver-${count.index + 1}"
  }
}
