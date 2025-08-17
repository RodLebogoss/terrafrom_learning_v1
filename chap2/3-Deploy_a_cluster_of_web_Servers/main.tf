#provider
provider "aws" {
  region = "eu-north-1"
  
}

#launch config of asg. Launch configuration est dérécié. On utilisera launch template
resource "aws_launch_template" "Mask_asg_test" {

  image_id = "ami-042b4708b1d05f512"
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.Mask_asg_security_group.id]

  user_data = base64encode(<<-EOF
  #!/bin/bash
  echo "Hello world" > index.html 
  nohup busybox httpd -f -p ${var.server_port} &
  EOF
  )
#Permet à Terraform de créer la nouvelle ressource avant de supprimer l’ancienne

  lifecycle{
    create_before_destroy = true
  }                                      
}
#create asg
resource "aws_autoscaling_group" "example" {
  #launch_configuration = aws_launch_configuration.Mask_asg_test.name
  vpc_zone_identifier = data.aws_subnets.default.ids

  target_group_arns = [ aws_lb_target_group.asg.arn ]
  health_check_type = "ELB"

  desired_capacity = 2
  min_size = 1
  max_size = 10

  launch_template {
    id = aws_launch_template.Mask_asg_test.id
    version = "$Latest"
  }
 #Cet ASG exécutera entre 2 et 10 instances EC2 (en commençant par 2 au lancement)
  tag {
    key = "Name"
    value = "Tp_Autoscaling_Group"
    propagate_at_launch = true
  }
}
#security group asg
resource "aws_security_group" "Mask_asg_security_group" {
  name = "Mask_Security_Group_example"

  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

data "aws_vpc" "default" {
  default = true
  
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
#création du load balancer avec la ressource aws_lb 

resource "aws_lb" "Mask_lb" {
  name = "Mask-Load-Balancer"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
#attache du security group a notre alb
  security_groups = [ aws_security_group.alb.id ]

}
#Definition d'un listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.Mask_lb.arn
  port = var.alb_port
  protocol = "HTTP"

  #par défaut, renvoie une page 404 simple
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: Page not found"
      status_code = 404
    }
  }
}
#Définition d'un security group ASG

resource "aws_security_group" "alb" {
  name = "alb_security_group"

#Autoriser les requêtes http entrante
  ingress {
    from_port = var.alb_port
    to_port = var.alb_port
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
#autoriser les requêtes http sortante
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  
}

#création du groupe cible pour l'asg. Le target group vérifie la santé des instances via HTTP.
resource "aws_lb_target_group" "asg" {
  name = "terraform-asg-example"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

  health_check {
    unhealthy_threshold = 2
    path = "/"
    protocol = "HTTP"
    matcher = 200
    interval = 30
    timeout = 10
    healthy_threshold = 2
  }
  
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}