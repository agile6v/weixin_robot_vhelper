Introduction
====

微信公共账号 “V哥助手” 基于nginx lua开发，通过整合开放数据平台API实现如下功能：

1. 天气查询
2. 人脸检测
3. 智能听歌
4. 智能查书
5. 智能翻译


Requirements
====
[nginx-1.4.4](http://nginx.org/)
[lua-nginx-module](https://github.com/chaoslawful/lua-nginx-module)
[LuaJIT](http://luajit.org)
[LuaXML](http://viremo.eludi.net/LuaXML)
[lua-resty-http](https://github.com/pintsized/lua-resty-http/)
[lua-cjson](http://www.kyne.com.au/~mark/)


Installation
====
1. 下载vhelper, 执行install.sh（自动下载所有依赖库）
2. 根据sample configuration修改nginx.conf
3. export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
4. 执行nginx -t检查配置是否正确

Sample Configuration
====
```bash
http {

    resolver 8.8.8.8;

    lua_package_path '/usr/dev/workspace/?.lua;/usr/dev/lua-resty-http-0.02/lib/?.lua;/usr/dev/LuaXML/?.lua;;';
    init_by_lua 'local xml = require "LuaXml"';
    lua_need_request_body on;

    server {
        listen      6789;
        server_name  *.example.com;
        
        location / {
            root   html;
            index  index.html index.htm;
        }

        location /weixin {
            content_by_lua_file /usr/dev/workspace/vhelper_robot.lua;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
}
```


Example
====
使用微信扫一扫，添加微信公共账号 “V哥助手” 体验效果：

![V哥助手二维码](http://mmbiz.qpic.cn/mmbiz/govJ6sqSicNPQkClUt8ialprRIrozQuLP3IB676Mv8XMve09Yib3OnZZMKKQibRjJ0u4Ovclpib3TbVY4suUQfDEIQg/0)
