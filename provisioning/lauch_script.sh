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

apt --yes update
apt --yes install python3.7 git virtualenv

runuser -l  ubuntu -c 'git clone https://github.com/tomjohntaylor/obeythetestinggoat.git ~/sites/$SITENAME'
runuser -l  ubuntu -c 'cd ~/sites/$SITENAME; git pull'
runuser -l  ubuntu -c 'virtualenv ~/sites/$SITENAME/virtualenv --python=python3.7'
runuser -l  ubuntu -c '~/sites/$SITENAME/virtualenv/bin/pip install -r ~/sites/$SITENAME/requirements.txt'
runuser -l  ubuntu -c '~/sites/$SITENAME/virtualenv/bin/python ~/sites/$SITENAME/manage.py migrate --noinput'
runuser -l  ubuntu -c '~/sites/$SITENAME/virtualenv/bin/python ~/sites/$SITENAME/manage.py runserver 0.0.0.0:8000 --noreload'
