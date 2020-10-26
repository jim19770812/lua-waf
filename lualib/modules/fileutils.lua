local FileUtils={}

function FileUtils:getCurrentDir()
  --第二个参数 "S" 表示仅返回 source,short_src等字段， 其他还可以 "n", "f", "I", "L"等 返回不同的字段信息
  local info = debug.getinfo(1, "S")
  local path = info.source
  --去掉开头的"@"
  path = string.sub(path, 2, -1)
  --捕获最后一个 "/" 之前的部分就是我们最终要的目录部分  
  path = string.match(path, "^.*/")
  return path
end

return FileUtils