# 使用你指定的 Flink 镜像作为基础镜像
FROM alexmerced/flink-iceberg:latest

# 更新系统并安装必要的工具
RUN apt-get update && \
    apt-get install -y --no-install-recommends supervisor nginx wget curl && \
    rm -rf /var/lib/apt/lists/*


# 配置 Nginx
RUN rm /etc/nginx/sites-enabled/default

# 将新的 nginx.conf 文件添加到容器中
COPY nginx.conf /etc/nginx/nginx.conf

# 将 HTTP server 块复制到 sites-enabled
COPY default.conf /etc/nginx/sites-enabled/default

# 将 TCP 代理配置复制到适当的位置
COPY stream_proxy.conf /etc/nginx/conf.d/stream_proxy.conf

# 配置 Supervisord
# Copy the local supervisord.conf file into the container
#COPY supervisord.conf /etc/supervisor/supervisord.conf

# Create the necessary directories
RUN mkdir -p /var/log/supervisor /etc/supervisor/conf.d
COPY start.sh /usr/local/bin/start.sh

# 赋予脚本可执行权限
RUN chmod +x /usr/local/bin/start.sh

# 暴露必要的端口
# 80 端口用于 Nginx
# 8081 端口用于 Flink Web UI
# 9060 端口用于 TCP 代理
EXPOSE 80 8081 9060

# 设置容器启动时执行的命令
#CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
CMD ["/usr/local/bin/start.sh"]

