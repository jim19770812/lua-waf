local etcd=require("modules.etcd"):new("http://127.0.0.1:2379")

etcd:keys_put("a", "100")
local t=etcd:keys_get("a")
print(t)