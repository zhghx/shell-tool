#!/bin/bash

# openresty install
# ./configure \
# --prefix=/home/work/progam/openresry/program \
# --with-luajit \
# --with-http_stub_status_module \
# --with-pcre \
# --with-pcre-jit \
# --add-module=/home/work/progam/openresry/ngx_openresty-1.9.7.1/moudels/upstream-fair/

#Configuration summary info
#  + using system PCRE library
#  + using system OpenSSL library
#  + using system zlib library
#
#  nginx path prefix: "/usr/local/nginx"
#  nginx binary file: "/usr/local/nginx/sbin/nginx"
#  nginx modules path: "/usr/local/nginx/modules"
#  nginx configuration prefix: "/usr/local/nginx/conf"
#  nginx configuration file: "/usr/local/nginx/conf/nginx.conf"
#  nginx pid file: "/usr/local/nginx/logs/nginx.pid"
#  nginx error log file: "/usr/local/nginx/logs/error.log"
#  nginx http access log file: "/usr/local/nginx/logs/access.log"
#  nginx http client request body temporary files: "client_body_temp"
#  nginx http proxy temporary files: "proxy_temp"
#  nginx http fastcgi temporary files: "fastcgi_temp"
#  nginx http uwsgi temporary files: "uwsgi_temp"
#  nginx http scgi temporary files: "scgi_temp"

######## Run Bash ########
# bash <(curl -sL https://raw.githubusercontent.com/zhghx/shell-tool/main/nginx-install.sh)
######## Run Bash ########

# Nginx Version
NGINX_DIR=nginx-1.22.1

# *****************************************************
# *********************  PARAM  ***********************
DOMAIN="www.haoxuan.click"         # 有证书得域名
REMOTE_HOST="maimai.sega.jp"       # 替换域名
PROXY_URL="https://maimai.sega.jp" # 代理地址
ALLOW_SPIDER="n"                   # 是否允许爬虫
TLS="true"                         # 支持TLS协议
WS="true"                          # 支持WS协议
XTLS="true"                        # 支持XTLS协议
PORT="443"                         # SSL端口
XPORT="55555"                      # Xray端口
WSPATH="/pkchkejqbf"               # Xray Path
# *********************  PARAM  ***********************
# *****************************************************

# 环境变量可用快捷链接 link file
NGINX_BIN_LINK="/usr/bin/nginx"
# Systemctl 配置服务 systemctl service
NGINX_SYSTEMCTL_CONFIG="/usr/lib/systemd/system/nginx.service"
# Nginx 源码安装时默认目录
NGINX_DEF_DIR="/usr/local/nginx"
# Nginx 源码安装时默认得可执行文件安装位置BIN
NGINX_DEF_SBIN="/usr/local/nginx/sbin/nginx"
# Nginx 源码安装时模块存放位置
NGINX_MODULES="/usr/local/nginx/modules"
# Nginx 源码安装时默认得配置文件
NGINX_CONFIG_DIR="/usr/local/nginx/conf"
# Nginx PID FILE
NGINX_PID_FILE="/usr/local/nginx/logs/nginx.pid"
# Nginx Error Log
NGINX_ERROR_LOG="/usr/local/nginx/logs/error.log"
# Nginx Access Log
NGINX_ACCESS_LOG="/usr/local/nginx/logs/access.log"
# Certificates
CERTIFICATES_DIR="/usr/local/nginx/certificates"

deleteDownloadFile() {
    sudo rm -rf ~/${NGINX_DIR}
    sudo rm -rf ~/${NGINX_DIR}.tar.gz
}

downloadFile() {
    wget http://nginx.org/download/${NGINX_DIR}.tar.gz
}

copyCertificates() {
    mkdir -p ${CERTIFICATES_DIR}
    cp ~/xray.crt ${CERTIFICATES_DIR}/${DOMAIN}.crt
    cp ~/xray.key ${CERTIFICATES_DIR}/${DOMAIN}.key
}

resetNginxFile() {
    sudo rm -rf ${NGINX_BIN_LINK}         # link file
    sudo rm -rf ${NGINX_SYSTEMCTL_CONFIG} # systemctl service
    sudo rm -rf ${NGINX_DEF_DIR}
    sudo rm -rf ${NGINX_DEF_SBIN}
    sudo rm -rf ${NGINX_MODULES}
    sudo rm -rf ${NGINX_CONFIG_DIR}
    sudo rm -rf ${NGINX_CONFIG_DIR}/nginx.conf
    sudo rm -rf ${NGINX_PID_FILE}
    sudo rm -rf ${NGINX_ERROR_LOG}
    sudo rm -rf ${NGINX_ACCESS_LOG}
    sudo rm -rf ${CERTIFICATES_DIR}
}

