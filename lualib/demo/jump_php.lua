require('mobdebug').start('127.0.0.1')

local args = ngx.req.get_uri_args()
ngx.req.read_body() -- 解析 body 参数之前一定要先读取 body
local post_body = ngx.req.get_post_args()local res = ngx.location.capture('/run_php',{
      method = ngx.HTTP_POST,
      args=ngx.encode_args(args),
      body=ngx.encode_args(post_body),
})
ngx.say(res.body)
require('mobdebug').done()