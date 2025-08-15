provider "aws" {

  region = "eu-north-1"
  
}

resource "aws_instance" "Mask_single_web_server" {

  ami = "ami-042b4708b1d05f512"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.Mask_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello world" > index.html 
              nohup busybox httpd -f -p 8080 &

              EOF                       
  user_data_replace_on_change = true

  tags = {
    Name = "Tp_Single_Web_server"
  }
  
}

resource "aws_security_group" "Mask_sg" {

  name = "Mask_Security_Group_example"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}