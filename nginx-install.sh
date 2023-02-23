#!/bin/bash

# openresty install
# ./configure \
# --prefix=/home/work/progam/openresry/program \
# --with-luajit \
# --with-http_stub_status_module \
# --with-pcre \
# --with-pcre-jit \
# --add-module=/home/work/progam/openresry/ngx_openresty-1.9.7.1/moudels/upstream-fair/

cd ~

NGINX_DIR=nginx-1.22.1

rm -rf ./${NGINX_DIR}
rm -rf ./${NGINX_DIR}.tar.gz

wget http://nginx.org/download/${NGINX_DIR}.tar.gz

sudo tar -zxvf ./${NGINX_DIR}.tar.gz

cd ./${NGINX_DIR}

sudo ./configure --with-http_ssl_module
