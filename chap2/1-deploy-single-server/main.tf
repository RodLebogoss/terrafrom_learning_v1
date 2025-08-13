provider "aws" {

  region = "eu-north-1" #les informations sur le provider
  
}

resource "aws_instance" "Mask_vm_instance1" {

  ami = "ami-042b4708b1d05f512" #
  instance_type = "t3.micro"

  tags = {
    Name = "Mask_vm_instance1" # Ajout du nom de l'instance avec l'attribut tags
  }
  
}