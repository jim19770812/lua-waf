local M={
  name=nil
}

function M:init(name)
  self.name=name
end

function M:getCache()
  local cache=ngx.shared[self.name]
  return cache
end

function M:get(key)
  local cache=self:getCache()
  local result=cache:get(key)
  return result
end

function M:set(key, val, expires)
  local cache=self:getCache()
  cache:set(key, val, expires)
end

return M