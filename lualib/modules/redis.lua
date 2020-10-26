local Redis={
}

function Redis:init(host, port)
  local redis = require "resty.redis"
  local apiutils = require("modules.apiutils")
  self.red = redis:new()
  self.red:set_timeout(1000) -- 1 sec
  local ok, err = self.red:connect(host, port)
  if not ok then
      apiutils:exit(err, 1005)
  end
  return ok
end

function Redis:get(key)
  local ret=self.red:get(key)
  return ret
end

function Redis:set(key, value, expire)
  local ret=self.red:set(key, value)
  self.red:expire(key, expire)
  return ret
end

function Redis:delete(key)
  ret=self.red:del(key)
  return ret
end

return Redis