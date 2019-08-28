provider "aws" {
  version = "~> 2.0"
  region  = "${var.aws_region}"
}

/*
Network
*/
resource "aws_vpc" "wordpress_stack_vpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags = {
        Name = "ًWordpess Stack VPC"
    }
}

resource "aws_internet_gateway" "wordpress_stack_gateway" {
    vpc_id = "${aws_vpc.wordpress_stack_vpc.id}"
}
resource "aws_subnet" "wordpress_stack_private_subnet" {
    vpc_id = "${aws_vpc.wordpress_stack_vpc.id}"
    cidr_block = "${var.private_subnet_cidr}"
    availability_zone = "us-west-2c"
    tags = {
        Name = "Private Subnet"
    }
}

resource "aws_subnet" "rds_private_subnet" {
    vpc_id = "${aws_vpc.wordpress_stack_vpc.id}"
    cidr_block = "${var.rds_private_subnet_cidr}"
    availability_zone = "us-west-2a"
    tags = {
        Name = "RDS Private Subnet"
    }
}

resource "aws_route_table" "wordpress_stack_route" {
    vpc_id = "${aws_vpc.wordpress_stack_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.wordpress_stack_gateway.id}"
    }
    tags = {
        Name = "Rounting Table"
    }
}

resource "aws_route_table_association" "wordpress_stack_route_subnet" {
    subnet_id = "${aws_subnet.wordpress_stack_private_subnet.id}"
    route_table_id = "${aws_route_table.wordpress_stack_route.id}"
}
/*
SSH Public Key
*/

resource "aws_key_pair" "ssh_key" {
  key_name   = "deployer_key"
  public_key = "${var.deployer_public_key}"
}

/*
Ubuntu AMI
*/

data "aws_ami" "ubuntu-server" {
most_recent = true
owners = ["099720109477"]

  filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

/*
Security groups
*/

// Web server
resource "aws_security_group" "wordpress_stack_security_group" {
    name = "vpc_web"
    description = "Restrict inbound traffic"
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
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
    vpc_id = "${aws_vpc.wordpress_stack_vpc.id}"

    tags = {
        Name = "WordPress Server Security Group"
    }
}

// RDS server

resource "aws_security_group" "wordpress_rds_security_group" {
    name = "vpc_rds"
    description = "Allow inbound and oubtound traffic."
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = ["${aws_security_group.wordpress_stack_security_group.id}"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.wordpress_stack_vpc.id}"

    tags = {
        Name = "RDS Server Security Group"
    }
}

/*
Web Server
*/
resource "aws_instance" "wordpress_stack_server" {
    ami = "${data.aws_ami.ubuntu-server.id}"
    instance_type = "t2.small"
    key_name = "${aws_key_pair.ssh_key.key_name}"
    vpc_security_group_ids = ["${aws_security_group.wordpress_stack_security_group.id}"]
    subnet_id = "${aws_subnet.wordpress_stack_private_subnet.id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags = {
        Name = "Wordpress Stack Server"
    }
}

# build the CloudWatch auto-recovery alarm and recovery action
resource "aws_cloudwatch_metric_alarm" "wordpress_stack_server_monitoring" {
  alarm_name         = "stack-instance-autorecovery"
  namespace          = "AWS/EC2"
  evaluation_periods = "2"
  period             = "60"
  alarm_description  = "This metric auto recovers wordpress server"
 
  alarm_actions = ["arn:aws:automate:${var.aws_region}:ec2:recover"]
 
  statistic           = "Minimum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "0.0"
  metric_name         = "StatusCheckFailed_System"
 
  dimensions = {
    InstanceId = "${aws_instance.wordpress_stack_server.id}"
  }
}

/*
RDS
*/

resource "aws_db_subnet_group" "wordpress_rds_subnet_group" {
  name        = "rds_subnet_group"
  description = "Rds group of subnets"
  subnet_ids  = ["${aws_subnet.wordpress_stack_private_subnet.id}", "${aws_subnet.rds_private_subnet.id}"]
}

resource "aws_db_instance" "wordpress_rds_instance" {
  allocated_storage    = 30
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "wordpress"
  username             = "wordpress_username"
  password             = "wordpress_password"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  vpc_security_group_ids = ["${aws_security_group.wordpress_rds_security_group.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.wordpress_rds_subnet_group.id}"

  tags = {
        Name = "RDS Server"
    }
}
