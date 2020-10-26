# 用于openresty的api控制脚本，用lua编写，实现功能
依赖
1. openresty
1. etcd

# 部署方式
1. 整个复制到 /usr/local/openresty/site/lualib 目录下
1. 在openresty的某个vhost中的location中加入下面的代码
                set $env "csl";
                access_by_lua_file '/usr/local/openresty/site/lualib/access_by_lua_apifilter.lua';

1. 下面是一个完整的例子
        location ~ .*\.(php|php5)($|/){
                lua_code_cache on; #生产环境要设置成on，开发环境需要设置成off
                include php_def.inc; #php的处理和定义
                set $env "csl"; #每个项目都有一个代号，csl表示快乐钱包，she表示二手电商，iou表示闪放云等等
                set $luadebug "1"; #1表示允许调试，0表示不允许调试，在生产环境要设置成0
                access_by_lua_file '/usr/local/openresty/site/lualib/action_apifilter_on_access.lua';
        }

# 需要配置confd
数据格式参考lua代码

# 功能
## action_api_on_access.lua
用于API的筛查，实现功能
1. 请求格式检查
1. 数据格式检查
1. API参数格式检查
1. API名字/版本检查
1. 支持插件式的检查器

## action_checkers_on_rewrite.lua
通用的检查机制
1. 限流：限制制单一IP地址的连接数量保持早一定阀值，允许突破此阀值一定的数量，但高于阀值+突破值后会返回错误
1. 限制连接数：在指定窗口期内限制连接在某一阀值内
1. URL白名单机制：不在白名单内的都会禁止调用
1. 支持插件式的检查器

## action_pullticket.lua
用于拉模式的请求机制，客户端传入一个ticket，nginx从redis中获取该ticket的结果并返回
