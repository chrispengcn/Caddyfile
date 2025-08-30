#!/bin/bash

# Update the system
echo "Updating the system..."
sudo apt update && sudo apt upgrade -y

# Install Docker
echo "Installing Docker..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce
sudo systemctl enable docker
sudo systemctl start docker
# Allow the current user to run Docker commands (optional)
sudo usermod -aG docker $USER

# Install Caddy
echo "Installing Caddy..."
curl -fsSL https://get.caddyserver.com | bash
sudo systemctl enable caddy
sudo systemctl start caddy

# Install MariaDB
echo "Installing MariaDB..."
sudo apt install -y mariadb-server
sudo systemctl enable mariadb
sudo systemctl start mariadb

# Configure MariaDB security
echo "Configuring MariaDB security..."
sudo mysql_secure_installation

# Create necessary directories
echo "Creating website and configuration directories..."
sudo mkdir -p /home/www
sudo mkdir -p /home/openlitespeed/conf
sudo chmod -R 755 /home/www
sudo chmod -R 755 /home/openlitespeed

# Run OpenLiteSpeed with Docker
echo "Starting OpenLiteSpeed Docker container..."
sudo docker run -d \
  --name openlitespeed \
  --network host \
  -p 8080:80 \
  -p 8443:443 \
  -p 7080:7080 \
  -v /home/www:/home/www \
  -v /usr/local/lsws/conf:/usr/local/lsws/conf \
  --restart always \
  litespeedtech/openlitespeed:latest

# Download and extract phpMyAdmin to the specified directory
echo "Installing phpMyAdmin..."
PHPMYADMIN_VERSION="5.2.1"  # Use stable version
cd /home/www/demo.site/html
sudo wget https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz
sudo tar -zxvf phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz
sudo mv phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages phpmyadmin
sudo rm phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz
sudo chown -R nobody:nogroup /home/www/demo.site/html/phpmyadmin

# Varnish installation prompt
read -p "Do you want to install Varnish cache? (Y/N): " varnish_install
if [[ "$varnish_install" == "Y" || "$varnish_install" == "y" ]]; then
  echo "Installing Varnish cache..."
  sudo docker run -d \
    --name varnish \
    --network host \
    -p 6081:80 \
    -v /etc/varnish:/etc/varnish \
    -v /usr/share/varnish:/usr/share/varnish \
    --restart always \
    varnish:stable
  echo "Varnish installation complete, access at: http://localhost:6081"
else
  echo "Skipping Varnish installation."
fi

# Output installation status
echo "Caddy, MariaDB, and OpenLiteSpeed Docker containers have been installed!"
echo "Caddy default access address: http://localhost:2015"
echo "OpenLiteSpeed access address: http://localhost:8080"
echo "OpenLiteSpeed HTTPS access address: https://localhost:8443"
echo "OpenLiteSpeed Admin Panel access address: https://localhost:7080"
echo "Varnish default address: https://localhost:6081"
