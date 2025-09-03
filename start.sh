#!/bin/bash

# 创建 supervisord.conf 基础配置
cat >/etc/supervisor/conf.d/supervisord.conf <<EOF
[supervisord]
nodaemon=true

[program:nginx]
command=/usr/sbin/nginx -g "daemon off;"
autostart=true
autorestart=true
stderr_logfile=/var/log/supervisor/nginx.err.log
stdout_logfile=/var/log/supervisor/nginx.out.log
EOF

# 根据环境变量动态添加 Flink 程序
if [ "$FLINK_ROLE" = "jobmanager" ]; then
  cat >>/etc/supervisor/conf.d/supervisord.conf <<EOF
[program:jobmanager]
command=/opt/flink/bin/jobmanager.sh start-foreground
autostart=true
autorestart=true
stderr_logfile=/var/log/supervisor/jobmanager.err.log
stdout_logfile=/var/log/supervisor/jobmanager.out.log
EOF
elif [ "$FLINK_ROLE" = "taskmanager" ]; then
  cat >>/etc/supervisor/conf.d/supervisord.conf <<EOF
[program:taskmanager]
command=/opt/flink/bin/taskmanager.sh start-foreground
autostart=true
autorestart=true
stderr_logfile=/var/log/supervisor/taskmanager.err.log
stdout_logfile=/var/log/supervisor/taskmanager.out.log
EOF
fi

# 启动 supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
