--限流+融断控制

--/openresty/traffic/%s/req.limit         number
--/openresty/traffic/%s/req.limitbrust    number
--/openresty/traffic/%s/req.overflownodelay 0/1

local M={
  etcd=nil,
  env=nil,
  limitCache=nil,
  limitReq=nil,
}

function M:init(etcd, env)
  self.etcd=etcd
  self.env=env
  self.limitCache=require("modules.ngxsharedcache")
  self.limitCache:init("traffic_limit_cache")
  
  -- 限制请求速率为200 req/sec，并且允许100 req/sec的突发请求
  -- 就是说我们会把200以上300一下的请求请求给延迟
  -- 超过300的请求将会被拒绝
  self.limitReq=require("modules.limit.req")
end

--得到限制请求速度数
function M:getTraficReqLimit()
    local result=self.limitCache:get("traffic.reqlimit")
    if result==nil then
      local key=string.format("/openresty/traffic/%s/req.limit", self.env)
      result=self.etcd:get(key) or 5000 --默认并发限制5000
      self.limitCache:set("traffic.reqlimit", result, 30000) --缓存30秒
    end
    return tonumber(result)
end

--得到突发请求数
function M:getTrafficReqBurst()
    local result=self.limitCache:get("traffic.reqbrust")
    if result==nil then
      local key=string.format("/openresty/traffic/%s/req.limitbrust", self.env)
      result=self.etcd:get(key) or 1000 --默认突发请求1000
      self.limitCache:set("traffic.reqbrust", result, 30000) --缓存30秒
    end
    return tonumber(result)
end

--是否需要不延迟处理
function M:getTrafficNoDelay()
    local result=self.limitCache:get("traffic.req.overflownodelay")
    if result==nil then
      local key=string.format("/openresty/traffic/%s/req.nodelay", self.env)
      result=self.etcd:get(key) or 1 --默认无延迟
      self.limitCache:set("traffic.req.nodelay", result, 30000) --缓存30秒
    end
    return tonumber(result)
end

function M:check()
  local apiutils = require("modules.apiutils")
  local limitCount=self:getTraficReqLimit()--限制请求数量
  local burstCount=self:getTrafficReqBurst() ----突发请求数量
  local nodelay=self:getTrafficNoDelay() --超速后是否无延迟处理（即当前并发数量在限制请求数量和(限制请求数量+突发请求数量)之间的处理模式 ）
  local lim, err = self.limitReq.new("traffic_limit_cache", limitCount, burstCount)
  if not lim then --没定义共享字典
      apiutils.exit("无效的限流设置", 1005)
  end
   
  local key = ngx.var.binary_remote_addr --IP维度限流
  --请求流入，如果你的请求需要被延迟则返回delay>0
  local delay, err = lim:incoming(key, true)
   
  if not delay and err == "rejected" then
      apiutils.exit("小伙伴们太热情了，请休息一下吧", 1005)
  end
   
  if delay > 0 then --根据需要决定延迟或者不延迟处理
      if nodelay then
          --直接突发处理
      else
          ngx.sleep(delay) --延迟一点时间，单位是毫秒
      end
  end
end

return M