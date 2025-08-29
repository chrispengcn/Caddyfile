#!/bin/bash

# 更新系统
echo "更新系统..."
sudo apt update && sudo apt upgrade -y

# 安装 Docker
echo "安装 Docker..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce
sudo systemctl enable docker
sudo systemctl start docker
# 允许当前用户运行docker命令（可选）
sudo usermod -aG docker $USER

# 安装 Caddy
echo "安装 Caddy..."
curl -fsSL https://get.caddyserver.com | bash
sudo systemctl enable caddy
sudo systemctl start caddy

# 安装 MariaDB
echo "安装 MariaDB..."
sudo apt install -y mariadb-server
sudo systemctl enable mariadb
sudo systemctl start mariadb

# 设置 MariaDB 安全性
echo "配置 MariaDB 安全性..."
sudo mysql_secure_installation

# 创建必要的目录
echo "创建网站和配置目录..."
sudo mkdir -p /home/www
sudo mkdir -p /home/openlitespeed/conf
sudo chmod -R 755 /home/www
sudo chmod -R 755 /home/openlitespeed

# 使用Docker运行OpenLiteSpeed
echo "启动 OpenLiteSpeed Docker 容器..."
sudo docker run -d \
  --name openlitespeed \
  --network host \
  -p 8080:80 \
  -p 8443:443 \
  -v /home/www:/home/www \
  -v /usr/local/lsws/conf:/usr/local/lsws/conf \
  --restart always \
  litespeedtech/openlitespeed:latest

# 输出安装状态
echo "Caddy, MariaDB 和 OpenLiteSpeed Docker 容器已安装完成！"
echo "Caddy 默认访问地址: http://localhost:2015"
echo "OpenLiteSpeed 访问地址: http://localhost:8080"
echo "OpenLiteSpeed HTTPS 访问地址: https://localhost:8443"
