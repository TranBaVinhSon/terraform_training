provider "aws" {
  profile = "default" # default profile in ~/.aws/config
  region  = "ap-northeast-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0183ac312a029c38c"
  instance_type = "t2.micro"
}

resource "aws_eip" "ip" {
  vpc      = true
  instance = "${aws_instance.example.id}"
}
