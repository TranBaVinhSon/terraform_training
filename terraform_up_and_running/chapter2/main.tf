# resource "<PROVIDER>_<TYPE>" "<NAME>" {
#   [CONFIG ...]
# }
provider "aws" {
  profile = "son-terraform-learning" # default profile in ~/.aws/config
  region  = "ap-northeast-1"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

# resource "<PROVIDER>_<TYPE>" "<NAME>" {
#  [CONFIG …]
# }
resource "aws_instance" "example" {
  ami           = "ami-0cc75a8978fbbc969" # Using Packer to create custom AMI
  instance_type = "t2.micro"
  # <PROVIDER>_<TYPE>.<NAME>.<ATTRIBUTE>
  vpc_security_group_ids = [aws_security_group.instance.id]
  # AWS will execute when the instance is booting
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF
  tags = {
    Name = "terraform-example"
  }
}

# CIDR blocks are a concise way to specify IP address ranges. For example, a CIDR block of 10.0.0.0/24 represents all IP addresses between 10.0.0.0 and 10.0.0.255. 
# The CIDR block 0.0.0.0/0 is an IP address range that includes all possible IP addresses, so this security group allows incoming requests on port 8080 from any IP.
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Deploy a cluster of web servers

resource "aws_launch_configuration" "example" {
  image_id        = "ami-0cc75a8978fbbc969"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]
  user_data       = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_availability_zones" "all" {}

# data "<PROVIDER>_<TYPE>" "<NAME>" {
#  [CONFIG ...]
# }
# Access: data.<PROVIDER>_<TYPE>.<NAME>.<ATTRIBUTE>
resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.id
  availability_zones   = data.aws_availability_zones.all.names

  min_size = 2
  max_size = 10

  load_balancers = [aws_elb.example.name]
  # default EC2: Only check unhealthy instance
  # ELB: will use health check of CLB
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "elb" {
  name = "terrafrom-example-elb"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "example" {
  name               = "terraform-asg-example"
  security_groups    = [aws_security_group.elb.id]
  availability_zones = data.aws_availability_zones.all.names

  health_check {
    target              = "HTTP:${var.server_port}/"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }
}

output "clb_dns_name" {
  value       = aws_elb.example.dns_name
  description = "The domain name of the load balancer"
}
