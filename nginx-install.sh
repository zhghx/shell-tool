#!/bin/bash

# openresty install
# ./configure \
# --prefix=/home/work/progam/openresry/program \
# --with-luajit \
# --with-http_stub_status_module \
# --with-pcre \
# --with-pcre-jit \
# --add-module=/home/work/progam/openresry/ngx_openresty-1.9.7.1/moudels/upstream-fair/

#Configuration summary
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

NGINX_DIR=nginx-1.22.1

CONFIG_FILE="/usr/local/nginx/conf/nginx.conf"

deleteDownloadFile() {
    sudo rm -rf ~/${NGINX_DIR}
    sudo rm -rf ~/${NGINX_DIR}.tar.gz
}

downloadFile() {
    wget http://nginx.org/download/${NGINX_DIR}.tar.gz
}

resetNginxFile() {
    sudo rm -rf /usr/bin/nginx # link file
    sudo rm -rf /usr/local/nginx
    sudo rm -rf /usr/local/nginx/sbin/nginx
    sudo rm -rf /usr/local/nginx/modules
    sudo rm -rf /usr/local/nginx/conf
    sudo rm -rf /usr/local/nginx/conf/nginx.conf
    sudo rm -rf /usr/local/nginx/logs/nginx.pid
    sudo rm -rf /usr/local/nginx/logs/error.log
    sudo rm -rf /usr/local/nginx/logs/access.log
}

resetNginxConfig() {
    cat > $CONFIG_FILE<<-EOF
#user  nobody;
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

    server {
        listen       80;
        server_name  localhost;

        location / {
            root   html;
            index  index.html index.htm;
        }

        error_page   500 502 503 504  /50x.html;

        location = /50x.html {
            root   html;
        }

        location /.well-known/pki-validation/61D22919D27E9B245AED0E7B1D949B59.txt {
            default_type text/html;
            return 200 '865E005EC46E8432E2A78A53C77AA6C7D2729E8E4BAD332997B4F513DB75B56E
            sectigo.com
            t0523873001677076078';
        }
    }

    server {
        listen       443 ssl http2;
        listen       [::]:443 ssl http2;
        server_name dev.haoxuan.click;
        charset utf-8;

        # ssl配置
        ssl_protocols TLSv1.1 TLSv1.2;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
        ssl_ecdh_curve secp384r1;
        ssl_prefer_server_ciphers on;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;
        ssl_session_tickets off;
        ssl_certificate /usr/local/etc/xray/custom.pem;
        ssl_certificate_key /usr/local/etc/xray/custom.key;

        root /usr/share/nginx/html;
        location / {
            proxy_ssl_server_name on;
            proxy_pass https://maimai.sega.jp;
            proxy_set_header Accept-Encoding '';
            sub_filter "maimai.sega.jp" "dev.haoxuan.click";
            sub_filter_once off;
        }

        location = /robots.txt {}

        location /PiFCkYk8IGLA {
            proxy_redirect off;
            proxy_pass http://127.0.0.1:50553;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    }
}
EOF
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

resetNginxConfig

sudo ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx
