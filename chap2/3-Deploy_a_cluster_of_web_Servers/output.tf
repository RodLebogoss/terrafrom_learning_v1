output "alb_dns_name" {
  value = aws_lb.Mask_lb.dns_name
  description = "Nom de domaine du load balancer"
}