provider "aws" {
  region = "eu-north-1"
}

resource "aws_launch_template" "Mask_web_server" {

  image_id = "ami-042b4708b1d05f512"
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.Mask_asg_security_group.id]
#appel du fichier user_data.sh avec templatefile
  user_data = templatefile("user_data.sh", {
    server_port = var.server_port
  })
  
  lifecycle {
    create_before_destroy = true
  }
  
}
resource "aws_autoscaling_group" "asg_for_webserver" {
  vpc_zone_identifier = data.aws_subnets.default.ids

  target_group_arns = [ aws_lb_target_group.asg.arn ]
  health_check_type = "ELB"

  desired_capacity = 2
  min_size = 1
  max_size = 5

  launch_template {
    id = aws_launch_template.Mask_web_server.id
    version = "$Latest"
  }
  tag {
    key = "Name"
    value = "asg_for_webserver"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "Mask_asg_security_group" {
  name = "Mask_Security_group_Web_Server"

  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = [ "O.O.O.O/0" ]
  }
  
}

data "aws_vpc" "Vpc_Web_Servers" {
  default = true
}

data "aws_subnets" "subnets_vpc_ws" {
  filter {
    name = "vpc-id"
    values = [ data.aws_vpc.Vpc_Web_Servers.id ]
  }
}

resource "aws_lb" "lb_web_server" {
  name = "Mask_web_server_lb"
  load_balancer_type = "application"
  subnets = data.aws_subnets.subnets_vpc_ws.ids

  security_groups = [ aws_security_group.Mask_asg_security_group.id ]
  
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.lb_web_server.arn
  port = var.alb_port
  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: Page not found"
      status_code = 404
    }
  }
}

resource "aws_security_group" "alb" {

  name = "alb_security_group"

  ingress {
    from_port = var.alb_port
    to_port = var.alb_port
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  
}

resource "aws_lb_target_group" "asg_target_group" {

  name = "Web_server_tgt"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.Vpc_Web_Servers.id

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

resource "aws_lb_listener_rule" "asg_listener_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  condition {
    path_pattern {
      values = [ "*" ]
    }
  }
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg_target_group.arn
  }
  
}