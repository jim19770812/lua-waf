local Env={}

function Env:getConfig()
  return {
    redis={
      host="127.0.0.1",
      port=6379
    },
    etcd={
      url="http://127.0.0.1:2379"
    },
  }
end

return Env