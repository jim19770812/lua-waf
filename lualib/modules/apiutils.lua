local APIUtils={}

local dateUtils=require("modules.dateutils")
errInfo={errCode=1005,
  errMessage=""
}

function APIUtils:buildResult(succCnt, failCnt, resultCode, message)
  local ret={
          successcount=tostring(succCnt),
          failcount=tostring(failCnt),
          timestamp=dateUtils:getDatetimeString(dateUtils:getLongDateTimeFormat()),
          result=tostring(resultCode),
          msg=message
    }
  return ret;
end

function APIUtils:exit(message, errCode)
    local cjson = require("cjson.safe")
    ngx.log(ngx.ERR, "error["..errCode .. "]" .. message)
    local ret=self:buildResult(0, 1, errCode, message)
    --ngx.header["Content-type"] = "text/html";
    ngx.header["Content-type"] = "application/json";
    ngx.say(cjson.encode(ret))
    ngx.eof()
    ngx.exit()
end

function APIUtils:halt(message)
    ngx.header["Content-type"] = "text/html";
    ngx.say(cjson.encode(ret))
    ngx.eof();
    ngx.exit()
end

return APIUtils