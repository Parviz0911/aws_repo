#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl enable httpd
sudo bash -c 'echo "<h1>App1</h1>" > /var/www/html/index.html'
sudo systemctl start httpd
