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

cd ~

NGINX_DIR=nginx-1.22.1

sudo rm -rf /usr/local/nginx
sudo rm -rf /usr/local/nginx/sbin/nginx
sudo rm -rf /usr/local/nginx/modules
sudo rm -rf /usr/local/nginx/conf
sudo rm -rf /usr/local/nginx/conf/nginx.conf
sudo rm -rf /usr/local/nginx/logs/nginx.pid
sudo rm -rf /usr/local/nginx/logs/error.log
sudo rm -rf /usr/local/nginx/logs/access.log

sudo rm -rf ./${NGINX_DIR}
sudo rm -rf ./${NGINX_DIR}.tar.gz

wget http://nginx.org/download/${NGINX_DIR}.tar.gz

sudo tar -zxvf ./${NGINX_DIR}.tar.gz

cd ./${NGINX_DIR}

sudo ./configure --with-http_ssl_module

sudo make




