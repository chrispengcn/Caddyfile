#!/bin/bash

# 定义变量（可根据实际情况修改）
CADDY_CONTAINER_NAME="caddy"  # 容器名称
LOCAL_CADDYFILE="./Caddyfile"  # 本地配置文件路径
CONTAINER_CADDYFILE="/etc/caddy/Caddyfile"  # 容器内配置文件路径

# 步骤1：检查本地配置文件是否存在
if [ ! -f "$LOCAL_CADDYFILE" ]; then
    echo "错误：本地配置文件 $LOCAL_CADDYFILE 不存在！"
    exit 1
fi

# 步骤2：使用 Caddy 容器验证配置文件语法
echo "正在验证配置文件语法..."
if docker run --rm -v "$LOCAL_CADDYFILE:$CONTAINER_CADDYFILE" caddy caddy validate --config "$CONTAINER_CADDYFILE"; then
    echo "配置文件语法验证通过 ✅"
else
    echo "错误：配置文件语法无效 ❌，请检查修正后再重试。"
    exit 1
fi

# 步骤3：复制配置文件到目标路径（如果需要持久化到宿主机 /etc/caddy 目录）
echo "正在复制配置文件到 $CONTAINER_CADDYFILE ..."
sudo cp "$LOCAL_CADDYFILE" "$CONTAINER_CADDYFILE"  # 使用 sudo 确保权限足够
if [ $? -ne 0 ]; then
    echo "错误：复制配置文件失败 ❌"
    exit 1
fi

# 步骤4：重启 Caddy 容器使配置生效
echo "正在重启 $CADDY_CONTAINER_NAME 容器..."
if docker restart "$CADDY_CONTAINER_NAME"; then
    echo "容器重启成功 ✅，新配置已应用。"
else
    echo "错误：容器重启失败 ❌，请检查容器状态。"
    exit 1
fi

# 步骤5：查看容器日志（可选，确认启动状态）
echo "查看最新日志（按 Ctrl+C 退出）："
docker logs -f "$CADDY_CONTAINER_NAME"