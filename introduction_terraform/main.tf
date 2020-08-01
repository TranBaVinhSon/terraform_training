provider "aws" {
  profile = "default" # default profile in ~/.aws/config
  region  = "ap-northeast-1"
}

# resource "<PROVIDER>_<TYPE>" "<NAME>" {
#  [CONFIG …]
# }
resource "aws_instance" "example" {
  ami           = "ami-0183ac312a029c38c" # Using Packer to create custom AMI
  instance_type = "t2.micro"
  # <PROVIDER>_<TYPE>.<NAME>.<ATTRIBUTE>
  vpc_security_group_ids = [aws_security_group.instance.id]
  # AWS will execute when the instance is booting
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
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
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
