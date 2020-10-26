require('mobdebug').start('127.0.0.1')
ngx.sleep(0.1)
local request_filename=ngx.var.request_filename
local document_root=ngx.var.document_root
local fastcgi_script_name=ngx.var.fastcgi_script_name
local path_info=ngx.var.path_info
ngx.say("document_root=" .. tostring(document_root))
ngx.say("fastcgi_script_name=" .. tostring(sfastcgi_script_name))
ngx.say("path_info="..tostring(path_info))
ngx.say("request_filename" .. tostring(request_filename))
require('mobdebug').done()