configNginx() {
    mkdir -p ${NGINX_DEF_DIR}/html
    mkdir -p ${NGINX_CONFIG_DIR}/conf.d

    if [[ "$ALLOW_SPIDER" = "n" ]]; then
        echo 'User-Agent: *' >${NGINX_DEF_DIR}/html/robots.txt
        echo 'Disallow: /' >>${NGINX_DEF_DIR}/html/robots.txt
        ROBOT_CONFIG="    location = /robots.txt {}"
    else
        ROBOT_CONFIG=""
    fi

    res=$(id nginx 2>/dev/null)
    if [[ "$?" != "0" ]]; then
        user="www-data"
    else
        user="nginx"
    fi

    cat >${NGINX_CONFIG_DIR}/nginx.conf <<-EOF
user $user;
worker_processes auto;
error_log ${NGINX_ERROR_LOG};
pid ${NGINX_PID_FILE};

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include ${NGINX_MODULES}/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  ${NGINX_ACCESS_LOG}  main;
    server_tokens off;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;
    gzip                on;

    include             ${NGINX_CONFIG_DIR}/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include ${NGINX_CONFIG_DIR}/conf.d/*.conf;
}
EOF

    if [[ "$PROXY_URL" = "" ]]; then
        action=""
    else
        action="proxy_ssl_server_name on;
        proxy_pass $PROXY_URL;
        proxy_set_header Accept-Encoding '';
        sub_filter \"$REMOTE_HOST\" \"$DOMAIN\";
        sub_filter_once off;"
    fi

    if [[ "$TLS" = "true" || "$XTLS" = "true" ]]; then
        mkdir -p ${NGINX_CONFIG_DIR}/conf.d
        # VMESS+WS+TLS
        if [[ "$WS" = "true" ]]; then
            cat >${NGINX_CONFIG_DIR}/conf.d/${DOMAIN}.conf <<-EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN};
    return 301 https://\$server_name:${PORT}\$request_uri;
}

server {
    listen       ${PORT} ssl http2;
    listen       [::]:${PORT} ssl http2;
    server_name ${DOMAIN};
    charset utf-8;

    # ssl config
    ssl_protocols TLSv1.1 TLSv1.2;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    ssl_ecdh_curve secp384r1;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_session_tickets off;
    ssl_certificate ${CERTIFICATES_DIR}/${DOMAIN}.crt;
    ssl_certificate_key ${CERTIFICATES_DIR}/${DOMAIN}.key;

    root ${NGINX_DEF_DIR}/html;
    location / {
        $action
    }
    $ROBOT_CONFIG

    location ${WSPATH} {
      proxy_redirect off;
      proxy_pass http://127.0.0.1:${XPORT};
      proxy_http_version 1.1;
      proxy_set_header Upgrade \$http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_set_header Host \$host;
      proxy_set_header X-Real-IP \$remote_addr;
      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF
        else
            # VLESS+TCP+TLS
            # VLESS+TCP+XTLS
            # trojan
            cat >${NGINX_CONFIG_DIR}/conf.d/${DOMAIN}.conf <<-EOF
server {
    listen 80;
    listen [::]:80;
    listen 81 http2;
    server_name ${DOMAIN};
    root ${NGINX_DEF_DIR}/html;
    location / {
        $action
    }
    $ROBOT_CONFIG
}
EOF
        fi
    fi
}

setSystemctl() {
    cat >${NGINX_SYSTEMCTL_CONFIG} <<-EOF

[Unit]
Description=nginx
After=network.target
[Service]
Type=forking
PIDFile=${NGINX_PID_FILE}
ExecStart=${NGINX_DEF_SBIN}
ExecReload=${NGINX_DEF_SBIN} -s reload
ExecStop=${NGINX_DEF_SBIN} -s stop
PrivateTmp=true
[Install]
WantedBy=multi-user.target

EOF
    systemctl daemon-reload
    # systemctl enable nginx.service

    #root@ip-172-31-11-16:~# systemctl enable nginx.service
    #Synchronizing state of nginx.service with SysV service script with /lib/systemd/systemd-sysv-install.
    #Executing: /lib/systemd/systemd-sysv-install enable nginx
}

cd ~

deleteDownloadFile
resetNginxFile
downloadFile

sudo tar -zxvf ./${NGINX_DIR}.tar.gz

cd ./${NGINX_DIR}

sudo ./configure --with-http_ssl_module --with-http_v2_module --with-http_sub_module

sudo make
sudo make install

deleteDownloadFile

copyCertificates

configNginx

setSystemctl

sudo ln -s ${NGINX_DEF_SBIN} ${NGINX_BIN_LINK}
