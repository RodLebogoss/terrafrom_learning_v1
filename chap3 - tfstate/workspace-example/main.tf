provider "aws" {

  region = "eu-north-1" #les informations sur le provider
  
}

resource "aws_instance" "workspace_example_vm" {
  ami = "ami-042b4708b1d05f512" #
  instance_type = "t3.micro"
}