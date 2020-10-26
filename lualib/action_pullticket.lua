--根据传入的ticket获取响应数据，用于pull模式api
--请求格式： http://ip:port/action?ticket=<ticket>

if ngx.var.luadebug then
  require('mobdebug').start('127.0.0.1')
end

function exitRequest(response, errorCode, errMessage)
  local cjson = require("cjson.safe")
  ngx.header["Content-type"] = "application/json"
  local tab={resp=response,
        code=tostring(errorCode),
        message=tostring(errMessage)}
  ngx.say(cjson.encode(tab))
  ngx.eof()
  ngx.exit(200)
end

local ticket=ngx.var.arg_ticket

local apiutils = require("modules.apiutils")
local cjson = require("cjson.safe")

local env=ngx.var.env
local config=require("modules.config"):load(env)
if env ==nil then
  apiutils:exit("server env not found", 1005)
end
if ticket == nil then
  apiutils:exit("没有传入有效的ticket参数", 1005)
end

local cjson = require("cjson.safe")
local redis = require("resty.redis")
local red = redis:new()
red:set_timeout(1000) --连接超时时间是1秒
local ok, err = red:connect(config.getConfig().redis.host, config.getConfig().redis.port)
if not ok then
    exitRequest("", "1005", "failed to connect")
end
--red:init_pipeline()
local t=red:get(ticket)
t=((t ==nil or t == ngx.null) and {}) or t
exitRequest(t, 1000, "")

if ngx.var.luadebug then
  require('mobdebug').done()
end