#!/bin/bash
sudo apt-get update -y
sudo apt-get install ec2-instance-connect
sudo apt-get install -y apache2
echo "Hello, World!" | sudo tee /var/www/html/index.html
sudo service apache2 start
sudo systemctl enable apache2
