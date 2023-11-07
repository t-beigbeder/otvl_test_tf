provider "aws" {
  region = "eu-west-3"
}

resource "aws_instance" "example" {
  ami           = "ami-087da76081e7685da"
  instance_type = "t2.micro"
}