local M={}

function M:load(alias)
  local fileutils = require("modules.fileutils")
  local pwd=fileutils:getCurrentDir()
  local envFileName=pwd.."../env/" .. alias .. ".lua"
  file,err=io.open(envFileName)
  if err ~=nil then
    apiutils:exit("server configure error[G0001] " .. envFileName .. "没有找到", 1005)
  end
  io.close(file)
  local config=require("env." .. alias)
  return config
end

return M