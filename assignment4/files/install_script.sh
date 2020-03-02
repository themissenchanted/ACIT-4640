#!/bin/bash
setenforce = 0
sed -r -i 's/^(%wheel\s+ALL=\(ALL\)\s+)(ALL)$/\1NOPASSWD: ALL/' /etc/sudoers
#getting the database
curl -s --user BCIT:w1nt3r2020 https://acit4640.y.vu/docs/module06/resources/mongodb_ACIT4640.tgz -o - | tar xzf -

#firewall settings
sudo firewall-cmd --zone=public --add-port=8080/tcp
sudo firewall-cmd --zone=public --list-all

#adding todoapp as a user
sudo useradd todoapp -p 'P@ssw0rd'
sudo usermod -a -G wheel todoapp
echo "user created successfully"


#installing packages
sudo yum install -y git
sudo yum install -y nodejs
sudo yum install -y npm
sudo yum install -y mongodb-server
sudo yum install -y mongodb
sudo systemctl enable mongod 
sudo systemctl start mongod
mongorestore -d acit4640 ACIT4640
echo "all packages installed"


#making app folder in home directory to clone 
sudo mkdir /home/todoapp/app
sudo chown todoapp /home/todoapp
sudo git clone https://github.com/timoguic/ACIT4640-todo-app.git /home/todoapp/app/ACIT4640-todo-app      #cloning
sudo chmod 755 /home/todoapp                                                        #giving right permissions

#installing the application
echo "Installing applications"
sudo cd /home/todoapp/app/ACIT4640-todo-app
sudo npm install --prefix /home/todoapp/app/ACIT4640-todo-app
#sudo mv /home/admin/setup/database.js /home/todoapp/app/ACIT4640-todo-app/config
sudo mv /home/admin/database.js /home/todoapp/app/ACIT4640-todo-app/config/database.js

echo "moved succesfully "

#installing nginx
sudo yum install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
#sudo mv /home/admin/setup/nginx.conf /etc/nginx/
sudo mv /home/admin/nginx.conf /etc/nginx/nginx.conf

sudo systemctl restart nginx


#running nodejs as a daemon with systemd
#sudo mv /home/admin/setup/todoapp.service /etc/systemd/system/
sudo mv /home/admin/todoapp.service /etc/systemd/system/todoapp.service
sudo systemctl daemon-reload
sudo systemctl start todoapp
sudo systemctl enable todoapp

sudo systemctl restart nginx


echo "all done"