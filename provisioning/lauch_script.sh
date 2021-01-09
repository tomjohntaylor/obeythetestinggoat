#!/bin/bash

###############
# Data
# OS: Ubuntu 18.04 LTS
################


# SYSTEM CONFIGURATION
# ssh port change to 443
sed -i "s/#Port 22/Port 443/" /etc/ssh/sshd_config
service sshd restart


# SITE CONFIGURATION
echo "export SITENAME="otg.tj-t.com"" >> /etc/profile

# packages
apt --yes update
apt --yes install python3.7 git virtualenv nginx

# nginx config file
bash -c 'echo "server {" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "    listen 80;" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "    server_name otg.tj-t.com;" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "    location /static {" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "        alias /home/ubuntu/sites/otg.tj-t.com/static;" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "    }" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "    location / {" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "        proxy_pass http://localhost:8000;" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "    }" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "}" >> /etc/nginx/sites-available/otg.tj-t.com'

ln -s /etc/nginx/sites-available/$SITENAME /etc/nginx/sites-enabled/$SITENAME
rm /etc/nginx/sites-enabled/default

# git clone & pull
runuser -l  ubuntu -c 'git clone https://github.com/tomjohntaylor/obeythetestinggoat.git ~/sites/$SITENAME'
runuser -l  ubuntu -c 'cd ~/sites/$SITENAME; git pull'

# virtualenv setup
runuser -l  ubuntu -c 'virtualenv ~/sites/$SITENAME/virtualenv --python=python3.7'
runuser -l  ubuntu -c '~/sites/$SITENAME/virtualenv/bin/pip install -r ~/sites/$SITENAME/requirements.txt'

# static files collection
runuser -l  ubuntu -c 'cd ~/sites/$SITENAME/virtualenv/bin/python manage.py collectstatic --noinput'

# server start
runuser -l  ubuntu -c 'cd ~/sites/$SITENAME; ./virtualenv/bin/gunicorn superlists.wsgi:application'
systemctl start nginx

# EOF
################

sudo apt --yes install nginx
sudo systemctl start nginx
sudo bash -c 'echo "server {" >> /etc/nginx/sites-available/otg.tj-t.com'
sudo bash -c 'echo "    listen 80;" >> /etc/nginx/sites-available/otg.tj-t.com'
sudo bash -c 'echo "    server_name otg.tj-t.com;" >> /etc/nginx/sites-available/otg.tj-t.com'
sudo bash -c 'echo "" >> /etc/nginx/sites-available/otg.tj-t.com'
sudo bash -c 'echo "    location /static {" >> /etc/nginx/sites-available/otg.tj-t.com'
sudo bash -c 'echo "        alias /home/ubuntu/sites/otg.tj-t.com/static;" >> /etc/nginx/sites-available/otg.tj-t.com'
sudo bash -c 'echo "    }" >> /etc/nginx/sites-available/otg.tj-t.com'
sudo bash -c 'echo "" >> /etc/nginx/sites-available/otg.tj-t.com'
sudo bash -c 'echo "    location / {" >> /etc/nginx/sites-available/otg.tj-t.com'
sudo bash -c 'echo "        proxy_pass http://localhost:8000;" >> /etc/nginx/sites-available/otg.tj-t.com'
sudo bash -c 'echo "    }" >> /etc/nginx/sites-available/otg.tj-t.com'
sudo bash -c 'echo "}" >> /etc/nginx/sites-available/otg.tj-t.com'

sudo ln -s /etc/nginx/sites-available/$SITENAME /etc/nginx/sites-enabled/$SITENAME
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl reload nginx

runuser -l  ubuntu -c 'cd ~/sites/$SITENAME/virtualenv/bin/python manage.py collectstatic --noinput'
runuser -l  ubuntu -c 'cd ~/sites/$SITENAME; ./virtualenv/bin/gunicorn superlists.wsgi:application'
