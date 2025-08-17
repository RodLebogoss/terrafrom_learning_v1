variable "server_port" {
  description = "Port number for webserver"
  type = number
  default = 8080
  
}

variable "alb_port" {

  description = "port for alb test"
  type = number
  default = 80
  
}