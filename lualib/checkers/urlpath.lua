--uri白名单
--/openresty/api/%s/path/<uri> 1

local M={
  etcd=nil,
  env=nil,
  cache=nil
}

function M:init(etcd, env)
  self.etcd=etcd
  self.env=env
  self.cache=require("modules.ngxsharedcache")
  self.cache:init("api_cache")
end

function M:containsPath(list, path)
  local stringutils = require("modules.stringutils")
  for i=1, #list do
      if stringutils:endWiths(list[i], path) then
        return true
      end
  end
  return false
end

function M:getUriCountKeyName()
  local result=string.format("uri.%s.path.count", self.env)
  return result
end

--index下标从1开始
function M:getUriKeyName(uri, index)
  local result=string.format("uri.%s.path.%d", self.env, index)
  return result
end

function M:check()
  local apiutils = require("modules.apiutils")
  local urlutils = require("modules.urlutils")
  local tableutils = require("modules.tableutils")
  local urlInfo=urlutils.parse(ngx.var.request_uri)
  local uriCountKeyName=self:getUriCountKeyName()
  local cnt=self.cache:get(uriCountKeyName)
  local pathList={}
  local uriRootPath=string.format("/openresty/api/%s/path", self.env)
  if (cnt==nil or cnt==0) then
    pathList=self.etcd:ls(uriRootPath)
    self.cache:set(uriCountKeyName, #pathList, 30000)--缓存30秒，如果基数不存在了就视做整个缓存都过期了
    local t= self.cache:get(uriCountKeyName)
    for i=1,#pathList do
      local uri=pathList[i]
      local uriKeyName=self:getUriKeyName(urlInfo.path, i)
      self.cache:set(uriKeyName, uri, 30000) --缓存30秒
    end
  end

  if next(pathList) == nil then
    for i=1,cnt do
      local uriKeyName=self:getUriKeyName(urlInfo.path, i)
      local uri=self.cache:get(uriKeyName)
      table.insert(pathList, uri)
    end
  end

  local ret=tableutils:indexOfArray(pathList, uriRootPath..urlInfo.path)
  if ret <=0 then
    ngx.header["Content-type"] = "text/html";
    apiutils:halt()
  end
end

return M