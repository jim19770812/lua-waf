--无效地址全部拦截
--不在白名单的API全部拦截
--需要定义在nginx.conf里 lua_shared_dict api_cache 10m;
--需要定义在nginx.conf里 lua_shared_dict traffic_limit_cache 256m;
--需要定义在nginx.conf里 lua_shared_dict traffic_conn_cache 256m;

if ngx.var.luadebug then
  require('mobdebug').start('127.0.0.1')
end
local env=ngx.var.env
local config=require("modules.config"):load(env)
local etcd=require("modules.etcd").new(config.getConfig().etcd.url)
local checkers={}
table.insert(checkers, require("checkers.traffic_limit_conn")) --限制连接数
table.insert(checkers, require("checkers.traffic_limit_req")) --限流+融断
table.insert(checkers, require("checkers.urlpath")) --请求URI白名单检查
for ck,cv in ipairs(checkers) do
  cv:init(etcd, env)
  cv:check()
end
if ngx.var.luadebug then
  require('mobdebug').done()
end