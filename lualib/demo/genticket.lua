require('mobdebug').start('127.0.0.1')

local ticket=ngx.var.arg_ticket

if ticket == nil then
   ngx.say("没有传入有效的ticket参数")
   ngx.eof()
   ngx.exit()
end

local cjson = require("cjson.safe")
local redis = require("resty.redis")
local red = redis:new()
local host="127.0.0.1"
local port=6379
red:set_timeout(1000) --连接超时时间是1秒
local ok, err = red:connect(host, port)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end
local args = ngx.req.get_uri_args()
local tab={}
tab["name"]="100"
--red:eval(string.format("return redis.call('sadd', '%s', '%s')",args.ticket, tab), 0)
red:set("pull." .. ticket, cjson.encode(tab))
require('mobdebug').done()