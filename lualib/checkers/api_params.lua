local M={
  etcd=nil,
  env=nil,
  cache=nil
}

function M:init(etcd, env)
  self.etcd=etcd
  self.env=env
  self.apiutils=require("modules.apiutils")
  self.cache=require("modules.ngxsharedcache")
  self.cache:init("api_cache")
end

function M:getKeyName(env, apiName, apiVersion)
  local stringUtils=require("modules.stringutils")
  local version=stringUtils:strReplace(apiVersion, "[.]", "_")
  return "/openresty/api/" .. env.. "/" .. apiName .."_" .. version
end

--查找API
function M:find(env, apiName, apiVersion)
  local cjson = require("cjson.safe")
  local tableUtils=require("modules.tableutils")
  local keyName=self:getKeyName(env, apiName, apiVersion)
  local result=nil
  if not self:getAPIDefineFromCache(keyName) then
    result=self.etcd:get(keyName)
    self:saveAPIDefineToCache(keyName, result, 30000) --缓存30秒
  end
  return cjson.decode(result)
end

function M:getAPIDefineFromCache(key)
    local result = self.cache:get(key)
    return result
end

function M:saveAPIDefineToCache(key, value, exptime)
    if not exptime then
        exptime = 0
    end

    local succ, err, forcible = self.cache:set(key, value)
    return succ
end

function M:check()
  local cache = ngx.shared.api_cache
  if cache==nil then
    apiutils:exit("server configure error[G0001] no cache found", 1005)
    print("未在nginx.conf中定义 lua_shared_dict api_cache 8m;")
  end
  cache:flush_expired(50)--清理掉超过50个的过期缓存项

  local apiutils = require("modules.apiutils")
  local cjson = require("cjson.safe")
  --参数检查
  local c=ngx.var.arg_c
  local stringutils=require("modules.stringutils")
  local urlutils = require("modules.urlutils")

  --检查c参数是否存在
  if c==nil then
    apiutils:exit("invalid api[G0002] ", 1005)
  end

  --检查c参数是否是一个有效的json
  local t1=ngx.unescape_uri(c)
  local actParams= cjson.decode(urlutils:decodeUrl(stringutils:rTrim(stringutils:lTrim(t1))))
  if actParams==nil or type(actParams) ~= "table" then
    apiutils:exit("invalid api[G0003]", 1005)
  end

  local tableUtils=require("modules.tableutils")
  if not tableUtils:containKey(actParams, "cliname") then
    self.apiutils:exit("请求格式错误，没有包含有效的count属性", 1005)
  end
  if not tableUtils:containKey(actParams, "cliver") then
    self.apiutils:exit("请求格式错误，没有包含有效的cliver属性", 1005)
  end
  if not tableUtils:containKey(actParams, "source") then
    self.apiutils:exit("请求格式错误，没有包含有效的source属性", 1005)
  end
  if not tableUtils:containKey(actParams, "sessionkey") then
    self.apiutils:exit("请求格式错误，没有包含有效的sessionkey属性", 1005)
  end
  if not tableUtils:containKey(actParams, "uid") then
    self.apiutils:exit("请求格式错误，没有包含有效的uid属性", 1005)
  end
  if not tableUtils:containKey(actParams, "reqs") then
    self.apiutils:exit("请求格式错误，没有包含有效的reqs属性", 1005)
  end
  local reqs=actParams["reqs"]
  for i in pairs(reqs) do
    local req=reqs[i]
    if not tableUtils:containKey(req, "name") then
      self.apiutils:exit("请求格式错误，没有包含有效的name属性", 1005)
    end
    if not tableUtils:containKey(req, "version") then
      self.apiutils:exit("请求格式错误，没有包含有效的version属性", 1005)
    end
    local name=req["name"]
    local version=req["version"]
    local def=self:find(self.env, name, version)
    if def ==nil then
      self.apiutils:exit(string.format("请求格式错误，API[%s]没有找到", name), 1005)
    end
  end

end

return M