#!bin/bash
yum install httpd -y
chkconfig httpd on
echo "Welcome to terraform" > /var/www/html/index.html
service httpd start
