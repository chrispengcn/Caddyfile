#!/bin/bash

# 更新系统
echo "更新系统..."
sudo apt update && sudo apt upgrade -y

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

# 安装 OpenLiteSpeed
echo "安装 OpenLiteSpeed..."
# 安装依赖
sudo apt install -y lsb-release wget
# 下载并安装 OpenLiteSpeed
wget -qO - https://repo.litespeedtech.com/packages/enable_openlitespeed_repo.sh | sudo bash
sudo apt install -y openlitespeed

# 启动 OpenLiteSpeed
echo "启动 OpenLiteSpeed..."
sudo systemctl enable openlitespeed
sudo systemctl start openlitespeed

# 输出安装状态
echo "Caddy, MariaDB 和 OpenLiteSpeed 已安装完成！"
echo "Caddy 默认访问地址: http://localhost:2015"
echo "OpenLiteSpeed 默认访问地址: http://localhost:8088"
