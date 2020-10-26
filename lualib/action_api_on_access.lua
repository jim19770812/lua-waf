--无效地址全部拦截
--不在白名单的API全部拦截
--常量定义
--需要定义在nginx.conf里 lua_shared_dict api_cache 10m;
--另外在nginx location中需要定义
--set $env "csl";  --其中的csl是项目代号，lua会自动找到env/csl.lua并加载其中的配置信息
if ngx.var.luadebug then
  require('mobdebug').start('127.0.0.1')
end

local env=ngx.var.env
local config=require("modules.config"):load(env)
--local tableutils = require("modules.tableutils")
local etcd=require("modules.etcd").new(config.getConfig().etcd.url)
local checkers={}
table.insert(checkers, require("checkers.api_params")) --API参数检查
for ck,cv in ipairs(checkers) do
  cv:init(etcd, env)
  cv:check()
end

if ngx.var.luadebug then
  require('mobdebug').done()
end