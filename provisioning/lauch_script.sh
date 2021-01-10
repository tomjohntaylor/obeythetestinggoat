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
SITENAME="otg.tj-t.com"
DJANGO_DEBUG_FALSE="y"
DJANGO_SECRET_KEY=$(python3 -c "import random; print(\"\".join(random.SystemRandom().choices(\"abcdefghijklmnopqrstuvwxyz0123456789\", k=50)))")
echo "export SITENAME=$SITENAME" >> /etc/profile
echo "export DJANGO_DEBUG_FALSE=y" >> /etc/profile
echo "export DJANGO_SECRET_KEY=$DJANGO_SECRET_KEY" >> /etc/profile

# packages
# rm /var/lib/apt/lists/lock
# rm /var/cache/apt/archives/lock
# rm /var/lib/dpkg/lock
sleep 20s # need because of "Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend)" issues
apt-get --yes update
apt-get --yes install python3.7 git virtualenv nginx


# nginx config file
systemctl start nginx
bash -c 'echo "server {" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "    listen 80;" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "    server_name otg.tj-t.com;" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "    location /static {" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "        alias /home/ubuntu/sites/otg.tj-t.com/static;" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "    }" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "    location / {" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "        proxy_pass http://unix:/tmp/otg.tj-t.com.socket;" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "        proxy_set_header Host \$host;" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "    }" >> /etc/nginx/sites-available/otg.tj-t.com'
bash -c 'echo "}" >> /etc/nginx/sites-available/otg.tj-t.com'

ln -s /etc/nginx/sites-available/$SITENAME /etc/nginx/sites-enabled/$SITENAME
rm /etc/nginx/sites-enabled/default

# git clone & pull
runuser -l  ubuntu -c 'git clone https://github.com/tomjohntaylor/obeythetestinggoat.git ~/sites/$SITENAME'
runuser -l  ubuntu -c 'cd ~/sites/$SITENAME; git pull'

# site environment variables to .env file 
runuser -l  ubuntu -c 'echo "DJANGO_DEBUG_FALSE=y" >> ~/sites/$SITENAME/.env'
runuser -l  ubuntu -c 'echo "SITENAME=$SITENAME" >> ~/sites/$SITENAME/.env'
runuser -l  ubuntu -c 'echo "DJANGO_SECRET_KEY=$DJANGO_SECRET_KEY"  >> ~/sites/$SITENAME/.env'

# virtualenv setup
runuser -l  ubuntu -c 'virtualenv ~/sites/$SITENAME/virtualenv --python=python3.7'
runuser -l  ubuntu -c '~/sites/$SITENAME/virtualenv/bin/pip install -r ~/sites/$SITENAME/requirements.txt'

# migration & static files collection
runuser -l  ubuntu -c '~/sites/$SITENAME/virtualenv/bin/python ~/sites/$SITENAME/manage.py makemigrations --noinput'
runuser -l  ubuntu -c '~/sites/$SITENAME/virtualenv/bin/python ~/sites/$SITENAME/manage.py migrate --noinput'
runuser -l  ubuntu -c '~/sites/$SITENAME/virtualenv/bin/python ~/sites/$SITENAME/manage.py collectstatic --noinput'

# # server start
# nohup runuser -l  ubuntu -c 'cd ~/sites/$SITENAME; ./virtualenv/bin/gunicorn --bind unix:/tmp/otg.tj-t.com.socket superlists.wsgi:application' &
# systemctl reload nginx

# service systemd registration
bash -c 'echo "[Unit]" >> /etc/systemd/system/gunicorn-superlists-otg.tj-t.com.service'
bash -c 'echo "Description=Gunicorn server for otg.tj-t.com" >> /etc/systemd/system/gunicorn-superlists-otg.tj-t.com.service'
bash -c 'echo "" >> /etc/systemd/system/gunicorn-superlists-otg.tj-t.com.service'
bash -c 'echo "[Service]" >> /etc/systemd/system/gunicorn-superlists-otg.tj-t.com.service'
bash -c 'echo "Restart=on-failure  " >> /etc/systemd/system/gunicorn-superlists-otg.tj-t.com.service'
bash -c 'echo "User=ubuntu  " >> /etc/systemd/system/gunicorn-superlists-otg.tj-t.com.service'
bash -c 'echo "WorkingDirectory=/home/ubuntu/sites/otg.tj-t.com  " >> /etc/systemd/system/gunicorn-superlists-otg.tj-t.com.service'
bash -c 'echo "EnvironmentFile=/home/ubuntu/sites/otg.tj-t.com/.env  " >> /etc/systemd/system/gunicorn-superlists-otg.tj-t.com.service'
bash -c 'echo "" >> /etc/systemd/system/gunicorn-superlists-otg.tj-t.com.service'
bash -c 'echo "ExecStart=/home/ubuntu/sites/otg.tj-t.com/virtualenv/bin/gunicorn --bind unix:/tmp/otg.tj-t.com.socket superlists.wsgi:application" >> /etc/systemd/system/gunicorn-superlists-otg.tj-t.com.service'
bash -c 'echo "" >> /etc/systemd/system/gunicorn-superlists-otg.tj-t.com.service'
bash -c 'echo "[Install]" >> /etc/systemd/system/gunicorn-superlists-otg.tj-t.com.service'
bash -c 'echo "WantedBy=multi-user.target " >> /etc/systemd/system/gunicorn-superlists-otg.tj-t.com.service'

# server start
systemctl daemon-reload
systemctl enable gunicorn-superlists-otg.tj-t.com
systemctl start gunicorn-superlists-otg.tj-t.com
systemctl reload nginx

# EOF
################
