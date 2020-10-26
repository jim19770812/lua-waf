--流量控制

--/openresty/traffic/%s/conn.limit 5000 时间窗口内的连接数
--/openresty/traffic/%s/conn.timewindow 3600 连接限制的时间窗口，单位是秒

local M={
  etcd=nil,
  env=nil,
  connCache=nil,
  limitConn=nil
}

function M:init(etcd, env)
  self.etcd=etcd
  self.env=env
  self.connCache=require("modules.ngxsharedcache")
  self.connCache:init("traffic_conn_cache")
  self.limitConn=require("modules.limit.count")
end

--连接限制的时间窗口，单位是秒
function M:getConnTimeWindow()
    local result=self.connCache:get("traffic.conn.timewindow")
    if result==nil then
      local key=string.format("/openresty/traffic/%s/conn.timewindow", self.env)
      result=self.etcd:get(key) or 1 --默认时间窗口1秒
      self.connCache:set("traffic.conn.timewindow", result, 30000) --缓存30秒
    end
    return tonumber(result)
end

--/openresty/traffic/%s/conn.limit 5000 时间窗口内的连接数
function M:getConnLimit()
    local result=self.connCache:get("traffic.conn.limit")
    if result==nil then
      local key=string.format("/openresty/traffic/%s/conn.limit", self.env)
      result=self.etcd:get(key) or 5000 --默认5000连接
      self.connCache:set("traffic.conn.limit", result, 30000) --缓存30秒
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