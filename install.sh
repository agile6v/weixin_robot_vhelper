#!/bin/sh

if [ ! -e nginx-1.4.4.tar.gz ]; then
    wget http://nginx.org/download/nginx-1.4.4.tar.gz
    tar xzvf nginx-1.4.4.tar.gz
fi

if [ ! -e v0.9.4 ]; then
    wget https://github.com/chaoslawful/lua-nginx-module/archive/v0.9.4.tar.gz --no-check-certificate
    tar xzvf v0.9.4
fi

if [ ! -e pcre-8.33.tar.gz ]; then
    wget sourceforge.net/projects/pcre/files/pcre/8.33/pcre-8.33.tar.gz
    tar xzvf pcre-8.33.tar.gz 
fi

if [ ! -e LuaJIT-2.0.2.tar.gz ]; then
    wget http://luajit.org/download/LuaJIT-2.0.2.tar.gz
    tar xzvf LuaJIT-2.0.2.tar.gz;
    cd LuaJIT-2.0.2/;
    make && make install; 
    cd -;
fi

export C_INCLUDE_PATH=$C_INCLUDE_PATH:/usr/local/include/luajit-2.0/
ln -s /usr/local/lib/libluajit-5.1.so.2.0.2 /usr/local/lib/libluajit-5.1.so.2
ln -s /usr/local/lib/libluajit-5.1.so.2.0.2 /usr/local/lib/liblua.so

if [ ! -e LuaXML_101012.zip ]; then
    wget http://viremo.eludi.net/LuaXML/LuaXML_101012.zip 
    mkdir -p LuaXML; 
    unzip LuaXML_101012.zip -d LuaXML;
    cd LuaXML && make 
    cp LuaXML_lib.so /usr/local/lib/lua/5.1/;
    cd -;
fi

if [ ! -e lua-resty-http.tar.gz ]; then
    wget https://github.com/pintsized/lua-resty-http/archive/v0.02.tar.gz --no-check-certificate
    mv v0.02 lua-resty-http.tar.gz
    tar xzvf lua-resty-http.tar.gz
fi


if [ ! -e lua-cjson-2.1.0.tar.gz ]; then
    wget http://www.kyne.com.au/~mark/software/download/lua-cjson-2.1.0.tar.gz
    tar xzvf lua-cjson-2.1.0.tar.gz
    cd lua-cjson-2.1.0/
    make && make install;
    cd -
fi

export LUAJIT_INC=/usr/local/include/luajit-2.0
export LUAJIT_LIB=/usr/local/lib/lua/5.1

DIR=`pwd`
cd nginx-1.4.4/

./configure --add-module=$DIR/lua-nginx-module-0.9.4/ --with-pcre=$DIR/pcre-8.33/ && make -j2 && make install;
