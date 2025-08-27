  #!/bin/bash
  echo "Hello world" > index.html 
  nohup busybox httpd -f -p ${var.server_port} &
