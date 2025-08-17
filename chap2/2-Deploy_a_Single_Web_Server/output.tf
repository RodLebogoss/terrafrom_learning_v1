output "public_ip" {
  value = aws_instance.Mask_single_web_server.public_ip
  description = "public ip of server"
}